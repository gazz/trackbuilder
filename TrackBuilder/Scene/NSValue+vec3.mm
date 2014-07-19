#import "NSValue+vec3.h"

@implementation NSValue (vec3)

+ (id)valueWithVec3:(glm::vec3)vec3;
{
  return [NSValue value:&vec3 withObjCType:@encode(glm::vec3)];
}

- (glm::vec3)vec3Value;
{
  glm::vec3 vec3; [self getValue:&vec3]; return vec3;
}

@end
