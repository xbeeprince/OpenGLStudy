
attribute vec4 position;
attribute vec4 sourceColor;

varying vec4 destinationColor;

void main(void)
{
    destinationColor = sourceColor;
    gl_Position = position;
}
