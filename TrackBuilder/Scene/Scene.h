
#import <glm/glm.hpp>
#import <glm/gtc/type_ptr.hpp>
#include <glm/gtc/matrix_transform.hpp>

#import "Octree.h"
#import "Mesh.h"

extern NSString * const SceneNeedsRenderNotification;

@interface Scene : NSObject

@property Octree *octree;

@property NSMutableDictionary *meshes;

- (void)generateTerrain:(CGSize)size;

- (void)renderBounds;

- (void)renderMeshes;

- (BOOL)pickNodeWithRay:(glm::vec3)ray origin:(glm::vec3)origin;

@end
