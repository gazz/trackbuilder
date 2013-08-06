#import "Node.h"

#import "utils.h"

#import <GLUT/GLUT.h>

#import "AppDelegate.h"


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


- (AABB) aabbWorld
{
  AABB b;
  glm::vec3 worldOrigin = self.worldOrigin;
  b.min = glm::vec3(worldOrigin.x - _size.x/2, worldOrigin.y - _size.y/2, worldOrigin.z - _size.z/2);
  b.max = glm::vec3(worldOrigin.x + _size.x/2, worldOrigin.y + _size.y/2, worldOrigin.z + _size.z/2);
  return b;
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
  
  pick.distance = [self rayDistanceToNode:ray origin:origin];
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


- (CGFloat)rayDistanceToNode:(glm::vec3)ray origin:(glm::vec3)origin
{
  AABB aabb = self.aabbWorld;
  
  // the basic check if origin is within the box, then return hit
  DHApp.numRayCalculations++;
  
  
  CGFloat tmin, tmax, tymin, tymax, tzmin, tzmax;
  
  // calc base min & max
  tmin = (aabb.min.x - origin.x) / ray.x;
  tmax = (aabb.max.x - origin.x) / ray.x;
  if (tmin > tmax) swap(tmin, tmax);
  
  // calc z min & max
  tzmin = (aabb.min.z - origin.z) / ray.z;
  tzmax = (aabb.max.z - origin.z) / ray.z;
  if (tzmin > tzmax) swap(tzmin, tzmax);
  
  if (tmin > tzmax || tzmin > tmax) return -1;
  
  // calc 3rd dimension
  if (tzmin > tmin) tmin = tzmin;
  if (tzmax < tmax) tmax = tzmax;
  
  tymin = (aabb.min.y - origin.y) / ray.y;
  tymax = (aabb.max.y - origin.y) / ray.y;
  if (tymin > tymax) swap(tymin, tymax);
  
  if (tmin > tymax || tymin > tmax) return -1;
  
//  NSLog(@"tmin: %f, tmax: %f", tmin, tmax);
  if (tmax < 0) return -1;
  
  ;
  // calculate distance and validate if within range
  //  if (tzmin > tmin) tmin = tzmin;
  //  if (tzmax < tmax) tmax = tzmax;
  //
  //  if (tmin > maxDistance) || tmax < minDistance) return false;
  //
  //  if (r.tmin < tmin) r.tmin = tmin;
  //  if (r.tmax > tmax) r.tmax = tmax;
  
  //
  //  CGFloat tMinZ = (bounds.min.z - origin.z) / ray.z;
  //  CGFloat tMaxZ = (bounds.max.z - origin.z) / ray.z;
  //  if (tMinZ > tMaxZ) swap(tMinZ, tMinZ);
  //
  
  return glm::length(glm::vec3(tmax, tymax, tzmax));
}

@end

