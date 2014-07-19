#import "Scene.h"
#import "AppDelegate.h"
#import <OpenGL/gl.h>
#import "Delaunay.h"
#import "NSValue+vec3.h"
#import "RayCast.h"
#import <glm/gtc/matrix_transform.hpp>
#import "utils.h"


NSString * const SceneNeedsRenderNotification = @"SceneNeedsRenderNotification";

@implementation Scene

- (id)init
{
  if (self = [super init]) {
    self.rootNode = [[SceneNode alloc] initWithMesh:nil];
  }
  return self;
}

- (void)resetScene
{
  [self.rootNode purgeOBB];
}


@end


#pragma mark - Ray hit test

static int g_nodesChecked = 0;
static int g_polygonsChecked = 0;

@implementation Scene (RayCast)

- (CGFloat)hitTestForNode:(SceneNode *)node
                      ray:(glm::vec3)ray
                   origin:(glm::vec3)origin
            withTransform:(glm::mat4)parentTransform
               pickedNode:(SceneNode **)outNode
                  polygon:(DHPolygon **)outPolygon
{
  g_nodesChecked++;
  glm::mat4 combinedTransform = parentTransform * node.transform;
  BoundingBox *nodeAABB = [node.obb boundingBoxForTransform:combinedTransform];
  CGFloat hitDistance = rayDistanceToBox(ray, origin, nodeAABB.min, nodeAABB.max);
  // bail quickly if aabb is not hit
  if (hitDistance < 0) {
    return -1;
  }
  // delve deeper
  for (SceneNode *childNode in node.childNodes) {
    SceneNode *localNode;
    DHPolygon *localPolygon;
    CGFloat childHitDistance = [self hitTestForNode:childNode ray:ray origin:origin withTransform:combinedTransform pickedNode:&localNode polygon:&localPolygon];
    if (childHitDistance < 0) {
      continue;
    }
    if (childHitDistance < hitDistance) {
      hitDistance = childHitDistance;
      *outNode = localNode;
      *outPolygon = localPolygon;
    }
  }
  if (!node.mesh) {
    if (*outPolygon) {
      return hitDistance;
    }
    return -1;
  }
  
  // try to hit the mesh
  BoundingBox *meshAABB = [node.mesh.obb boundingBoxForTransform:combinedTransform];
  CGFloat meshBBHitDistance = rayDistanceToBox(ray, origin, meshAABB.min, meshAABB.max);
  if (meshBBHitDistance < 0 || meshBBHitDistance > hitDistance) {
    if (*outPolygon) {
      return hitDistance;
    }
    return -1;
  }
  // try to hit polygon
  Mesh *mesh = node.mesh;
  CGFloat minDistanceToPoly = -1;
  for (DHPolygon *poly in mesh.polygons) {
    g_polygonsChecked++;
    CGFloat distanceToPoly = rayDistanceToTriangle(ray, origin,
      transformV3(UNWRAP_V3(mesh.vertices[[poly.indexes[0] intValue]]), combinedTransform),
      transformV3(UNWRAP_V3(mesh.vertices[[poly.indexes[1] intValue]]), combinedTransform),
      transformV3(UNWRAP_V3(mesh.vertices[[poly.indexes[2] intValue]]), combinedTransform));
    if (distanceToPoly < 0) {
      continue;
    }
    if (minDistanceToPoly < 0 || distanceToPoly < minDistanceToPoly) {
      minDistanceToPoly = distanceToPoly;
      *outNode = node;
      *outPolygon = poly;
    }
  }
  return fmin(hitDistance, minDistanceToPoly);
}


- (BOOL)pickNodeWithRay:(glm::vec3)ray origin:(glm::vec3)origin
{
  g_polygonsChecked = 0;
  g_nodesChecked = 0;
  
  self.pickedNode = nil;
  self.pickedPolygon = nil;
  
  SceneNode *localNode;
  DHPolygon *localPolygon;
  [self hitTestForNode:self.rootNode ray:ray origin:origin withTransform:glm::mat4(1.0) pickedNode:&localNode polygon:&localPolygon];
//  NSLog(@"Node %ld hit at %f distance", [self.rootNode.childNodes indexOfObject:localNode],  hitDistance);
//  NSLog(@"Ray cast checked %d nodes and %d polygons", g_nodesChecked, g_polygonsChecked);
  if (localNode && localPolygon) {
    self.pickedNode = localNode;
    self.pickedPolygon = localPolygon;
  }

  return NO;
}

@end


#pragma mark - Rendering

@implementation Scene (Render)

