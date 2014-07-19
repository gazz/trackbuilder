#import "SceneNode.h"
#include <glm/gtc/matrix_transform.hpp>
#import "BoundingBox.h"
#import "Mesh.h"


@implementation SceneNode {
  BoundingBox *_cachedOBB;
}


- (id)initWithMesh:(Mesh *)mesh
{
  self = [self initWithMesh:mesh transform:glm::mat4()];
  return self;
}


- (id)initWithMesh:(Mesh *)mesh transform:(glm::mat4)transform
{
  if (self = [super init]) {
    self.transform = transform;
    self.mesh = mesh;
    self.childNodes = [NSMutableArray new];
  }
  return self;
}


- (BoundingBox *)obb
{
  if (_cachedOBB) {
    return _cachedOBB;
  }
  
  BoundingBox *obb = self.mesh.obb ?: [BoundingBox new];

  for (SceneNode *childNode in self.childNodes) {
    obb = [obb bbByAppendingBB:[childNode.obb boundingBoxForTransform:childNode.transform]];
  }
  
  _cachedOBB = obb;
  return obb;
}


- (void)purgeOBB
{
  _cachedOBB = nil;
  [self.childNodes makeObjectsPerformSelector:@selector(purgeOBB)];
}


@end
