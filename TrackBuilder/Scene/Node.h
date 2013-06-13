
#import <glm/glm.hpp>
#import <glm/gtc/type_ptr.hpp>
#include <glm/gtc/matrix_transform.hpp>

struct {
  glm::vec3 min;
  glm::vec3 max;
} typedef AABB;

class Triangle {
public:
  glm::vec3 v1, v2, v3;
  glm::vec3 n;
  Triangle() {}
  Triangle(glm::vec3 v1, glm::vec3 v2, glm::vec3 v3, glm::vec3 n) : v1(v1), v2(v2), v3(v3), n(n){}
};


struct {
  CGFloat distance;
  id node;
} typedef NodePick;

@interface Node : NSObject {
}


@property Node *parentNode;
@property NSMutableArray *childNodes;
@property glm::vec3 origin;
@property glm::vec3 size;
@property (readonly) AABB aabbWorld;
@property (readonly) glm::vec3 worldOrigin;

- (id)initWithParent:(Node*)node origin:(glm::vec3)origin size:(glm::vec3)size;

- (void)renderBounds;
- (void)renderActiveBoundsInWorld;

- (void)increaseDetail;

- (NSArray*)nodesHitByRay:(glm::vec3)ray origin:(glm::vec3)origin;

- (NodePick)pickClosestNode:(glm::vec3)ray origin:(glm::vec3)origin;

- (CGFloat)rayDistanceToNode:(glm::vec3)ray origin:(glm::vec3)origin;

@end

