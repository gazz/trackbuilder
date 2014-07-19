#import <Foundation/Foundation.h>
#import <glm/glm.hpp>
#import <glm/gtc/type_ptr.hpp>



@interface BoundingBox : NSObject

@property glm::vec3 origin;
@property glm::vec3 size;

@property (readonly) glm::vec3 min;
@property (readonly) glm::vec3 max;

- (id)initWithOrigin:(glm::vec3)origin size:(glm::vec3)size;

@end

@interface BoundingBox (Render)

- (void)renderBBWithColor:(NSColor *)color;

@end


