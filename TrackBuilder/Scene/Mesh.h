#import "DHPolygon.h"

@interface Mesh : NSObject

@property NSMutableArray *vertices;  // @[WRAP_V3(glm::vec3), ..]
@property NSMutableArray *polygons;  // @[DHPolygon, ..]

- (void)addTriangleWithV1:(glm::vec3)v1 v2:(glm::vec3)v2 v3:(glm::vec3)v3;

@end