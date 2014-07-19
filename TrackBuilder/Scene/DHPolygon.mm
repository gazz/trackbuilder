#import "DHPolygon.h"


@implementation DHPolygon

-(id)initWithIndices:(NSInteger)i1 i2:(NSInteger)i2 i3:(NSInteger)i3
{
  if (self = [super init]) {
    // triangle
    _indexes = @[@(i1),@(i2),@(i3)];
  }
  return self;
}


-(id)initWithIndices:(NSInteger)i1 i2:(NSInteger)i2 i3:(NSInteger)i3 i4:(NSInteger)i4
{
  if (self = [super init]) {
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
