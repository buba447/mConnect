//
//  MCRotationalControl.m
//  mConnect
//
//  Created by Brandon Withrow on 7/14/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//

#import "MCRotationalControl.h"
#import "BWShader.h"
#import "BWMesh.h"
#import "BWModel.h"

@interface MCRotationalControl () <GLKViewDelegate>

@end

@implementation MCRotationalControl {
  EAGLContext *context_;
  GLKView *glView_;
  BWModel *xModel_;
  BWModel *yModel_;
  BWModel *zModel_;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
      context_ = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
      glView_ = [[GLKView alloc] initWithFrame:self.bounds context:context_];
      glView_.drawableDepthFormat = GLKViewDrawableDepthFormat24;
      glView_.delegate = self;
      [self addSubview:glView_];
      [EAGLContext setCurrentContext:context_];
      BWShader *shader = [[BWShader alloc] initWithShaderNamed:@"circleShader"];
      BWMesh *mesh = [[BWMesh alloc] initWithNumberOfVertices:4];
      [mesh setVertex:GLKVector3Make(-1, 1, 0.f) atIndex:0];
      [mesh setTexCoor0:GLKVector3Make(0.f, 0.f, 1.f) atIndex:0];
      
      [mesh setVertex:GLKVector3Make(1, 1, 0.f) atIndex:1];
      [mesh setTexCoor0:GLKVector3Make(1.f, 0.f, 1.f) atIndex:1];
      
      [mesh setVertex:GLKVector3Make(-1, -1, 0.f) atIndex:2];
      [mesh setTexCoor0:GLKVector3Make(0.f, 1.f, 1.f) atIndex:2];
      
      [mesh setVertex:GLKVector3Make(1, -1, 0.f) atIndex:3];
      [mesh setTexCoor0:GLKVector3Make(1.f, 1.f, 1.f) atIndex:3];
      
      zModel_ = [[BWModel alloc] init];
      zModel_.mesh = mesh;
      zModel_.shader = shader;
      zModel_.projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(25.0f), 1.f, 0.1f, 100.0f);
      zModel_.transform = GLKMatrix4MakeTranslation(0, 0, 0);
      zModel_.projectionTransform = GLKMatrix4MakeLookAt(3, 3, -3, 0, 0, 0, 0, 1, 0);
      [zModel_ setUseBlock:^(BWModel *model) {
        GLKVector4 diffuseColor = GLKVector4Make(0, 0, 1, 1);
        [model.shader setUniform:@"diffuseColor" withValue:&diffuseColor];
        GLfloat radius = 0.5;
        [model.shader setUniform:@"circleRadius" withValue:&radius];
        GLfloat linThickness = 0.1;
        [model.shader setUniform:@"lineThickness" withValue:&linThickness];
      }];
      
      BWMesh *mesh2 = [[BWMesh alloc] initWithNumberOfVertices:4];
      [mesh2 setVertex:GLKVector3Make(0, 1, 1) atIndex:0];
      [mesh2 setTexCoor0:GLKVector3Make(0.f, 0.f, 1.f) atIndex:0];
      
      [mesh2 setVertex:GLKVector3Make(0, 1, -1) atIndex:1];
      [mesh2 setTexCoor0:GLKVector3Make(1.f, 0.f, 1.f) atIndex:1];
      
      [mesh2 setVertex:GLKVector3Make(0, -1, 1) atIndex:2];
      [mesh2 setTexCoor0:GLKVector3Make(0.f, 1.f, 1.f) atIndex:2];
      
      [mesh2 setVertex:GLKVector3Make(0, -1, -1) atIndex:3];
      [mesh2 setTexCoor0:GLKVector3Make(1.f, 1.f, 1.f) atIndex:3];
      
      xModel_ = [[BWModel alloc] init];
      xModel_.mesh = mesh2;
      xModel_.shader = shader;
      xModel_.projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(25.0f), 1.f, 0.1f, 100.0f);
      xModel_.transform = GLKMatrix4MakeTranslation(0, 0, 0);
      xModel_.projectionTransform = GLKMatrix4MakeLookAt(3, 3, -3, 0, 0, 0, 0, 1, 0);
      [xModel_ setUseBlock:^(BWModel *model) {
        GLKVector4 diffuseColor = GLKVector4Make(1, 0, 0, 1);
        [model.shader setUniform:@"diffuseColor" withValue:&diffuseColor];
        GLfloat radius = 0.5;
        [model.shader setUniform:@"circleRadius" withValue:&radius];
        GLfloat linThickness = 0.1;
        [model.shader setUniform:@"lineThickness" withValue:&linThickness];
      }];
      
      BWMesh *mesh3 = [[BWMesh alloc] initWithNumberOfVertices:4];
      [mesh3 setVertex:GLKVector3Make(1, 0, 1) atIndex:0];
      [mesh3 setTexCoor0:GLKVector3Make(0.f, 0.f, 1.f) atIndex:0];
      
      [mesh3 setVertex:GLKVector3Make(-1, 0, 1) atIndex:1];
      [mesh3 setTexCoor0:GLKVector3Make(1.f, 0.f, 1.f) atIndex:1];
      
      [mesh3 setVertex:GLKVector3Make(1, 0, -1) atIndex:2];
      [mesh3 setTexCoor0:GLKVector3Make(0.f, 1.f, 1.f) atIndex:2];
      
      [mesh3 setVertex:GLKVector3Make(-1, 0, -1) atIndex:3];
      [mesh3 setTexCoor0:GLKVector3Make(1.f, 1.f, 1.f) atIndex:3];
      
      yModel_ = [[BWModel alloc] init];
      yModel_.mesh = mesh3;
      yModel_.shader = shader;
      yModel_.projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(25.0f), 1.f, 0.1f, 100.0f);
      yModel_.transform = GLKMatrix4MakeTranslation(0, 0, 0);
      yModel_.projectionTransform = GLKMatrix4MakeLookAt(3, 3, -3, 0, 0, 0, 0, 1, 0);
      [yModel_ setUseBlock:^(BWModel *model) {
        GLKVector4 diffuseColor = GLKVector4Make(0, 1, 0, 1);
        [model.shader setUniform:@"diffuseColor" withValue:&diffuseColor];
        GLfloat radius = 0.5;
        [model.shader setUniform:@"circleRadius" withValue:&radius];
        GLfloat linThickness = 0.1;
        [model.shader setUniform:@"lineThickness" withValue:&linThickness];
      }];
    }
    return self;
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//  CGPoint touchPoint = [[touches anyObject] locationInView:self];
//  UIImage *image = [glView_ snapshot];
//
//  if ((touchPoint.x < image.size.width) && (touchPoint.y < image.size.height))
//  {
//    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
//    const UInt8* data = CFDataGetBytePtr(pixelData);
//    size_t bytesPerRow = CGImageGetBytesPerRow(image.CGImage);
//    size_t width = CGImageGetWidth(image.CGImage);
//    size_t height = CGImageGetHeight(image.CGImage);
//    
//    touchPoint.x *= image.scale;
//    touchPoint.y *= image.scale;
//
//
//  }
//}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {

  glClearColor(0.5f, 0.5f, 0.5f, 1.f);
  glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);;
  glEnable(GL_BLEND);
  glEnable(GL_DEPTH_TEST);
//  glEnable(GL_ALPHA_TEST);
//  glAlphaFunc(GL_EQUAL, 1.0f);
  
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  [xModel_ use];
  [xModel_ draw];
  [yModel_ use];
  [yModel_ draw];
  [zModel_ use];
  [zModel_ draw];
}

@end