// recursively apply transform & render nodes
- (void)renderNode:(SceneNode *)node withTransform:(glm::mat4)transform
{
  glPushMatrix();

  // set transform for node
  glm::mat4 combinedTransform = transform * node.transform;
  glLoadMatrixf(glm::value_ptr(combinedTransform));
  
  Mesh *mesh = node.mesh;
  
  for (DHPolygon *poly in mesh.polygons) {
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

    glBegin(poly.indexes.count==3 ? GL_TRIANGLES : GL_QUADS);
    {
      if (poly == self.pickedPolygon) {
        glColor3f(1, .7, .7);
      } else {
        glColor3f(.7, .7, .7);
      }

      for (NSNumber *index in poly.indexes) {
        glm::vec3 v = UNWRAP_V3(mesh.vertices[index.intValue]);
        glVertex3f(v.x, v.y, v.z);
      }
    }
    glEnd();

    if (DHApp.debugMode > BASIC_DEBUG || poly == self.pickedPolygon) {
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
  
  if (DHApp.debugMode > NO_DEBUG) {
    BoundingBox *nodeBB = node.obb;
    if (node.mesh) {
      [node.mesh.obb renderBBWithColor:node == self.pickedNode ? [NSColor redColor] : [NSColor cyanColor]];
    }
    
    // calculate aabb
    BoundingBox *aabb = [nodeBB boundingBoxForTransform:combinedTransform];
    glPushMatrix();
    glLoadIdentity();
    // render
    [aabb renderBBWithColor:node == self.pickedNode ? [NSColor redColor] : [NSColor greenColor]];
    glPopMatrix();
  }
  
  for (SceneNode *childNode in node.childNodes) {
    [self renderNode:childNode withTransform:combinedTransform];
  }

  glPopMatrix();
}


- (void)renderNodes
{
  glLoadIdentity();
  
//  [self.rootNode precalcOBB];
  
  [self renderNode:self.rootNode withTransform:glm::mat4x4(1.0f)];
}


- (void)renderBounds
{
}


@end


#pragma mark - Terrain generation

@implementation Scene (Generation)

- (void)generateTerrain:(CGSize)size
{
//  [self.rootNode.childNodes removeAllObjects];
  
//  [self generateNodeWith2Pyramids];
//  return;
  NSLog(@"regenerating terrain of size: %@", NSStringFromSize(size));
  
  // generate random terrain and add to the scene
  
  Mesh *terrainMesh = [Mesh new];
  
  vertexSet vertices;
  int segments = 5;
  //  float offset = (float)segments / 2;
//  float offset = (float)segments / 3;
  float offset = 0;
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
  
  SceneNode *terrainNode = [[SceneNode alloc] initWithMesh:terrainMesh];
//  // center in the world
  BoundingBox *box = terrainMesh.obb;
  terrainNode.transform = glm::translate(glm::mat4(), glm::vec3(-box.size.x / 2, (rand()%1000) / 1000.0 -box.size.y / 2, -box.size.z / 2))
    * glm::rotate(glm::mat4(1.0f), (float)(rand() % 360), glm::vec3(0, 1, 0));
  [self.rootNode.childNodes addObject:terrainNode];
  
  // add pyramid on top
  SceneNode *pyramidNode = [[SceneNode alloc] initWithMesh:[Mesh pyramidWithWidth:.5 height:.5]];
//  pyramidNode.transform = glm::translate(glm::mat4(1.0f), glm::vec3(1, 0, 0)) * glm::rotate(glm::mat4(1.0f), 30.0f, glm::vec3(0, 1, 0));
//  pyramidNode.transform = glm::translate(glm::mat4(1.0f), glm::vec3(-1, 0, 0)) * glm::rotate(glm::mat4(1.0f), 30.0f, glm::vec3(0, 1, 0));
  pyramidNode.transform = glm::rotate(glm::mat4(), 15.0f, glm::vec3(0, 1, 0)) * glm::translate(glm::mat4(), glm::vec3(-.5, 0, -.5));
  [terrainNode.childNodes addObject:pyramidNode];
//  [self.rootNode.childNodes addObject:pyramidNode];
  
  [self resetScene];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:SceneNeedsRenderNotification object:nil];
}


- (void)generateNodeWith2Pyramids
{
  SceneNode *containerNode = [[SceneNode alloc] initWithMesh:nil];
  
  SceneNode *pyramidNode1 = [[SceneNode alloc] initWithMesh:[Mesh pyramidWithWidth:.5 height:.5]];
  pyramidNode1.transform = glm::translate(glm::mat4(1.0f), glm::vec3(1, -0.2, 0)) * glm::rotate(glm::mat4(1.0f), 30.0f, glm::vec3(0, 1, 0));
  [containerNode.childNodes addObject:pyramidNode1];

  SceneNode *pyramidNode2 = [[SceneNode alloc] initWithMesh:[Mesh pyramidWithWidth:.5 height:.7]];
  pyramidNode2.transform = glm::translate(glm::mat4(1.0f), glm::vec3(-1, 0, 2)) * glm::rotate(glm::mat4(1.0f), -15.0f, glm::vec3(0, 1, 0));
  [containerNode.childNodes addObject:pyramidNode2];
  
  [self.rootNode.childNodes addObject:containerNode];
}

@end

