//
//  Shader.fsh
//  TestGame
//
//  Created by Brandon Withrow on 6/8/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

uniform int hasTexture;
uniform int light1On;

precision mediump float;
varying lowp vec4 colorVarying;
varying lowp vec4 lightVarying;
varying lowp vec4 textureVarying;

uniform sampler2D texture;
uniform vec2 textureOffset;

void main()
{  
  vec4 textureV = texture2D(texture, textureVarying.xy);
  vec4 mixed = (colorVarying * (1.0 - (textureV.a * float(hasTexture)))) + 
                (textureV * float(hasTexture));
  mixed[3] = 1.0;
  gl_FragColor = colorVarying * lightVarying;
}
