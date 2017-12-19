
attribute vec4 position;
attribute vec4 sourceColor;

uniform mat4 m;
uniform mat4 v;
uniform mat4 p;

varying vec4 destinationColor;

void main(void)
{
    destinationColor = sourceColor;
    gl_Position = p*v*m*position;
}
