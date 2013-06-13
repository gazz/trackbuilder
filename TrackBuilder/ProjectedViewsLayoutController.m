#import "ProjectedViewsLayoutController.h"

#import "ProjectedView.h"

@protocol LayoutBackgroundDelegate
- (void)layoutViews;
@end


@interface LayoutBackgroundView : NSView
@property (weak) id<LayoutBackgroundDelegate> delegate;
@end

@implementation LayoutBackgroundView

- (id)initWithFrame:(NSRect)frameRect delegate:(id<LayoutBackgroundDelegate>)delegate
{
  if (self = [super initWithFrame:frameRect]) {
    _delegate = delegate;
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
  [[NSColor lightGrayColor] set];
  NSRectFill(dirtyRect);
}


-(void)resizeSubviewsWithOldSize:(NSSize)oldSize
{
  [_delegate layoutViews];
}


@end


@interface ProjectedViewsLayoutController () <LayoutBackgroundDelegate>

@end

@implementation ProjectedViewsLayoutController {
  NSArray *_views;
}

- (id)initWithOpenGLContext:(NSOpenGLContext*)glContext
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
      _views = @[
                 [[ProjectedView alloc] initWithFrame:NSZeroRect openGLContext:glContext],
                 [[ProjectedView alloc] initWithFrame:NSZeroRect openGLContext:glContext],
                 [[ProjectedView alloc] initWithFrame:NSZeroRect openGLContext:glContext],
                 [[ProjectedView alloc] initWithFrame:NSZeroRect openGLContext:glContext],
                 ];
    }
    
    return self;
}

- (void)loadView
{
  self.view = [[LayoutBackgroundView alloc] initWithFrame:NSZeroRect delegate:self];
  
  [self layoutViews];
}


- (void)layoutViews
{
  NSSize size = self.view.frame.size;
  NSArray *layouts = [self layoutsForViews:_views.count];
  for (ProjectedView *view in _views) {
    NSInteger index = [_views indexOfObject:view];
    NSRect layout = [layouts[index] rectValue];
    
    // add 1px bezel to avoid overdraw and opengl context switch craze
    CGRect frame = NSMakeRect(layout.origin.x * size.width, layout.origin.y * size.height,
                              layout.size.width * size.width, layout.size.height * size.height);

    if (layout.origin.x != 0) frame.origin.x += 1;
    else frame.size.width -= 1;
    
    if (layout.origin.y != 0) frame.origin.y += 1;
    else frame.size.height -= 1;
    
    
    view.frame = frame;
    //NSLog(@"Adding view at frame: %@", NSStringFromRect(view.frame));
    if (!view.superview) [self.view addSubview:view];
  }
}


- (NSArray *)layoutsForViews:(NSInteger)views
{
  NSArray *layouts = nil;
  switch (views) {
    default:
    case 1:
      layouts = @[[NSValue valueWithRect:NSMakeRect(0, 0, 1, 1)], ];
      break;
    case 2:
      layouts = @[[NSValue valueWithRect:NSMakeRect(0, 0, .5, 1)],
                  [NSValue valueWithRect:NSMakeRect(.5, 0, .5, 1)],
                  ];
      break;
    case 3:
      layouts = @[[NSValue valueWithRect:NSMakeRect(0, 0.33, .5, 1)],
                  [NSValue valueWithRect:NSMakeRect(.5, 0.33, .5, 1)],
                  [NSValue valueWithRect:NSMakeRect(0, 0, 1, .33)],
                  ];
      break;
    case 4:
      layouts = @[[NSValue valueWithRect:NSMakeRect(0, 0, .5, .5)],
                  [NSValue valueWithRect:NSMakeRect(.5, 0, .5, .5)],
                  [NSValue valueWithRect:NSMakeRect(0, .5, .5, .5)],
                  [NSValue valueWithRect:NSMakeRect(.5, .5, .5, .5)],
                  ];
      break;
  }
  return layouts;
}

@end
