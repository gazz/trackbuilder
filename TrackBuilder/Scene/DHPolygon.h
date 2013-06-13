#import <glm/glm.hpp>
#import <glm/gtc/type_ptr.hpp>
#include <glm/gtc/matrix_transform.hpp>

@interface NSValue (vec3)
+ (id)valueWithVec3:(glm::vec3)vec3;
- (glm::vec3)vec3Value;
@end

#define WRAP_V3(v) [NSValue valueWithVec3:v]
#define UNWRAP_V3(v) [v vec3Value]

@interface DHPolygon : NSObject
@property NSArray *indexes;
-(id)initWithIndices:(NSInteger)i1 i2:(NSInteger)i2 i3:(NSInteger)i3;
-(id)initWithIndices:(NSInteger)i1 i2:(NSInteger)i2 i3:(NSInteger)i3 i4:(NSInteger)i4;
@end

