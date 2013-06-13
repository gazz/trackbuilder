#import "StatusView.h"

const CGFloat StatusBarHeight = 20;

@interface StatusView ()

@end

@implementation StatusView

- (id) initWithFrame:(NSRect)frameRect
{
  if (self = [super initWithFrame:frameRect]) {
    self.frame = NSMakeRect(frameRect.origin.x, frameRect.origin.y - StatusBarHeight,
                            frameRect.size.width, StatusBarHeight);

    // add listener for notifications
  }
  return self;
}

- (void) drawRect:(NSRect)dirtyRect
{
  [[NSColor whiteColor] set];
  NSRectFill(dirtyRect);
  
  NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
  [style setAlignment:NSCenterTextAlignment];
  NSDictionary *attr = [NSDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
  
  [[NSColor darkGrayColor] set];
  [@"This is the status bar" drawWithRect:NSInsetRect(self.bounds, 0, 5) options:NSStringDrawingOneShot attributes:attr];

  [[NSColor grayColor] set];
  NSRectFill(NSMakeRect(0, NSHeight(self.bounds)-1, self.bounds.size.width, 1));
}

@end
