#import "Node.h"

#import "utils.h"

#import <GLUT/GLUT.h>
#import "RayCast.h"


@implementation Node {
}


- (id)initWithParent:(Node*)parent origin:(glm::vec3)origin size:(glm::vec3)size
{
  if (self == [super init]) {
    _parentNode = parent;
    _origin = origin;
    _size = size;
    _childNodes = [NSMutableArray array];
  }
  return self;
}

-(void)dealloc
{
}


- (glm::vec3)worldOrigin
{
  glm::vec3 origin = _origin;
  if (_parentNode) {
    origin += _parentNode.worldOrigin;
  }
  return origin;
}


- (BoundingBox *)aabbWorld
{
  return [[BoundingBox alloc] initWithOrigin:self.worldOrigin size:_size];
}


- (void)renderActiveBoundsInWorld
{
  glm::vec3 worldOrigin = self.worldOrigin;
  glTranslatef(worldOrigin.x, worldOrigin.y, worldOrigin.z);
  glColor3f(1, 0, 0);
  wireBox(glm::vec3(-_size.x/2, -_size.y/2, -_size.z/2), glm::vec3(_size.x/2, _size.y/2, _size.z/2));
//  glutWireCube(_size.x);
}


- (void)render
{
  // just do translation as simple node has no idea how to render itself
  glTranslatef(_origin.x, _origin.y, _origin.z);
  for (Node *child in _childNodes) {
    glPushMatrix();
    [child render];
    glPopMatrix();
  }
}


- (void)renderBounds
{
  glTranslatef(_origin.x, _origin.y, _origin.z);
  
  // test cube
  //  glLoadIdentity();
  //  glTranslatef(0, 0, 0);
  //  glColor3f(.7, .7, .7);
  //
  //  glPolygonOffset( 1.0, 1.0 );
  //  glEnable(GL_POLYGON_OFFSET_FILL);
  //  glutSolidCube(1);
  //  glDisable(GL_POLYGON_OFFSET_FILL);
  //
  //  glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
  //  glColor3f(.2, .2, .2);
  //  glutSolidCube(1);
  //  glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
  
  glColor3f(1, 1, 0);
//  glutWireCube(_size.x);

  
  wireBox(glm::vec3(-_size.x/2, -_size.y/2, -_size.z/2), glm::vec3(_size.x/2, _size.y/2, _size.z/2));
  
  
  for (Node *child in _childNodes) {
    glPushMatrix();
    [child renderBounds];
    glPopMatrix();
  }
  
//  glBegin(GL_LINES);
//  {
//    CGFloat halfSize = _size.x/2;
//    glColor3f(0, 1, 0);
//    glVertex3f(-halfSize, -halfSize, -halfSize);
//    glColor3f(1, 0, 0);
//    glVertex3f(halfSize, halfSize, halfSize);
//  }
//  glEnd();
  
}


- (void)increaseDetail
{
  // add inner quads as child nodes inside
  
  // create 8 quads
//  CGFloat childSize = _size.x / 2;
//  CGFloat halfSize = childSize / 2;
  
  // create 8 quads
  CGFloat childHalfX = _size.x / 4;
  CGFloat childHalfY = _size.y / 4;
  CGFloat childHalfZ = _size.z / 4;
  
  glm::vec3 childSize(_size.x / 2, _size.y / 2, _size.z / 2);
  
  if (!_childNodes.count) {
    // top front left
    [_childNodes addObject:[[Node alloc] initWithParent:self origin:glm::vec3(-childHalfX, childHalfY, childHalfZ)
                                                   size:childSize]];
    // top front right
    [_childNodes addObject:[[Node alloc] initWithParent:self origin:glm::vec3(childHalfX, childHalfY, childHalfZ)
                                                   size:childSize]];
    // top rear left
    [_childNodes addObject:[[Node alloc] initWithParent:self origin:glm::vec3(-childHalfX, childHalfY, -childHalfZ)
                                                   size:childSize]];
    // top rear right
    [_childNodes addObject:[[Node alloc] initWithParent:self origin:glm::vec3(childHalfX, childHalfY, -childHalfZ)
                                                   size:childSize]];
    // bottom front left
    [_childNodes addObject:[[Node alloc] initWithParent:self origin:glm::vec3(-childHalfX, -childHalfY, childHalfZ)
                                                   size:childSize]];
    // bottom front right
    [_childNodes addObject:[[Node alloc] initWithParent:self origin:glm::vec3(childHalfX, -childHalfY, childHalfZ)
                                                   size:childSize]];
    // bottom rear left
    [_childNodes addObject:[[Node alloc] initWithParent:self origin:glm::vec3(-childHalfX, -childHalfY, -childHalfZ)
                                                   size:childSize]];
    // bottom rear right
    [_childNodes addObject:[[Node alloc] initWithParent:self origin:glm::vec3(childHalfX, -childHalfY, -childHalfZ)
                                                   size:childSize]];
  } else {
    for (Node * child in _childNodes) {
      [child increaseDetail];
    }
  }
}


- (BOOL)decreaseDetail
{
  if (_childNodes.count) {
    NSMutableArray *removableNodes = [NSMutableArray array];
    for (Node *child in _childNodes) {
      if (child.decreaseDetail) {
        [removableNodes addObject:child];
      }
    }
    [_childNodes removeObjectsInArray:removableNodes];
    return NO;
  }
  return YES;
}


- (NSArray*)nodesHitByRay:(glm::vec3)ray origin:(glm::vec3)origin
{
  NSMutableArray *nodesHit = [NSMutableArray array];
  if ([self rayDistanceToNode:ray origin:origin] >= 0) {
    for (Node *child in _childNodes) {
      [nodesHit addObjectsFromArray:[child nodesHitByRay:ray origin:origin]];
    }
    if (!nodesHit.count) [nodesHit addObject:self];
  }
  return nodesHit;
}


- (NodePick)pickClosestNode:(glm::vec3)ray origin:(glm::vec3)origin
{
  NodePick pick;
  pick.distance = -1;
  
  
  BoundingBox *aabb = self.aabbWorld;
  pick.distance = rayDistanceToBox(ray, origin, aabb.min, aabb.max);
  if (pick.distance >= 0) {
    pick.node = self;
    // try to find child node closer to origin
    for (Node *child in _childNodes) {
      NodePick childPick = [child pickClosestNode:ray origin:origin];
      if (childPick.distance >= 0 && childPick.distance <= pick.distance) {
        pick = childPick;
      }
    }
  }
  return pick;
}




@end

