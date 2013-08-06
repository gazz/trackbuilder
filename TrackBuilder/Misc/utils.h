
#import <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#import <glm/gtc/type_ptr.hpp>


#ifndef TrackBuilder_utils_h
#define TrackBuilder_utils_h

NSString *toString(glm::vec3 &vec3);
NSString *toString(glm::quat &quat);


typedef struct {
  CGFloat distance;
  glm::quat rotation;
  glm::vec3 center;
} ProjectionViewCamera;

typedef struct {
  glm::vec3 origin;
  glm::vec3 direction;
} Ray;


void drawArrowFrom(glm::vec3 from, glm::vec3 to, glm::vec3 color);
void drawArrowFrom(glm::vec3 from, glm::vec3 to, glm::vec3 color, CGFloat width);

void swap(CGFloat &v1, CGFloat &v2);

void drawCircle(float radius, glm::vec3 color);

void daBox(glm::vec3 from, glm::vec3 to);
void wireBox(glm::vec3 from, glm::vec3 to);

@interface RedView : NSView
@end


#endif
