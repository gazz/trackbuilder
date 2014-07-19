#import <Foundation/Foundation.h>
#import <glm/glm.hpp>
#import <glm/gtc/type_ptr.hpp>

@interface NSValue (vec3)
+ (id)valueWithVec3:(glm::vec3)vec3;
- (glm::vec3)vec3Value;
@end

#define WRAP_V3(v) [NSValue valueWithVec3:v]
#define UNWRAP_V3(v) [v vec3Value]

