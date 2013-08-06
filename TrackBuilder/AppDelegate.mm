//
//  AppDelegate.m
//  TrackBuilder
//
//  Created by Janis Dancis on 5/21/13.
//  Copyright (c) 2013 digihaze. All rights reserved.
//

#import "AppDelegate.h"

#import "CompositeViewController.h"

#import "Scene.h"


@implementation AppDelegate {
  Scene *_scene;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  self.debugMode = MAX_DEBUG;

  _scene = [Scene new];
  
  NSOpenGLPixelFormatAttribute attrs[] = { NSOpenGLPFADepthSize,24, 0 };
  NSOpenGLPixelFormat *pixFmt = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
  NSOpenGLContext *rootGLContext = [[NSOpenGLContext alloc] initWithFormat:pixFmt shareContext:nil];
  
  self.rootViewController = [[CompositeViewController alloc] initWithRootGLContext:rootGLContext];
  self.window = [self spawnWindowWithTitle:@"Yeehaa" autosaveName:@"Main"];
  [self.window makeKeyAndOrderFront:nil];
  self.window.contentView = self.rootViewController.view;
  
}

-(NSWindow*)spawnWindowWithTitle:(NSString*)title autosaveName:(NSString*)autosaveName
{
  // init single window app
  NSRect visibleScreenFrame = [[NSScreen mainScreen] visibleFrame];
  NSRect targetFrame = NSMakeRect(0, 0, 1280, 800);
  CGFloat x = (visibleScreenFrame.size.width - targetFrame.size.width) / 2;
  CGFloat y = (visibleScreenFrame.size.height - targetFrame.size.height) / 2;
  
  // Create a rect to send to the window
  NSRect newFrame = NSMakeRect(x, y, targetFrame.size.width, targetFrame.size.height);
  
  NSWindow *win = [[NSWindow alloc] initWithContentRect:newFrame
                                            styleMask:NSTitledWindowMask|NSClosableWindowMask|NSResizableWindowMask
                                              backing:NSBackingStoreBuffered defer:NO];
  
  [win setFrameAutosaveName:autosaveName];
  [win setBackgroundColor:[NSColor grayColor]];
  [win setTitle:title];
  [win setAcceptsMouseMovedEvents:YES];
  
  win.minSize = NSMakeSize(400, 300);

  return win;
}


- (Scene*)scene
{
  return _scene;
}

- (void)rotateDebugMode
{
  self.debugMode = self.debugMode - 1;
  if (_debugMode < NO_DEBUG) self.debugMode = MAX_DEBUG;
}

- (void)setDebugMode:(NSInteger)debugMode
{
  _debugMode = debugMode;
  [[NSNotificationCenter defaultCenter] postNotificationName:SceneNeedsRenderNotification object:self];
}


@end
