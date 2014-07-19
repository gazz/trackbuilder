#import "DHPolygon.h"


@implementation DHPolygon

- (id)init
{
  if (self = [super init]) {
    self.color = glm::vec3(.7, .7, .7);
  }
  return self;
}


-(id)initWithIndices:(NSInteger)i1 i2:(NSInteger)i2 i3:(NSInteger)i3
{
  if (self = [self init]) {
    // triangle
    _indexes = @[@(i1),@(i2),@(i3)];
  }
  return self;
}


-(id)initWithIndices:(NSInteger)i1 i2:(NSInteger)i2 i3:(NSInteger)i3 i4:(NSInteger)i4
{
  if (self = [self init]) {
    // quad
    _indexes = @[@(i1),@(i2),@(i3),@(i4)];
  }
  return self;
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"%@", _indexes];
}

@end
