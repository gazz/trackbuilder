
#import <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#import <glm/gtc/type_ptr.hpp>


#ifndef TrackBuilder_utils_h
#define TrackBuilder_utils_h

NSString *toString(glm::vec3 &vec3);
NSString *toString(glm::quat &quat);

void drawArrowFrom(glm::vec3 from, glm::vec3 to, glm::vec3 color);
void drawArrowFrom(glm::vec3 from, glm::vec3 to, glm::vec3 color, CGFloat width);

void swap(CGFloat &v1, CGFloat &v2);

void drawCircle(float radius, glm::vec3 color);

void daBox(glm::vec3 from, glm::vec3 to);
void wireBox(glm::vec3 from, glm::vec3 to);

#endif
