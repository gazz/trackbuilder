#import "AppDelegate.h"
#import "ProjectedView.h"

#import <OpenGL/OpenGL.h>
#import <GLUT/GLUT.h>

#import <glm/glm.hpp>
#import <glm/gtc/type_ptr.hpp>
#include <glm/gtc/matrix_transform.hpp>

#import "Scene.h"
#import "utils.h"

#import "OverlayControlsView.h"

#define FAST_TRANSFORM_SCALE 10

@interface ProjectedView ()

- (void) drawRect: (NSRect) bounds;
- (void) reshape;
- (Scene*) scene;

@end

@implementation ProjectedView {
  NSMutableSet *_keysDown;
  ProjectionViewCamera _camera;
  NSOpenGLContext *_openGLContext;

  Ray _ray;
  
  glm::vec3 _screenH;
  glm::vec3 _screenV;
  
  NSTrackingRectTag _trackingRect;
  NSWindow *_overlayControlsWindow;
  OverlayControlsView *_controlsView;
  
  double _rayCastTime;
  
  CGPoint _mouseLocation;
}


- (id) initWithFrame:(NSRect)frameRect openGLContext:(NSOpenGLContext*)glContext
{
  if (self = [super initWithFrame:frameRect]) {
    _openGLContext = glContext;
    
    self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    _keysDown = [NSMutableSet set];

    // initial camera position
    _camera.center = glm::vec3(0);

    _camera.distance = 5;
    _camera.rotation = glm::quat();
    _camera.rotation = glm::rotate(_camera.rotation, 40, glm::vec3(1,0,0));
    _camera.rotation = glm::rotate(_camera.rotation, -30, glm::vec3(0,1,0));
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SceneNeedsRenderNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
      if (note.object != self && self.superview) {
        [self setNeedsDisplay:YES];
      }
    }];
  }
  return self;
}


- (CGRect)overlayFrameSize:(NSWindow *)window
{
  CGRect wRect = window.frame;
  NSView *contentView  = self;
  CGRect cRect = contentView.frame;
  
  if (contentView.superview.superview.isFlipped) {
    CGRect superFrame = contentView.superview.frame;
    cRect.origin.y = contentView.superview.superview.frame.size.height - cRect.size.height - cRect.origin.y - superFrame.origin.y;
    cRect.size.width -= 1;
  }
  
  CGRect rect = CGRectMake(wRect.origin.x + cRect.origin.x, wRect.origin.y + cRect.origin.y, cRect.size.width, cRect.size.height);
  return rect;
}


- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
  if ( [self window] && _trackingRect ) {
    [self removeTrackingRect:_trackingRect];
  }

  if (_overlayControlsWindow) [_overlayControlsWindow orderOut:nil];
  
  CGRect rect = [self overlayFrameSize:newWindow];
  _overlayControlsWindow = [[NSWindow alloc]initWithContentRect:rect
                                                       styleMask:NSBorderlessWindowMask
                                                         backing:NSBackingStoreBuffered
                                                           defer:NO];

  _overlayControlsWindow.backgroundColor = [NSColor clearColor];
  _overlayControlsWindow.opaque = NO;
  
  _controlsView = [[OverlayControlsView alloc] initWithFrame:NSZeroRect];
  _overlayControlsWindow.contentView = _controlsView;
  
  [newWindow addChildWindow:_overlayControlsWindow ordered:NSWindowAbove];
}


- (Scene*) scene
{
  return DHApp.scene;
}


-(BOOL) acceptsFirstResponder
{
  return YES;
}

- (void)setFrame:(NSRect)frame {
  [super setFrame:frame];
  [self removeTrackingRect:_trackingRect];
  _trackingRect = [self addTrackingRect:self.bounds owner:self userData:NULL assumeInside:NO];
  
  [_overlayControlsWindow setFrame:[self overlayFrameSize:self.window] display:YES];
}


- (void) reshape
{
  [ _openGLContext update ];

  [self updateCamera];
}


- (glm::vec3)eyeForRotation:(glm::quat)rotation
{
  glm::vec3 eye = glm::vec3(0,0,1) * rotation;
  eye *= _camera.distance;
  eye += _camera.center;
  return eye;
}


- (glm::vec3)cameraEye
{
  return [self eyeForRotation:_camera.rotation];
}


