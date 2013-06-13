#import "Octree.h"
#import <OpenGL/OpenGL.h>
#import "AppDelegate.h"

@implementation Octree

- (id)init
{
  if (self == [super initWithParent:nil origin:glm::vec3(0, 0, 0) size:glm::vec3(2, 1, 2)]) {
  }
  return self;
}


- (void)renderBounds
{
  
  glLoadIdentity();
  
  if (DHApp.debugMode > BASIC_DEBUG) {
    glPushMatrix();
    [super renderBounds];
    glPopMatrix();
  }
  
  if (DHApp.debugMode > NO_DEBUG) {
    if (_nodesHitByRay) {
      glClear(GL_DEPTH_BUFFER_BIT);
      // render bounds
      for (Node *child in _nodesHitByRay) {
        glPushMatrix();
        [child renderActiveBoundsInWorld];
        glPopMatrix();
      }
    }
  }
}


- (BOOL)pickNodeWithRay:(glm::vec3)ray origin:(glm::vec3)origin
{
//  _nodesHitByRay = [self nodesHitByRay:ray origin:origin];
  DHApp.numRayCalculations = 0;
  NodePick pick = [self pickClosestNode:ray origin:origin];
//  NSLog(@"Picked node with %ld calculations", DHApp.numRayCalculations);
  _nodesHitByRay = (pick.distance >= 0 ? @[pick.node] : nil);
  return _nodesHitByRay.count;
}


- (void)addTriangle:(Triangle)triangle
{
  // add triangle to mesh and create
}


@end
