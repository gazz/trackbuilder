#import <Foundation/Foundation.h>
#import <glm/glm.hpp>
#import <glm/gtc/type_ptr.hpp>


typedef NS_ENUM(NSInteger, BBCorner) {
  BottomNorthEast,
  BottomSouthEast,
  BottomSouthWest,
  BottomNorthWest,
  TopNorthEast,
  TopSouthEast,
  TopSouthWest,
  TopNorthWest
};


@interface BoundingBox : NSObject

@property glm::vec3 origin;
@property glm::vec3 size;

@property (readonly) glm::vec3 min;
@property (readonly) glm::vec3 max;

- (id)initWithOrigin:(glm::vec3)origin size:(glm::vec3)size;
- (id)initWithMin:(glm::vec3)min max:(glm::vec3)max;

- (instancetype)boundingBoxForTransform:(glm::mat4)transform;

@end


@interface BoundingBox (Expand)

- (BoundingBox *)bbByAppendingBB:(BoundingBox *)otherBB;

@end


@interface BoundingBox (Render)

- (void)renderBBWithColor:(NSColor *)color;

@end


