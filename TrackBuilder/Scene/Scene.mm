#import "Scene.h"
#import "AppDelegate.h"

#import "Delaunay.h"

NSString * const SceneNeedsRenderNotification = @"SceneNeedsRenderNotification";

@implementation Scene

- (id)init
{
  if (self = [super init]) {
    CGFloat initialSize = 3;
    _octree = [[Octree alloc] initWithParent:nil origin:glm::vec3(0) size:glm::vec3(initialSize)];
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
  for (int i = 0; i < segments+1; ++i) {
    if (!i%2) {
      for (int j = 0; j < segments+1; ++j) {
        vertices.insert(vertex(i, j));
      }
    } else {
      for (int j = segments; j >= 0; --j) {
        vertices.insert(vertex(i, j));
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
        glPolygonOffset( -1.0, 1.0 );
        glEnable(GL_POLYGON_OFFSET_LINE);

        glBegin(poly.indexes.count==3 ? GL_TRIANGLES : GL_QUADS);
        {
          glColor3f(1, 1, 0);
          for (NSNumber *index in poly.indexes) {
            glm::vec3 v = UNWRAP_V3(mesh.vertices[index.intValue]);
            glVertex3f(v.x, v.y, v.z);
          }
        }
        glEnd();
        glDisable(GL_POLYGON_OFFSET_LINE);
      }
    }
  }
}

- (void)renderBounds
{
  [_octree renderBounds];
}

- (BOOL)pickNodeWithRay:(glm::vec3)ray origin:(glm::vec3)origin
{
  if ([_octree pickNodeWithRay:ray origin:origin]) {
    NSArray *nodesHit = _octree.nodesHitByRay;
    // use nodes hit to filter meshes and their vertices
    return YES;
  }
  return NO;
}



@end
