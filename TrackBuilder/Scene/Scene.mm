#import "Scene.h"
#import "AppDelegate.h"
#import <OpenGL/gl.h>
#import "Delaunay.h"
#import "NSValue+vec3.h"
#import "RayCast.h"


NSString * const SceneNeedsRenderNotification = @"SceneNeedsRenderNotification";

@implementation Scene

- (id)init
{
  if (self = [super init]) {
    _meshes = [NSMutableDictionary dictionary];
  }
  return self;
}


- (void)generateTerrain:(CGSize)size
{
  NSLog(@"regenerating terrain of size: %@", NSStringFromSize(size));
  
  // generate random terrain and add to the scene
  
  Mesh *terrainMesh = [Mesh new];
  
  vertexSet vertices;
  int segments = 5;
//  float offset = (float)segments / 2;
  float offset = (float)segments / 3;
  for (int i = 0; i < segments+1; ++i) {
    if (!i%2) {
      for (int j = 0; j < segments+1; ++j) {
        vertices.insert(vertex(i-offset, j-offset));
      }
    } else {
      for (int j = segments; j >= 0; --j) {
        vertices.insert(vertex(i-offset, j-offset));
      }
    }
  }


  triangleSet triangles;
  
  Delaunay d;
  d.Triangulate(vertices, triangles);
  
  NSLog(@"Generated %ld triangles from %ld vertices", triangles.size(), vertices.size());
  
  for ( triangleSet::iterator it = triangles.begin();
       it != triangles.end(); ++it ) {
    triangle t = *it;
    [terrainMesh addTriangleWithV1:glm::vec3(t.GetVertex(0)->GetX(), 0, t.GetVertex(0)->GetY())
                                v2:glm::vec3(t.GetVertex(1)->GetX(), 0, t.GetVertex(1)->GetY())
                                v3:glm::vec3(t.GetVertex(2)->GetX(), 0, t.GetVertex(2)->GetY())];
  }

  [_meshes setValue:terrainMesh forKey:@"terrain"];
  
//  [self recalculateOctree];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:SceneNeedsRenderNotification object:nil];
}


- (void)renderMeshes
{
  glLoadIdentity();

  for (Mesh *mesh in _meshes.allValues) {
    for (DHPolygon *poly in mesh.polygons) {
      
      glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

      glBegin(poly.indexes.count==3 ? GL_TRIANGLES : GL_QUADS);
      {
        glColor3f(.7, .7, .7);
        
        for (NSNumber *index in poly.indexes) {
          glm::vec3 v = UNWRAP_V3(mesh.vertices[index.intValue]);
          glVertex3f(v.x, v.y, v.z);
        }
      }
      glEnd();
      
      if (DHApp.debugMode > NO_DEBUG) {
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
        glPolygonOffset(self.pickedPolygon == poly ? -2.0 : -1.0, 1.0 );
        glEnable(GL_POLYGON_OFFSET_LINE);

        glBegin(poly.indexes.count==3 ? GL_TRIANGLES : GL_QUADS);
        {
          glColor3f(1, self.pickedPolygon == poly ? 0 : 1, 0);
          for (NSNumber *index in poly.indexes) {
            glm::vec3 v = UNWRAP_V3(mesh.vertices[index.intValue]);
            glVertex3f(v.x, v.y, v.z);
          }
        }
        glEnd();
        glDisable(GL_POLYGON_OFFSET_LINE);
      }
    }
    [mesh.obb renderBBWithColor:mesh == self.pickedMesh ? [NSColor redColor] : [NSColor greenColor]];
  }
}


- (void)renderBounds
{
  [_octree renderBounds];
}


- (BOOL)pickNodeWithRay:(glm::vec3)ray origin:(glm::vec3)origin
{
  self.pickedMesh = nil;
  self.pickedPolygon = nil;
  for (Mesh *mesh in _meshes.allValues) {
    CGFloat closestHit = 1000000;
    BoundingBox *aabb = mesh.obb;
    CGFloat distanceToMesh = rayDistanceToBox(ray, origin, aabb.min, aabb.max);
    if (distanceToMesh > 0 && distanceToMesh < closestHit) {
      closestHit = distanceToMesh;
      self.pickedMesh = mesh;
    }
  }
  
  for (DHPolygon *poly in self.pickedMesh.polygons) {
    CGFloat closestHit = 1000000;
    
    CGFloat distanceToNode = -1;
    if (poly.indexes.count == 3) {
      distanceToNode = rayDistanceToTriangle(ray, origin,
                                             UNWRAP_V3(self.pickedMesh.vertices[[poly.indexes[0] intValue]]),
                                             UNWRAP_V3(self.pickedMesh.vertices[[poly.indexes[1] intValue]]),
                                             UNWRAP_V3(self.pickedMesh.vertices[[poly.indexes[2] intValue]]));
    } else if (poly.indexes.count == 4) {
      distanceToNode = rayDistanceToQuad(ray, origin,
                                         UNWRAP_V3(self.pickedMesh.vertices[[poly.indexes[0] intValue]]),
                                         UNWRAP_V3(self.pickedMesh.vertices[[poly.indexes[1] intValue]]),
                                         UNWRAP_V3(self.pickedMesh.vertices[[poly.indexes[2] intValue]]),
                                         UNWRAP_V3(self.pickedMesh.vertices[[poly.indexes[3] intValue]]));
    }
    if (distanceToNode > 0 && distanceToNode < closestHit) {
      closestHit = distanceToNode;
      self.pickedPolygon = poly;
    }
  }
  
  if ([_octree pickNodeWithRay:ray origin:origin]) {
    //NSArray *nodesHit = _octree.nodesHitByRay;
    // use nodes hit to filter meshes and their vertices
    return YES;
  }
  return NO;
}


- (void)recalculateOctree
{
  NSLog(@"recalculating octree brute force");
  // calc the bounds & make it the source
  const CGFloat HUGE_NUM = 100000;
  CGFloat minX(HUGE_NUM), minY(HUGE_NUM), minZ(HUGE_NUM),
    maxX(-HUGE_NUM), maxY(-HUGE_NUM), maxZ(-HUGE_NUM);
  
  for (Mesh *mesh in _meshes.allValues) {
    NSArray *vertices = mesh.vertices;
    for (DHPolygon *poly in mesh.polygons) {
      for (NSNumber *index in [poly indexes]) {
        glm::vec3 vertex = UNWRAP_V3(vertices[index.integerValue]);
        // min point
        minX = vertex.x < minX ? vertex.x : minX;
        minY = vertex.y < minY ? vertex.y : minY;
        minZ = vertex.z < minZ ? vertex.z : minZ;

        // max point
        maxX = vertex.x > maxX ? vertex.x : maxX;
        maxY = vertex.y > maxY ? vertex.y : maxY;
        maxZ = vertex.z > maxZ ? vertex.z : maxZ;
      }
    }
  }
  
  // calc size
  CGFloat sizeX = maxX - minX;
  CGFloat sizeY = maxY - minY;
  CGFloat sizeZ = maxZ - minZ;
  CGFloat size = MAX(MAX(sizeX, sizeY), sizeZ);
  
  _octree = [[Octree alloc] initWithParent:nil origin:glm::vec3(0) size:glm::vec3(size)];
}

@end
