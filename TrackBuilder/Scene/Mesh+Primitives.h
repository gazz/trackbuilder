#import "Mesh.h"


@interface Mesh (Primitives)

+ (id)pyramidWithWidth:(CGFloat)width height:(CGFloat)height;


- (NSArray *)addCylinder:(CGFloat)numMajor numMinor:(CGFloat)numMinor height:(CGFloat)height radius:(CGFloat)radius;
- (NSArray *)addCylinder:(CGFloat)numMajor numMinor:(CGFloat)numMinor height:(CGFloat)height radius:(CGFloat)radius offset:(glm::vec3)offset;


@end
