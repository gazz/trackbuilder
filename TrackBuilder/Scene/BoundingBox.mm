#import "BoundingBox.h"
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


- (id)initWithMin:(glm::vec3)min max:(glm::vec3)max
{
  if (self = [super init]) {
    // calc origin & size from min/max
    self.origin = glm::vec3((min.x + max.x) / 2, (min.y + max.y) / 2, (min.z + max.z) / 2);
    self.size = glm::vec3(max.x - min.x, max.y - min.y, max.z - min.z);
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


- (glm::vec3)corner:(NSInteger)corner
{
  // xcomp
  CGFloat xComp = 0.0f;
  switch (corner) {
    case BottomNorthEast:
    case BottomSouthEast:
    case TopNorthEast:
    case TopSouthEast: xComp = 1; break;
    default: xComp = -1; break;
  }
  
  CGFloat yComp = corner < TopNorthEast ? -1.0f : 1.0f;

  CGFloat zComp = 0.0f;
  switch (corner) {
    case BottomSouthEast:
    case BottomSouthWest:
    case TopSouthEast:
    case TopSouthWest: zComp = 1; break;
    default: zComp = -1; break;
  }
  
  return glm::vec3(self.origin.x + self.size.x / 2 * xComp, self.origin.y + self.size.y / 2 * yComp, self.origin.z + self.size.z / 2 * zComp);
}


- (instancetype)boundingBoxForTransform:(glm::mat4)transform
{
  glm::vec3 corners[8];
  for (NSInteger i = 0; i < 8; ++i) {
    corners[i] = transformV3([self corner:i], transform);
  }
  return [[BoundingBox alloc] initWithMin:minPoint(corners, 8) max:maxPoint(corners, 8)];
}


@end


@implementation BoundingBox (Expand)

- (BoundingBox *)bbByAppendingBB:(BoundingBox *)otherBB
{
  glm::vec3 corners[16];
  for (NSInteger i = 0; i < 8; ++i) {
    corners[i] = [self corner:i];
    corners[8 + i] = [otherBB corner:i];
  }
  return [[BoundingBox alloc] initWithMin:minPoint(corners, 16) max:maxPoint(corners, 16)];
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