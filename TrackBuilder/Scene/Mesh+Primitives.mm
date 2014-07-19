#import "Mesh+Primitives.h"
#import "NSValue+vec3.h"


@implementation Mesh (Primitives)

+ (id)pyramidWithWidth:(CGFloat)width height:(CGFloat)height
{
  Mesh *pyramid = [Mesh new];
  
  CGFloat baseExtension = width / 2;
  
  glm::vec3 color = glm::vec3(.5, .2, .2);
  
  // East
  [pyramid addTriangleWithV1:glm::vec3(baseExtension, 0, -baseExtension)
                          v2:glm::vec3(0, height, 0)
                          v3:glm::vec3(baseExtension, 0, baseExtension)].color = color;

  // South
  [pyramid addTriangleWithV1:glm::vec3(-baseExtension, 0, -baseExtension)
                          v2:glm::vec3(0, height, 0)
                          v3:glm::vec3(baseExtension, 0, -baseExtension)].color = color;

  // West
  [pyramid addTriangleWithV1:glm::vec3(-baseExtension, 0, baseExtension)
                          v2:glm::vec3(0, height, 0)
                          v3:glm::vec3(-baseExtension, 0, -baseExtension)].color = color;
  
  // North
  [pyramid addTriangleWithV1:glm::vec3(-baseExtension, 0, baseExtension)
                          v2:glm::vec3(0, height, 0)
                          v3:glm::vec3(baseExtension, 0, baseExtension)].color = color;

  
  return pyramid;
}


- (NSArray *)addCylinder:(CGFloat)numMajor numMinor:(CGFloat)numMinor height:(CGFloat)height radius:(CGFloat)radius
{
  return [self addCylinder:numMajor numMinor:numMinor height:height radius:radius offset:glm::vec3()];
}


- (NSArray *)addCylinder:(CGFloat)numMajor numMinor:(CGFloat)numMinor height:(CGFloat)height radius:(CGFloat)radius offset:(glm::vec3)offset
{
  NSMutableArray *polys = [NSMutableArray array];
  NSMutableArray *sideVertices = [NSMutableArray array];
  double majorStep = height / numMajor;
  double minorStep = 2.0 * M_PI / numMinor;
  int i, j;
  
  for (i = 0; i < numMajor; ++i) {
    GLfloat z0 = 0.5 * height - i * majorStep;
    GLfloat z1 = z0 - majorStep;
    
    glm::vec3 lastVertice;
    
    for (j = 0; j <= numMinor; ++j) {
      double a = j * minorStep;
      GLfloat x = radius * cos(a);
      GLfloat y = radius * sin(a);

      [sideVertices addObject:WRAP_V3(glm::vec3(offset.x + x, offset.y + z0, offset.z + y))];
      [sideVertices addObject:WRAP_V3(glm::vec3(offset.x + x, offset.y + z1, offset.z + y))];
    }
  }
  
  // ends
  for (i = 0; i <= numMinor; ++i) {
    double a = i * minorStep;
    double nextA = (i + 1) * minorStep;
    CGFloat bottom = offset.y - height / 2;
    CGFloat top = offset.y + height / 2;
    [polys addObject:[self addTriangleWithV1:glm::vec3(offset.x + radius * sin(a), bottom, offset.z + radius * cos(a))
                                          v2:glm::vec3(offset.x + radius * sin(nextA), bottom, offset.z + radius * cos(nextA))
                                          v3:glm::vec3(offset.x, bottom, offset.z)]];
    [polys addObject:[self addTriangleWithV1:glm::vec3(offset.x + radius * sin(a), top, offset.z + radius * cos(a))
                                          v2:glm::vec3(offset.x + radius * sin(nextA), top, offset.z + radius * cos(nextA))
                                          v3:glm::vec3(offset.x, top, offset.z)]];
  }

  
  for (int i=0; i< sideVertices.count - 2; i++) {
    [polys addObject:[self addTriangleWithV1:UNWRAP_V3(sideVertices[i])
         v2:UNWRAP_V3(sideVertices[i + 1])
         v3:UNWRAP_V3(sideVertices[i + 2])]];
  }
  return polys;
}

@end
