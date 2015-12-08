attribute vec4 position;
attribute vec4 texture;

varying lowp vec4 textureVarying;

uniform mat4 projection;
uniform mat4 transform;
uniform mat4 projectionTransform;
void main()
{
  textureVarying = texture;
  gl_Position = projection * projectionTransform * transform * position;
}