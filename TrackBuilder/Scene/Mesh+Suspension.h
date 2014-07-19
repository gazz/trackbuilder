#import "Mesh.h"

@interface Mesh (Suspension)

+ (instancetype)springWithLength:(CGFloat)length coils:(CGFloat)coils thickness:(CGFloat)thickness;
+ (instancetype)shockWithLength:(CGFloat)length thickness:(CGFloat)thickness;
+ (instancetype)bar:(CGFloat)length thickness:(CGFloat)thickness;
+ (instancetype)spindle:(CGFloat)length;

@end
