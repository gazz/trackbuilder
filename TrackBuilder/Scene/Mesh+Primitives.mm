#import "Mesh+Primitives.h"


@implementation Mesh (Primitives)

+ (id)pyramidWithWidth:(CGFloat)width height:(CGFloat)height
{
  Mesh *pyramid = [Mesh new];
  
  CGFloat baseExtension = width / 2;
  
  // East
  [pyramid addTriangleWithV1:glm::vec3(baseExtension, 0, -baseExtension)
                          v2:glm::vec3(0, height, 0)
                          v3:glm::vec3(baseExtension, 0, baseExtension)];

  // South
  [pyramid addTriangleWithV1:glm::vec3(-baseExtension, 0, -baseExtension)
                          v2:glm::vec3(0, height, 0)
                          v3:glm::vec3(baseExtension, 0, -baseExtension)];

  // West
  [pyramid addTriangleWithV1:glm::vec3(-baseExtension, 0, baseExtension)
                          v2:glm::vec3(0, height, 0)
                          v3:glm::vec3(-baseExtension, 0, -baseExtension)];
  
  // North
  [pyramid addTriangleWithV1:glm::vec3(-baseExtension, 0, baseExtension)
                          v2:glm::vec3(0, height, 0)
                          v3:glm::vec3(baseExtension, 0, baseExtension)];

  return pyramid;
}

@end
