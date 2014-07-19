
#import "utils.h"
#import <OpenGL/gl.h>



@implementation RedView

- (void)drawRect:(NSRect)dirtyRect
{
  [[NSColor blueColor] set];
  NSRectFill(self.bounds);
  [[NSColor redColor] set];
  NSRectFill(NSInsetRect(self.bounds, 3, 3));
}

@end

NSString *toString(glm::vec3 &vec3)
{
  return [NSString stringWithFormat:@"(%.2f, %.2f, %.2f)", vec3.x, vec3.y, vec3.z];
}

NSString *toString(glm::quat &quat)
{
  glm::vec3 angles = glm::eulerAngles(quat);
  return [NSString stringWithFormat:@"[%.2f, %.2f, %.2f, %.2f]:%@", quat.x, quat.y, quat.z, quat.w, toString(angles)];
}


// draws arrow in 3d space, from -> to with the specified color
void drawArrowFrom(glm::vec3 from, glm::vec3 to, glm::vec3 color, CGFloat width)
{
  glLoadIdentity();
  glColor3f(color.x, color.y, color.z);
  glLineWidth(width);
  
  glBegin(GL_LINES);
  {
    glVertex3f(from.x, from.y, from.z);
    glVertex3f(to.x, to.y, to.z);
    
  }
  glEnd();
  
  glLineWidth(1);
}

void drawArrowFrom(glm::vec3 from, glm::vec3 to, glm::vec3 color)
{
  drawArrowFrom(from, to, color, 1);
}


void swap(CGFloat &v1, CGFloat &v2)
{
  CGFloat tmp = v1;
  v1 = v2;
  v2 = tmp;
}

void drawCircle(float radius, glm::vec3 color)
{
  float x,y;
  glBegin(GL_LINES);
  glColor3f(color.x, color.y, color.z);
  
  x = (float)radius * cos(359 * M_PI/180.0f);
  y = (float)radius * sin(359 * M_PI/180.0f);
  for(int j = 0; j < 360; j++)
  {
    glVertex2f(x,y);
    x = (float)radius * cos(j * M_PI/180.0f);
    y = (float)radius * sin(j * M_PI/180.0f);
    glVertex2f(x,y);
  }
  glEnd();
}


void wireBox(glm::vec3 from, glm::vec3 to)
{
  glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
  daBox(from, to);
  glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
}


void daBox(glm::vec3 from, glm::vec3 to)
{
  // 6 quads
  glBegin(GL_QUADS);
  {
    // from x
    glVertex3f(from.x, from.y, from.z);
    glVertex3f(from.x, to.y, from.z);
    glVertex3f(from.x, to.y, to.z);
    glVertex3f(from.x, from.y, to.z);

    // to x
    glVertex3f(to.x, from.y, from.z);
    glVertex3f(to.x, to.y, from.z);
    glVertex3f(to.x, to.y, to.z);
    glVertex3f(to.x, from.y, to.z);

    // from y
    glVertex3f(from.x, from.y, from.z);
    glVertex3f(to.x, from.y, from.z);
    glVertex3f(to.x, from.y, to.z);
    glVertex3f(from.x, from.y, to.z);

    // to y
    glVertex3f(from.x, to.y, from.z);
    glVertex3f(to.x, to.y, from.z);
    glVertex3f(to.x, to.y, to.z);
    glVertex3f(from.x, to.y, to.z);
    
    // from z
    glVertex3f(from.x, to.y, from.z);
    glVertex3f(to.x, to.y, from.z);
    glVertex3f(to.x, from.y, from.z);
    glVertex3f(from.x, from.y, from.z);

    // to z
    glVertex3f(from.x, to.y, to.z);
    glVertex3f(to.x, to.y, to.z);
    glVertex3f(to.x, from.y, to.z);
    glVertex3f(from.x, from.y, to.z);
  }
  glEnd();
}


glm::vec3 minPoint(glm::vec3 *vertices, int count)
{
  glm::vec3 minPoint = vertices[0];
  for (int i = 1; i < count; ++i) {
    glm::vec3 v = vertices[i];
    minPoint.x = fmin(v.x, minPoint.x);
    minPoint.y = fmin(v.y, minPoint.y);
    minPoint.z = fmin(v.z, minPoint.z);
  }
  return minPoint;
}


glm::vec3 maxPoint(glm::vec3 *vertices, int count)
{
  glm::vec3 maxPoint = vertices[0];
  for (int i = 1; i < count; ++i) {
    glm::vec3 v = vertices[i];
    maxPoint.x = fmax(v.x, maxPoint.x);
    maxPoint.y = fmax(v.y, maxPoint.y);
    maxPoint.z = fmax(v.z, maxPoint.z);
  }
  return maxPoint;
}


glm::vec3 transformV3(glm::vec3 v, glm::mat4 m)
{
  glm::vec4 transformedCorner = m * glm::vec4(v.x, v.y, v.z, 1.0f);
  return glm::vec3(transformedCorner.x, transformedCorner.y, transformedCorner.z);
}


