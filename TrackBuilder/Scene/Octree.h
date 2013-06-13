#import "Node.h"


@interface Octree : Node {
}

@property NSArray *nodesHitByRay;

- (BOOL)pickNodeWithRay:(glm::vec3)ray origin:(glm::vec3)origin;

- (void)addTriangle:(Triangle)triangle;

@end
