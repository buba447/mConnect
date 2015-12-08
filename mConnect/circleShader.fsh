varying lowp vec4 textureVarying;

uniform sampler2D texture;
uniform lowp float circleRadius;
uniform lowp float lineThickness;
uniform int hasTexture;
uniform lowp vec4 diffuseColor;

const highp vec2 center = vec2(0.5, 0.5);
void main()
{
//  lowp vec2 alteredTexture = textureVarying_b.xy;
//  alteredTexture.x = alteredTexture.x - 0.5;
//  alteredTexture.y = alteredTexture.y - 0.5;
//  highp float magDistance = distance(vec2(0.0, 0.0), alteredTexture.xy);
//  magDistance = (magDistance * 2.0);
//  magDistance = (magDistance * magDistance * magDistance * magDistance) * 0.05;
//  lowp vec2 offsetDistance = magDistance * alteredTexture.xy;
  
  highp float distanceFromCenter = distance(center, textureVarying.xy);
  lowp float check1 = step(distanceFromCenter, circleRadius);
  lowp float check2 = step(circleRadius - lineThickness, distanceFromCenter);
//  lowp float checkForPresenceWithinOuterCircle = step(distanceFromCenter, 0.5);
  lowp vec4 outColor = diffuseColor * check2 * check1;
  if((check2 * check1) == 0.0)
    discard;
  gl_FragColor = vec4(outColor.xyz, 1.0);
}
