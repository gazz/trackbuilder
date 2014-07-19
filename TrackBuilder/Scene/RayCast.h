#import <glm/glm.hpp>
#import <glm/gtc/type_ptr.hpp>

CGFloat rayDistanceToBox(glm::vec3 ray, glm::vec3 origin, glm::vec3 boxMin, glm::vec3 boxMax);


CGFloat rayDistanceToTriangle(glm::vec3 ray, glm::vec3 origin, glm::vec3 vertex1, glm::vec3 vertex2, glm::vec3 vertex3);
CGFloat rayDistanceToQuad(glm::vec3 ray, glm::vec3 origin, glm::vec3 vertex1, glm::vec3 vertex2, glm::vec3 vertex3, glm::vec3 vertex4);