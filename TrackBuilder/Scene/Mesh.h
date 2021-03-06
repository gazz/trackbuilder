#import "DHPolygon.h"
#import "BoundingBox.h"


@interface Mesh : NSObject

@property NSString *name;

@property glm::vec3 origin;

@property (readonly) BoundingBox *obb;

@property NSMutableArray *vertices;  // @[WRAP_V3(glm::vec3), ..]
@property NSMutableArray *polygons;  // @[DHPolygon, ..]

- (DHPolygon *)addTriangleWithV1:(glm::vec3)v1 v2:(glm::vec3)v2 v3:(glm::vec3)v3;

@end


#import "Mesh+Primitives.h"

#import "Mesh+Suspension.h"