- (void)updateCamera
{
  NSRect sceneBounds = [ self bounds ];
  
  glViewport( 0, 0, sceneBounds.size.width, sceneBounds.size.height );
  // Calculate the aspect ratio of the view
  glMatrixMode( GL_PROJECTION );   // Select the projection matrix
  
  
  glLoadIdentity();                // and reset it
  gluPerspective( 45, sceneBounds.size.width / sceneBounds.size.height,
                 0.1f, 100.0f );
  
  glEnable(GL_DEPTH_TEST);
  glm::vec3 up = glm::vec3(0,1,0);
  glm::vec3 eye = [self cameraEye];
  
  glm::mat4 matrix = glm::lookAt(eye, _camera.center, up);
  glMultMatrixf(glm::value_ptr(matrix));
  
  glm::vec3 view = glm::normalize(_camera.center - eye);
  _screenH = glm::normalize(glm::cross(view, glm::vec3(0,1,0)));
  _screenV = glm::normalize(glm::cross(_screenH, view));
  
  CGFloat rad = 45 * M_PI / 180;
  CGFloat vLength = tan( rad / 2) * .1;
  CGFloat hLength = vLength * (sceneBounds.size.width / sceneBounds.size.height);
  
  _screenV *= vLength;
  _screenH *= hLength;

  [self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)dirtyRect
{
  NSDate *date = [NSDate date];
  
  
//  if (_openGLContext.view != self) {
//    NSLog(@"View: %@ against view: %@", _openGLContext.view, self);
    [_openGLContext setView:self];
//  }

//  NSLog(@"Keeping on rendering: %@", self);

//  NSLog(@"rendering view: %@", self);

  glMatrixMode( GL_MODELVIEW );   // Select the projection matrix
  
  glClearColor(0.806, 0.846, 0.846, 0);
  glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
  
  [self drawGrid];

  [self.scene renderNodes];
  
  [self.scene renderBounds];
  
  // as the last draw world axis on top of everything
  [self drawWorldAxis];
  
  [self drawCameraPivot];
  
  if ([[self window] firstResponder]==self) {
    // draw ray
    glLoadIdentity();
    glPointSize(5);
    glBegin(GL_POINTS);
    {
      glm::vec3 dest = (_ray.origin + _ray.direction);
      glColor3f(1, 0, 0);
      glVertex3f(dest.x, dest.y, dest.z);
    }
    glEnd();
  }
  
  [self renderUIOverlay];
  
  glFlush();
  
  double timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
  _controlsView.basicTextField.stringValue = [self statisticsTextForPassedTime:timePassed_ms];
}


- (NSString*)statisticsTextForPassedTime:(double)passedMs
{
  static int index = 0;
  const int maxFramesAverage = 50;
  static double framesToAverage[maxFramesAverage];
  
  framesToAverage[index++] = passedMs;
  if (index >= maxFramesAverage)
    index = 0;

  double amountedTime = 0;
  for (int i = 0; i < maxFramesAverage; ++i) {
    amountedTime += framesToAverage[i];
  }
  int fps = 1000 / amountedTime * maxFramesAverage;
  
  return [NSString stringWithFormat:@"render took %f miliseconds, FPS: %d, rayCastTime: %.3f ms", passedMs, fps, _rayCastTime];
}


- (void) drawGrid
{
//  glEnable( GL_LINE_STIPPLE );
//  glLineStipple( 3, 0xff4e );

  GLfloat lineScale = .25;
  int numLines = 250;
  GLfloat lineLength = (numLines -1) * lineScale;

  glColor3f(0.9f, 0.9f, 0.9f);

  glLoadIdentity();

  glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
  glPolygonOffset( 1.0, 1.0 );
  glEnable(GL_POLYGON_OFFSET_LINE);
  
  glBegin(GL_QUADS);
  {
    // draw a maximum of 10 lines deep && 10 lines across
    for (int i=-numLines/2; i<=numLines/2; ++i) {
      CGFloat scaledOffset = i * lineScale;
      glVertex3f(scaledOffset, 0, -lineLength/2);
      glVertex3f(scaledOffset, 0, lineLength/2);
      glVertex3f(-lineLength/2, 0, scaledOffset);
      glVertex3f(lineLength/2, 0, scaledOffset);
    }
  }
  glEnd();
  
  glDisable(GL_POLYGON_OFFSET_LINE);
  
  glDisable(GL_LINE_STIPPLE);
}


- (void)drawWorldAxis
{
  glClear(GL_DEPTH_BUFFER_BIT);
  drawArrowFrom(glm::vec3(0,0,0), glm::vec3(1,0,0), glm::vec3(1,0,0)); // red x axis
  drawArrowFrom(glm::vec3(0,0,0), glm::vec3(0,1,0), glm::vec3(0,1,0)); // green y axis
  drawArrowFrom(glm::vec3(0,0,0), glm::vec3(0,0,1), glm::vec3(0,0,1)); // blue z axis
}

- (void)drawCameraPivot
{
  glPushMatrix();
  
  // draw circle of axes arount pivot
  glLoadIdentity();
  glTranslatef(_camera.center.x, _camera.center.y, _camera.center.z);

  CGFloat pivotSize = .03;
  drawCircle(pivotSize * _camera.distance, glm::vec3(1, 0, 0));
  glRotatef(90, 1, 0, 0);
  drawCircle(pivotSize * _camera.distance, glm::vec3(0, 1, 0));
  glRotatef(90, 0, 1, 0);
  drawCircle(pivotSize * _camera.distance, glm::vec3(0, 0, 1));

  glPopMatrix();
}


- (void)renderUIOverlay
{
  if (!self.scene.pickedNode) {
    return;
  }
  NSRect sceneBounds = [ self bounds ];
  // Calculate the aspect ratio of the view
  const CGFloat XSize = sceneBounds.size.width, YSize = sceneBounds.size.height;
  
  glDisable(GL_DEPTH_TEST);
  glMatrixMode (GL_PROJECTION);
  
  glLoadIdentity ();
  
  glOrtho (0, XSize, 0, YSize, 0, 1);
  
  CGFloat popupWidth = 200;
  CGFloat popupHeight = 200;
  CGFloat horOffset = 10;
  CGFloat verOffset = 10;
  
  glm::vec2 v1(_mouseLocation.x + horOffset, _mouseLocation.y + 15);
  glm::vec2 v2(_mouseLocation.x + popupWidth + horOffset, _mouseLocation.y + 15);
  glm::vec2 v3(_mouseLocation.x + popupWidth + horOffset, _mouseLocation.y - popupHeight + verOffset);
  glm::vec2 v4(_mouseLocation.x + horOffset, _mouseLocation.y - popupHeight + verOffset);
  
  glBegin(GL_QUADS);
  {
    glColor3f(.9, .9, .9);
    
    glVertex2f(v1.x, v1.y);
    glVertex2f(v2.x, v2.y);
    glVertex2f(v3.x, v3.y);
    glVertex2f(v4.x, v4.y);

  }
  glEnd();

  
  glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
  glPolygonOffset( 1.0, 1.0 );
  glEnable(GL_POLYGON_OFFSET_LINE);
  glBegin(GL_QUADS);
  {
    glColor3f(.7, .7, .7);

    glVertex2f(v1.x, v1.y);
    glVertex2f(v2.x, v2.y);
    glVertex2f(v3.x, v3.y);
    glVertex2f(v4.x, v4.y);
  }
  glEnd();
}


#pragma mark - input handlers

-(void) keyDown:(NSEvent *)theEvent
{
  [_keysDown addObject:[NSNumber numberWithInt:theEvent.keyCode]];
  [self setNeedsDisplay:YES];
}


-(void) keyUp:(NSEvent *)theEvent
{
  [_keysDown removeObject:[NSNumber numberWithInt:theEvent.keyCode]];
}


- (void)scrollWheel:(NSEvent *)theEvent {
  CGFloat zoomScale = 0.01;
  CGFloat zoom = 0.0f;
  if ([theEvent modifierFlags] & NSShiftKeyMask) {
    // for some reason shift makes the X scroll not Y
    zoom =- theEvent.deltaX * zoomScale * FAST_TRANSFORM_SCALE;
  } else {
    zoom =- theEvent.deltaY * zoomScale;
  }
  // zoom
  _camera.distance += zoom;
  if (_camera.distance < 0.1) {
    _camera.distance =  0.2;
  }

  [self updateCamera];

  NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  [self calculatePointerRay:curPoint];

}


- (void)mouseEntered:(NSEvent *)theEvent {
  [super mouseEntered:theEvent];
  if ([[self window] isKeyWindow]) {
    [[self window] makeFirstResponder:self];
  }
}


- (void)mouseExited:(NSEvent *)theEvent {
  [super mouseExited:theEvent];
}


- (void)mouseMoved:(NSEvent *)theEvent
{
  _mouseLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];;
  CGPoint mouseLoc = _mouseLocation;
  if (NSPointInRect(mouseLoc, self.bounds)) {
    
    if ([theEvent modifierFlags] & NSCommandKeyMask) {
      
      if ([theEvent modifierFlags] & NSShiftKeyMask) {
        // TODO: dont touch eye, just rotate center
      } else {
        float yAxisRotation = (CGFloat)(theEvent.deltaX);
        float xAxisRotation = (CGFloat)(theEvent.deltaY);
        if (yAxisRotation) {
          glm::vec3 rotAxis = glm::vec3(0, 1, 0);
          _camera.rotation = glm::rotate(_camera.rotation, yAxisRotation, rotAxis);
        }
        if (xAxisRotation) {
          glm::vec3 rotAxis = glm::vec3(-1, 0, 0) * _camera.rotation;
          
          glm::quat newRotation = glm::rotate(_camera.rotation, xAxisRotation, rotAxis);
          
          // limit rotation
          glm::vec3 calculatedEye = [self eyeForRotation:newRotation];
          if (calculatedEye.y >= 0 && calculatedEye.y < _camera.distance - 0.1) {
            _camera.rotation = newRotation;
          }
        }
      }
  
      [self updateCamera];
    }
    else if ([theEvent modifierFlags] & NSAlternateKeyMask) {
      CGFloat translateScale = 0.001 * _camera.distance;
      
      translateScale *= [theEvent modifierFlags] & NSShiftKeyMask ? FAST_TRANSFORM_SCALE : 1;
      
      glm::vec3 offsetVec = glm::vec3(-theEvent.deltaX * translateScale, 0, -theEvent.deltaY * translateScale);
      CGFloat len = glm::length(offsetVec);

      offsetVec = offsetVec * _camera.rotation;
      offsetVec.y = 0;
      
      if ([theEvent modifierFlags] & NSControlKeyMask) {
        offsetVec = glm::vec3(0, -theEvent.deltaY * translateScale, 0);
        _camera.center += offsetVec;
      } else {
        // upscale for the lost y component
        if (glm::length(offsetVec)) {
          offsetVec *= len/glm::length(offsetVec);
          _camera.center += offsetVec;
        }
      }
      

      [self updateCamera];
    }
  
    NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    [self calculatePointerRay:curPoint];
  }
}


