//
//  AppDelegate.h
//  TrackBuilder
//
//  Created by Janis Dancis on 5/21/13.
//  Copyright (c) 2013 digihaze. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Scene.h"

#define DHApp ((AppDelegate*)[[NSApplication sharedApplication] delegate])

enum {
  NO_DEBUG = 0,
  BASIC_DEBUG,
//  STREET_DEBUG,
//  PRO_DEBUG,
  MAX_DEBUG
} typedef DH_DEBUG_MODES;


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property NSWindow *window;
@property NSViewController *rootViewController;

@property (readonly) Scene *scene;

@property (nonatomic) NSInteger debugMode;
@property NSInteger numRayCalculations;

- (void)rotateDebugMode;

@end
