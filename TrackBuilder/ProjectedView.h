#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, ProjectedViewOrientation) {
  ProjectedViewOrtoTop,
  ProjectedViewOrtoLeft,
  ProjectedViewOrtoFront,
  ProjectedViewOrientationCustom,
  ProjectedViewOrientationsCount
};


@interface ProjectedView : NSOpenGLView

- (id) initWithFrame:(NSRect)frameRect openGLContext:(NSOpenGLContext*)glContext;

@property ProjectedViewOrientation orientation;

@end
