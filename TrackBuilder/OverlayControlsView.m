//
//  OverlayControlsView.m
//  TrackBuilder
//
//  Created by Janis Dancis on 6/21/13.
//  Copyright (c) 2013 digihaze. All rights reserved.
//

#import "OverlayControlsView.h"

@interface RedView2 : NSView
@end

@implementation RedView2

- (void)drawRect:(NSRect)dirtyRect
{
  [[NSColor blueColor] set];
  NSRectFill(self.bounds);
  [[NSColor redColor] set];
  NSRectFill(NSInsetRect(self.bounds, 3, 3));
}

@end

@implementation OverlayControlsView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
      _basicTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(5, 0, 400, 20)];
      [_basicTextField setStringValue:@"My Label"];
      [_basicTextField setBezeled:NO];
      [_basicTextField setDrawsBackground:NO];
      [_basicTextField setEditable:NO];
      [_basicTextField setSelectable:NO];
      [self addSubview:_basicTextField];
      
      _orientationLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(5, self.frame.size.height - 20, 400, 20)];
      [_orientationLabel setStringValue:@"Orientation: Custom"];
      [_orientationLabel setBezeled:NO];
      [_orientationLabel setDrawsBackground:NO];
      [_orientationLabel setEditable:NO];
      [_orientationLabel setSelectable:NO];
      _orientationLabel.autoresizingMask = NSViewMinYMargin;
      [self addSubview:_orientationLabel];
    }
    
    return self;
}


@end
