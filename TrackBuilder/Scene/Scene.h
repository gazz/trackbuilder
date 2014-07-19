#import <glm/glm.hpp>
#import <glm/gtc/type_ptr.hpp>
#import "Mesh.h"
#import "SceneNode.h"


extern NSString * const SceneNeedsRenderNotification;

@interface Scene : NSObject

@property SceneNode *rootNode;

@property SceneNode *pickedNode;
@property DHPolygon *pickedPolygon;

- (void)resetScene;

@end


@interface Scene (RayCast)
- (BOOL)pickNodeWithRay:(glm::vec3)ray origin:(glm::vec3)origin;
@end


@interface Scene (Generation)
- (void)generateTerrain:(CGSize)size;
@end


@interface Scene (Render)
- (void)renderNodes;
- (void)renderBounds;
@end