-(void) calculatePointerRay:(CGPoint)point
{
  NSDate *date = [NSDate date];
 //NSLog(@"mouse location: [%f, %f]", point.x, point.y);
  
  NSRect sceneBounds = [ self bounds ];
  
  glm::vec3 eye = [self cameraEye];

  // calculate ray direction for mouse location
  glm::vec3 view = glm::normalize(_camera.center - eye);
  
  CGFloat x = point.x - sceneBounds.size.width / 2;
  CGFloat y = point.y - sceneBounds.size.height / 2;
  x /= (sceneBounds.size.width / 2);
  y /= (sceneBounds.size.height / 2);

//  glm::
  _ray.origin = eye;
  glm::vec3 viewScaled = view;
  viewScaled *= .1;
  _ray.origin += viewScaled;
  
  glm::vec3 hScaled = _screenH;
  hScaled *= x;
  _ray.origin += hScaled;

  glm::vec3 vScaled = _screenV;
  vScaled *= y;
  _ray.origin += vScaled;
  
  _ray.direction = _ray.origin;
  _ray.direction -= eye;

  //  glm::vec3 dest = _ray.origin + _ray.direction;
  //NSLog(@"from: %@, to: %@", toString(_ray.origin), toString(dest));

  // update mouse position
  [self setNeedsDisplay:YES];
  
  static BOOL objInFocus = NO;

  if ([self.scene pickNodeWithRay:_ray.direction origin:_ray.origin]) {
    if (!objInFocus) {
      objInFocus = YES;
      [[NSNotificationCenter defaultCenter] postNotificationName:SceneNeedsRenderNotification object:self];
    }
  } else if (objInFocus) {
    objInFocus = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:SceneNeedsRenderNotification object:self];
  }
  _rayCastTime = [date timeIntervalSinceNow] * -1000.0;
}


- (NSString*)stringForOrientation
{
  switch (self.orientation) {
    case ProjectedViewOrtoTop:
      return @"Top View";
    case ProjectedViewOrtoLeft:
      return @"Left View";
    case ProjectedViewOrtoFront:
      return @"Front View";
    case ProjectedViewOrientationCustom:
    default:
      return @"Unknown";
  }
}

@end


