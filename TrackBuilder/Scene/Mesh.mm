#import "Mesh.h"
#import "NSValue+vec3.h"


BOOL equalVerts(glm::vec3 &v1, glm::vec3 &v2) {
  return (v1.x == v2.x && v1.y == v2.y && v1.z == v2.z);
}


@implementation Mesh

- (id)init
{
  if (self = [super init]) {
    _origin = glm::vec3(0);
    _vertices = [NSMutableArray array];
    _polygons = [NSMutableArray array];
  }
  return self;
}


- (void)addTriangleWithV1:(glm::vec3)v1 v2:(glm::vec3)v2 v3:(glm::vec3)v3
{
  // try to find indexes for vertices
  NSInteger v1Index = -1, v2Index = -1, v3Index = -1;
  for (int i = 0; i < _vertices.count; ++i) {
    glm::vec3 vertex = [[_vertices objectAtIndex:i] vec3Value];
    if (v1Index < 0 && equalVerts(vertex, v1)) v1Index = i;
    if (v2Index < 0 && equalVerts(vertex, v2)) v2Index = i;
    if (v3Index < 0 && equalVerts(vertex, v3)) v3Index = i;
  }
  
  if (v1Index < 0) {
    v1Index = _vertices.count;
    [_vertices addObject:WRAP_V3(v1)];
  }
  if (v2Index < 0) {
    v2Index = _vertices.count;
    [_vertices addObject:WRAP_V3(v2)];
  }
  if (v3Index < 0) {
    v3Index = _vertices.count;
    [_vertices addObject:WRAP_V3(v3)];
  }
  [_polygons addObject:[[DHPolygon alloc] initWithIndices:v1Index i2:v2Index i3:v3Index]];
  
  [self recalcOBB];
}


- (void)recalcOBB
{
  glm::vec3 minPoint = UNWRAP_V3([_vertices firstObject]);
  glm::vec3 maxPoint = UNWRAP_V3([_vertices firstObject]);
  for (NSValue *vertice in _vertices) {
    glm::vec3 v = UNWRAP_V3(vertice);
    minPoint.x = fmin(v.x, minPoint.x);
    minPoint.y = fmin(v.y, minPoint.y);
    minPoint.z = fmin(v.z, minPoint.z);
    maxPoint.x = fmax(v.x, maxPoint.x);
    maxPoint.y = fmax(v.y, maxPoint.y);
    maxPoint.z = fmax(v.z, maxPoint.z);
  }
  glm::vec3 size = glm::vec3(maxPoint.x - minPoint.x, maxPoint.y - minPoint.y, maxPoint.z - minPoint.z);
  glm::vec3 origin = glm::vec3(minPoint.x + size.x / 2, minPoint.y + size.y / 2, minPoint.z + size.z / 2);
  _obb = [[BoundingBox alloc] initWithOrigin:origin size:size];
}


@end

