//
//  ToolbarViewController.m
//  TrackBuilder
//
//  Created by Janis Dancis on 5/21/13.
//  Copyright (c) 2013 digihaze. All rights reserved.
//

#import "ToolbarViewController.h"
#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

#define COLORMAINTOP [NSColor colorWithDeviceRed:0.886 green:0.886 blue:0.886 alpha:1.00]
#define COLORMAINSTART [NSColor colorWithDeviceRed:0.812 green:0.812 blue:0.812 alpha:1.00]
#define COLORMAINEND [NSColor colorWithDeviceRed:0.643 green:0.643 blue:0.643 alpha:1.00]
#define COLORMAINBOTTOM [NSColor colorWithDeviceRed:0.443 green:0.443 blue:0.443 alpha:1.00]
#define COLORMAINSTATUSTOP [NSColor colorWithDeviceRed:0.549 green:0.549 blue:0.549 alpha:1.00]

@interface DHButton : NSButton {
  void (^_action)(DHButton *);
}
- (void)addAction:(void (^)(DHButton *button))action;
@end

@implementation DHButton

- (void)addAction:(void (^)(DHButton *button))action;
{
  _action = action;
  [self setTarget:self];
  [self setAction:@selector(handleClickWithBlock:)];
}

- (void)handleClickWithBlock:(id)sender
{
  _action(sender);
}

@end


@interface ToolbarContainerView : NSView
@end

@implementation ToolbarContainerView

- (void)drawRect:(NSRect)dirtyRect
{
  NSRect drawingRect = [self bounds];
  [NSGraphicsContext saveGraphicsState];
  
//  NSBezierPath *clipPath = [NSBezierPath roundRect:drawingRect withRadius:15 minXminY:YES maxXminY:NO minXmaxY:NO maxXmaxY:NO];
//  [clipPath addClip];
//  
  NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:COLORMAINSTART
                                                       endingColor:COLORMAINEND];
  [gradient drawInRect:drawingRect angle:-90];
  
  [COLORMAINSTATUSTOP set];
  NSRectFill(NSMakeRect(0.0, NSMaxY(drawingRect), NSWidth(drawingRect), 1.0));
  
  [COLORMAINTOP set];
  NSRectFill(NSMakeRect(0.0, NSMaxY(drawingRect), NSWidth(drawingRect), 1.0));

  [COLORMAINBOTTOM set];
  NSRectFill(NSMakeRect(0.0, 0, NSWidth(drawingRect), 1.0));
  
  
  [NSGraphicsContext restoreGraphicsState];
}

@end

@interface ToolbarViewController ()

@end

@implementation ToolbarViewController

- (void)loadView
{
  self.view = [[ToolbarContainerView alloc] initWithFrame:NSMakeRect(0, 0, 0, 40)];;

  [self addToolbarButton:[NSString stringWithFormat:@"Toggle Debug: %ld", DHApp.debugMode] action:^(DHButton *button) {
    // toggle debug
    [DHApp rotateDebugMode];
    button.title = [NSString stringWithFormat:@"Toggle Debug: %ld", DHApp.debugMode];
  }];
  
  [self addToolbarButton:@"Generate Terrain" action:^(DHButton *button) {
    [DHApp.scene generateTerrain:CGSizeMake(1, 1)];
  }];
  
  [self addToolbarButton:@"Decrease detail" action:^(DHButton *button) {
    [[NSNotificationCenter defaultCenter] postNotificationName:SceneNeedsRenderNotification object:nil];
  }];
  [self addToolbarButton:@"Increase detail" action:^(DHButton *button) {
    [[NSNotificationCenter defaultCenter] postNotificationName:SceneNeedsRenderNotification object:nil];
  }];


}

- (void) addToolbarButton:(NSString*)title action:(void (^)(DHButton *button))action
{
  NSView *lastView = [self.view.subviews lastObject];
  CGFloat offsetX = 10, horPadding = 10, verPadding = 10;
  if (lastView) {
    offsetX = lastView.frame.origin.x + lastView.frame.size.width + horPadding;
  }
  
  DHButton *button = [[DHButton alloc] initWithFrame:NSZeroRect];
  button.title = title;
  [button addAction:action];
  [button sizeToFit];
  CGRect frame = button.frame;
  frame.origin = CGPointMake(offsetX, verPadding);
  button.frame = frame;
  [self.view addSubview:button];
}




@end
