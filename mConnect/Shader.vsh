//
//  Shader.vsh
//  TestGame
//
//  Created by Brandon Withrow on 6/8/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;
attribute vec4 texture;

uniform mat4 modelViewMatrix;
uniform mat4 cameraLocationMatrix;
uniform mat4 cameraProjectionMatrix;
uniform mat3 normalMatrix;


varying lowp vec4 colorVarying;
varying lowp vec4 lightVarying;
varying lowp vec4 textureVarying;
precision mediump float;
uniform int light1On;
uniform int light2On;
uniform int light3On;
uniform int light4On;
uniform int hasTexture;
uniform vec3 light1;
uniform mat4 light2;
uniform mat4 light3;
uniform mat4 light4;
uniform vec2 textureOffset;
uniform vec4 diffuseColor;

void main() {

  vec3 eyeNormal = normalize(normalMatrix * normal);
  float nDotVP = max(0.0, dot(eyeNormal, normalize(light1.xyz)));
  
  lightVarying[0] = nDotVP;
  lightVarying[1] = nDotVP;
  lightVarying[2] = nDotVP;
  lightVarying[3] = 1.0;
  colorVarying = diffuseColor;
  colorVarying[3] = 1.0;
  
  textureVarying = texture;
  gl_Position = cameraProjectionMatrix * cameraLocationMatrix * modelViewMatrix * position;
}
