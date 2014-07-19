#import <glm/glm.hpp>
#import <glm/gtc/type_ptr.hpp>
#include <glm/gtc/matrix_transform.hpp>

@interface DHPolygon : NSObject
@property NSArray *indexes;
@property glm::vec3 color;
-(id)initWithIndices:(NSInteger)i1 i2:(NSInteger)i2 i3:(NSInteger)i3;
-(id)initWithIndices:(NSInteger)i1 i2:(NSInteger)i2 i3:(NSInteger)i3 i4:(NSInteger)i4;
@end

