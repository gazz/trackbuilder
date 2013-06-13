//
//  CompositeViewController.m
//  TrackBuilder
//
//  Created by Janis Dancis on 5/21/13.
//  Copyright (c) 2013 digihaze. All rights reserved.
//

#import "CompositeViewController.h"
#import "ProjectedViewsLayoutController.h"
#import "ToolbarViewController.h"
#import "StatusView.h"


@interface CompositeFlippedView : NSView
@end

@implementation CompositeFlippedView

- (BOOL) isFlipped
{
  return YES;
}

@end


@interface CompositeViewController ()

@property ToolbarViewController *toolbar;

@property ProjectedViewsLayoutController *projectedViews;

@property StatusView *statusView;

@end

@implementation CompositeViewController

- (id)initWithRootGLContext:(NSOpenGLContext*)rootGLContext
{
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    NSOpenGLPixelFormatAttribute attrs[] = { NSOpenGLPFADepthSize,24, 0 };
    NSOpenGLPixelFormat *pixFmt = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
    NSOpenGLContext *glContext = [[NSOpenGLContext alloc] initWithFormat:pixFmt shareContext:rootGLContext];
    self.projectedViews = [[ProjectedViewsLayoutController alloc] initWithOpenGLContext:glContext];
  }
  return self;
}

- (void)loadView
{
  // use 100 pixels so that toolbar and status bar are visible and we can calc offsets for center
  self.view = [[CompositeFlippedView alloc] initWithFrame:NSMakeRect(0, 0, 0, 100)];
  
  self.toolbar = [[ToolbarViewController alloc] initWithNibName:nil bundle:nil];
  
  self.toolbar.view.frame = NSMakeRect(0, 0, NSWidth(self.view.frame), NSHeight(self.toolbar.view.frame));
  self.toolbar.view.autoresizingMask = NSViewWidthSizable;
  [self.view addSubview:self.toolbar.view positioned:NSWindowAbove relativeTo:nil];

  // add status bar at the bottom
  self.statusView = [[StatusView alloc] initWithFrame:NSMakeRect(0, NSHeight(self.view.frame),
                                                                 NSWidth(self.view.frame), 0)];
  self.statusView.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
  [self.view addSubview:self.statusView positioned:NSWindowAbove relativeTo:nil];

  self.projectedViews.view.frame = NSMakeRect(0, NSHeight(self.toolbar.view.frame), NSWidth(self.view.frame),
                                              NSHeight(self.view.frame) - NSHeight(self.toolbar.view.frame) - NSHeight(self.statusView.frame));
  self.projectedViews.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  [self.view addSubview:self.projectedViews.view];
}

@end
