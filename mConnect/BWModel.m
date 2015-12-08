//
//  BWModel.m
//  Perfective
//
//  Created by Brandon Withrow on 5/11/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//

#import "BWModel.h"
#import "BWShader.h"
#import "BWMesh.h"
#import "BWImage.h"

@implementation BWModel

- (id)init {
  self = [super init];
  if (self) {
    _projection = GLKMatrix4Identity;
    _transform = GLKMatrix4Identity;
    _projectionTransform = GLKMatrix4Identity;
  }
  return self;
}

- (void)use {
  if (!self.shader || !self.mesh) {
    return;
  }
  if (self.mesh.needsUpdate) {
    [self.mesh updateBuffer];
  }
  [self.shader use];
  [self.mesh use];
}

- (void)setUniforms {
  GLint hasTexture = (self.imageTexture != nil);
  [self.shader setUniform:@"hasTexture" withValue:&hasTexture];
  [self.shader setUniform:@"cameraProjectionMatrix" withValue:&_projection];
  [self.shader setUniform:@"cameraLocationMatrix" withValue:&_projectionTransform];
  [self.shader setUniform:@"modelViewMatrix" withValue:&_transform];
}

- (void)draw {
  if (!self.shader || !self.mesh) {
    return;
  }
  if (self.imageTexture) {
    [self.imageTexture use];
  }
  if (self.useBlock) {
    self.useBlock(self);
  }
  [self setUniforms];
  glDrawArrays(GL_TRIANGLES, 0, self.mesh.vertexCount);
  glUseProgram(0);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindVertexArrayOES(0);
  glBindTexture(GL_TEXTURE_2D, 0);
}

@end
