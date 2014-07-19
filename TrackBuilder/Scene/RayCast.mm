#import "RayCast.h"
#import "Utils.h"

CGFloat triangle_intersection(const glm::vec3 V1,  // Triangle vertices
                              const glm::vec3 V2,
                              const glm::vec3 V3,
                              const glm::vec3 O,  //Ray origin
                              const glm::vec3 D);  //Ray direction


CGFloat rayDistanceToBox(glm::vec3 ray, glm::vec3 origin, glm::vec3 boxMin, glm::vec3 boxMax)
{
  
  // the basic check if origin is within the box, then return hit
  glm::vec3 min = boxMin;
  glm::vec3 max = boxMax;
  
  CGFloat tmin, tmax, tymin, tymax, tzmin, tzmax;
  
  // calc base min & max
  tmin = (min.x - origin.x) / ray.x;
  tmax = (max.x - origin.x) / ray.x;
  if (tmin > tmax) swap(tmin, tmax);
    
    // calc z min & max
    tzmin = (min.z - origin.z) / ray.z;
    tzmax = (max.z - origin.z) / ray.z;
    if (tzmin > tzmax) swap(tzmin, tzmax);
      
      if (tmin > tzmax || tzmin > tmax) return -1;
  
  // calc 3rd dimension
  if (tzmin > tmin) tmin = tzmin;
    if (tzmax < tmax) tmax = tzmax;
      
      tymin = (min.y - origin.y) / ray.y;
      tymax = (max.y - origin.y) / ray.y;
      if (tymin > tymax) swap(tymin, tymax);
        
        if (tmin > tymax || tymin > tmax) return -1;
  
  //  NSLog(@"tmin: %f, tmax: %f", tmin, tmax);
  if (tmax < 0) return -1;
  
  ;
  // calculate distance and validate if within range
  //  if (tzmin > tmin) tmin = tzmin;
  //  if (tzmax < tmax) tmax = tzmax;
  //
  //  if (tmin > maxDistance) || tmax < minDistance) return false;
  //
  //  if (r.tmin < tmin) r.tmin = tmin;
  //  if (r.tmax > tmax) r.tmax = tmax;
  
  //
  //  CGFloat tMinZ = (bounds.min.z - origin.z) / ray.z;
  //  CGFloat tMaxZ = (bounds.max.z - origin.z) / ray.z;
  //  if (tMinZ > tMaxZ) swap(tMinZ, tMinZ);
  //
  
  return glm::length(glm::vec3(tmax, tymax, tzmax));
}


CGFloat rayDistanceToTriangle(glm::vec3 ray, glm::vec3 origin, glm::vec3 vertex1, glm::vec3 vertex2, glm::vec3 vertex3)
{
  // try to hit bb first
  glm::vec3 vertexArray[] = {vertex1, vertex2, vertex3};
  CGFloat distanceToBB = rayDistanceToBox(ray, origin, minPoint(vertexArray, 3), maxPoint(vertexArray, 3));
  if (distanceToBB < 0) {
    return -1;
  }
  // try more advanced hitting
  return triangle_intersection(vertex1, vertex2, vertex3, origin, ray);
}


CGFloat rayDistanceToQuad(glm::vec3 ray, glm::vec3 origin, glm::vec3 vertex1, glm::vec3 vertex2, glm::vec3 vertex3, glm::vec3 vertex4)
{
  glm::vec3 vertexArray[] = {vertex1, vertex2, vertex3, vertex4};
  CGFloat distanceToBB = rayDistanceToBox(ray, origin, minPoint(vertexArray, 4), maxPoint(vertexArray, 4));
  if (distanceToBB < 0) {
    return -1;
  }
  // try more advanced hitting
  return distanceToBB;
}


#define EPSILON 0.000001
#define CROSS(dest, v1, v2) \
  dest.x = v1.y * v2.z - v1.z * v2.y; \
  dest.y = v1.z * v2.x - v1.x * v2.z; \
  dest.z = v1.x * v2.y - v1.y * v2.x;

#define DOT(v1, v2) (v1.x * v2.x + v1.y * v2.y + v1.z * v2.z)

#define SUB(dest, v1, v2) \
  dest.x = v1.x - v2.x; \
  dest.y = v1.y - v2.y; \
  dest.z = v1.z - v2.z;

CGFloat triangle_intersection(const glm::vec3 V1,  // Triangle vertices
                              const glm::vec3 V2,
                              const glm::vec3 V3,
                              const glm::vec3 O,  //Ray origin
                              const glm::vec3 D)  //Ray direction
{
  glm::vec3 e1, e2;  //Edge1, Edge2
  glm::vec3 P, Q, T;
  float det, inv_det, u, v;
  float t;
  
  //Find vectors for two edges sharing V1
  SUB(e1, V2, V1);
  SUB(e2, V3, V1);
  //Begin calculating determinant - also used to calculate u parameter
  CROSS(P, D, e2);
  //if determinant is near zero, ray lies in plane of triangle
  det = DOT(e1, P);
  //NOT CULLING
  if(det > -EPSILON && det < EPSILON) return -1;
  inv_det = 1.f / det;
  
  //calculate distance from V1 to ray origin
  SUB(T, O, V1);
  
  //Calculate u parameter and test bound
  u = DOT(T, P) * inv_det;
  //The intersection lies outside of the triangle
  if(u < 0.f || u > 1.f) return -1;
  
  //Prepare to test v parameter
  CROSS(Q, T, e1);
  
  //Calculate V parameter and test bound
  v = DOT(D, Q) * inv_det;
  //The intersection lies outside of the triangle
  if(v < 0.f || u + v  > 1.f) return -1;
  
  t = DOT(e2, Q) * inv_det;
  
  if(t > EPSILON) { //ray intersection
    return t;
  }
  
  // No hit, no win
  return -1;
}

