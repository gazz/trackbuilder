#import <Foundation/Foundation.h>

#import <glm/glm.hpp>
#import <glm/gtc/type_ptr.hpp>

@class Mesh;
@class BoundingBox;

@interface SceneNode : NSObject

@property glm::mat4x4 transform;
@property Mesh *mesh;

@property (readonly) BoundingBox *obb;

@property NSMutableArray *childNodes;

- (id)initWithMesh:(Mesh *)mesh;

- (void)purgeOBB;

@end
