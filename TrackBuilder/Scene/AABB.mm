#import "AABB.h"
#import "utils.h"
#import "RayCast.h"

#import "AppDelegate.h"


@implementation BoundingBox

- (id)initWithOrigin:(glm::vec3)origin size:(glm::vec3)size
{
  if (self = [super init]) {
    self.origin = origin;
    self.size = size;
  }
  return self;
}


- (glm::vec3)min
{
  return glm::vec3(self.origin.x - self.size.x / 2, self.origin.y - self.size.y / 2, self.origin.z - self.size.z / 2);
}


- (glm::vec3)max
{
  return glm::vec3(self.origin.x + self.size.x / 2, self.origin.y + self.size.y / 2, self.origin.z + self.size.z / 2);
}

@end


#import <OpenGL/gl.h>

@implementation BoundingBox (Render)

- (void)renderBBWithColor:(NSColor *)color
{
  glPushAttrib(GL_CURRENT_BIT);

  glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
  glPolygonOffset( -2.0, 1.0 );
  glEnable(GL_POLYGON_OFFSET_LINE);
  
  glBegin(GL_QUADS);
  {
    glColor3f(color.redComponent, color.greenComponent, color.blueComponent);
    wireBox(self.min, self.max);
  }
  glEnd();
  glDisable(GL_POLYGON_OFFSET_LINE);

  glPopAttrib();
}

@end