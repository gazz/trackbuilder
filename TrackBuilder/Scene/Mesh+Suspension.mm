#import "Mesh+Suspension.h"


@implementation Mesh (Suspension)

+ (instancetype)springWithLength:(CGFloat)length coils:(CGFloat)coils thickness:(CGFloat)thickness
{
  Mesh *mesh = [Mesh new];
  return mesh;
}


+ (instancetype)shockWithLength:(CGFloat)length thickness:(CGFloat)thickness
{
  Mesh *mesh = [Mesh new];
  
  CGFloat ratio = .6;
  
  [[mesh addCylinder:1 numMinor:10 height:length * ratio radius:thickness offset:glm::vec3(0, length * (1 - ratio) / 2, 0)]
      enumerateObjectsUsingBlock:^(DHPolygon *poly, NSUInteger idx, BOOL *stop) {
        poly.color = glm::vec3(.9, .6, .1);
      }];

  [[mesh addCylinder:1 numMinor:10 height:length * (1 - ratio) radius:thickness / 2 offset:glm::vec3(0, -length * ratio / 2 , 0)]
      enumerateObjectsUsingBlock:^(DHPolygon *poly, NSUInteger idx, BOOL *stop) {
        poly.color = glm::vec3(.9, .9, .9);
      }];
  
  mesh.name = @"Shock Absorber";
  
  return mesh;
}


+ (instancetype)bar:(CGFloat)length thickness:(CGFloat)thickness
{
  Mesh *mesh = [Mesh new];
  [mesh addCylinder:1 numMinor:10 height:length radius:thickness / 2];
  for (DHPolygon *poly in mesh.polygons) {
    poly.color = glm::vec3(.4, .4, 1);
  }
  
  mesh.name = @"Bar";

  return mesh;
}


+ (instancetype)hub:(CGFloat)diameter thickness:(CGFloat)thickness
{
  Mesh *mesh = [Mesh new];
  
  // inner circle
  [[mesh addCylinder:1 numMinor:20 height:thickness * .15 radius:diameter/2.5]
      enumerateObjectsUsingBlock:^(DHPolygon *poly, NSUInteger idx, BOOL *stop) {
        poly.color = glm::vec3(.3, .3, .3);
      }];

  [[mesh addCylinder:1 numMinor:20 height:thickness * .2 radius:diameter/2 offset:glm::vec3(0, thickness * .17, 0)]
      enumerateObjectsUsingBlock:^(DHPolygon *poly, NSUInteger idx, BOOL *stop) {
        poly.color = glm::vec3(.3, .3, .3);
      }];

  [[mesh addCylinder:1 numMinor:20 height:thickness * .2 radius:diameter/2.2 offset:glm::vec3(0, thickness * .3, 0)]
      enumerateObjectsUsingBlock:^(DHPolygon *poly, NSUInteger idx, BOOL *stop) {
        poly.color = glm::vec3(.5, .5, .5);
      }];

  [[mesh addCylinder:1 numMinor:20 height:thickness * .5 radius:diameter/5 offset:glm::vec3(0, thickness * .4, 0)]
      enumerateObjectsUsingBlock:^(DHPolygon *poly, NSUInteger idx, BOOL *stop) {
        poly.color = glm::vec3(.7, .7, .7);
      }];
  
  // wheel nuts
  int numBolts = 5;
  double minorStep = 2.0 * M_PI / numBolts;
  for (int i = 0; i <= numBolts; ++i) {
    double a = i * minorStep;
    GLfloat x = diameter / 2 * .7 * cos(a);
    GLfloat z = diameter / 2 * .7 * sin(a);
    [[mesh addCylinder:1 numMinor:10 height:thickness * .4 radius:thickness * .07 offset:glm::vec3(x, thickness * .6, z)]
        enumerateObjectsUsingBlock:^(DHPolygon *poly, NSUInteger idx, BOOL *stop) {
          poly.color = glm::vec3(.2, .2, .2);
        }];
  }
  
  mesh.name = @"5 Bolt Hub";

  return mesh;
}


@end

