//
//  MCMeshView.m
//  mConnect
//
//  Created by Brandon Withrow on 7/21/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//

#import "MCMeshView.h"
#import "BWShader.h"
#import "BWMesh.h"
#import "BWModel.h"

@interface MCMeshView () <GLKViewDelegate>

@end

@implementation MCMeshView {
  EAGLContext *context_;
  GLKView *glView_;
  BWModel *meshModel_;
  GLKVector3 _anchor_position;
  GLKVector3 _current_position;
}

- (id)initWithFrame:(CGRect)frame andMeshName:(NSString *)mesh {
    self = [super initWithFrame:frame];
    if (self) {
      context_ = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
      glView_ = [[GLKView alloc] initWithFrame:self.bounds context:context_];
      glView_.drawableDepthFormat = GLKViewDrawableDepthFormat24;
      glView_.delegate = self;
      [self addSubview:glView_];
      [EAGLContext setCurrentContext:context_];
      glEnable(GL_DEPTH_TEST);
        // Initialization code
      __weak typeof(self) weakSelf = self;
      NSString *command = [NSString stringWithFormat:@"bw.getMeshVertexData('%@')", mesh];
      [[MCStreamClient sharedClient] getJSONFromPyCommand:command withCompletion:^(id JSONObject) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf _loadMesh:(NSArray *)JSONObject];
      } withFailure:^{
        
      }];
      UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
      [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
  CGPoint location = [pan locationInView:self];
  if (pan.state == UIGestureRecognizerStateBegan) {
    
    _anchor_position = GLKVector3Make(location.x, location.y, 0);
    _anchor_position = [self projectOntoSurface:_anchor_position];
    
    _current_position = _anchor_position;
  }
  
  
  // Add to bottom of touchesMoved
  _current_position = GLKVector3Make(location.x, location.y, 0);
  _current_position = [self projectOntoSurface:_current_position];
  
  GLKVector3 axis = GLKVector3CrossProduct(_anchor_position, _current_position);
  float dot = GLKVector3DotProduct(_anchor_position, _current_position);
  float angle = acosf(dot);
  
  GLKQuaternion Q_rot = GLKQuaternionMakeWithAngleAndVector3Axis(angle * 2, axis);
  Q_rot = GLKQuaternionNormalize(Q_rot);
  
  if (meshModel_) {
    meshModel_.transform = GLKMatrix4MakeWithQuaternion(Q_rot);
    [glView_ display];
  }
}

- (GLKVector3) projectOntoSurface:(GLKVector3) touchPoint
{
  float radius = self.bounds.size.width/3;
  GLKVector3 center = GLKVector3Make(self.bounds.size.width/2, self.bounds.size.height/2, 0);
  GLKVector3 P = GLKVector3Subtract(touchPoint, center);
  
  // Flip the y-axis because pixel coords increase toward the bottom.
  P = GLKVector3Make(P.x, P.y * -1, P.z);
  
  float radius2 = radius * radius;
  float length2 = P.x*P.x + P.y*P.y;
  
  if (length2 <= radius2)
    P.z = sqrt(radius2 - length2);
  else
  {
    P.x *= radius / sqrt(length2);
    P.y *= radius / sqrt(length2);
    P.z = 0;
  }
  
  return GLKVector3Normalize(P);
}

- (void)_loadMesh:(NSArray *)vertexData {
  meshModel_ = [[BWModel alloc] init];
  meshModel_.shader = [[BWShader alloc] initWithShaderNamed:@"Shader"];
  meshModel_.mesh = [[BWMesh alloc] initWithNumberOfVertices:vertexData.count];
  for (int i = 0; i < vertexData.count; i++) {
    NSDictionary *face = [vertexData objectAtIndex:i];
    GLKVector3 vertex = GLKVector3Make([face[@"x"] floatValue], [face[@"y"] floatValue], [face[@"z"] floatValue]);
    [meshModel_.mesh setVertex:vertex atIndex:i];
    GLKVector3 normal = GLKVector3Make([face[@"xN"] floatValue], [face[@"yN"] floatValue], [face[@"zN"] floatValue]);
    [meshModel_.mesh setTexCoor0:normal atIndex:i];
//    [meshModel_.mesh setTexCoor0:GLKVector3Make([face[@"u"] floatValue], [face[@"v"] floatValue], 1.f)
//                         atIndex:[vertexData indexOfObject:face]];
  }
  meshModel_.projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(18.0f), 1.f, 0.1f, 100.0f);
  meshModel_.transform = GLKMatrix4MakeTranslation(0, 0, 0);
  meshModel_.projectionTransform = GLKMatrix4MakeLookAt(5, 10, 10, 0, 0, 0, 0, 1, 0);
  [meshModel_ setUseBlock:^(BWModel *model) {
    GLKVector4 diffuseColor = GLKVector4Make(0, 0.4, 0.4, 1);
    [model.shader setUniform:@"diffuseColor" withValue:&diffuseColor];
    
    GLKVector3 light1Matrix = GLKVector3Make(3, 3, 3);
    [model.shader setUniform:@"light1" withValue:&light1Matrix];
    GLint lightOn = 1;
    [model.shader setUniform:@"light1On" withValue:&lightOn];
    
    GLKMatrix3 normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(model.transform), NULL);
    [model.shader setUniform:@"normalMatrix" withValue:&normalMatrix];
  }];
  [meshModel_.mesh updateBuffer];
  [glView_ display];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
  
  glClearColor(0.5f, 0.5f, 0.5f, 1.f);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  if (meshModel_) {
    [meshModel_ use];
    [meshModel_ draw];
  }
}


@end
