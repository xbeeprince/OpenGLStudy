//
//  OpenGlRenderView.m
//  OpenGLStudy
//
//  Created by prince on 2017/12/18.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "OpenGlRenderView.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "OpenGlShaderUtil.h"
#import <GLKit/GLKit.h>

typedef struct {
    float position[4];
    float color[4];
    float texcood[2];
    
}Vertex;

#define TEX_COORD_MAX   1

const Vertex vertices[] = {
    // Front
    {{1, -1, 0}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{1, 1, 0}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, 1, 0}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, -1, 0}, {0, 0, 0, 1}, {0, 0}},
    // Back
    {{1, 1, -2}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{-1, -1, -2}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{1, -1, -2}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, 1, -2}, {0, 0, 0, 1}, {0, 0}},
    // Left
    {{-1, -1, 0}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{-1, 1, 0}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, 1, -2}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, -1, -2}, {0, 0, 0, 1}, {0, 0}},
    // Right
    {{1, -1, -2}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{1, 1, -2}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{1, 1, 0}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{1, -1, 0}, {0, 0, 0, 1}, {0, 0}},
    // Top
    {{1, 1, 0}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{1, 1, -2}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, 1, -2}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, 1, 0}, {0, 0, 0, 1}, {0, 0}},
    // Bottom
    {{1, -1, -2}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{1, -1, 0}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, -1, 0}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, -1, -2}, {0, 0, 0, 1}, {0, 0}}
};

const GLubyte vertexIndex[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 5, 6,
    4, 5, 7,
    // Left
    8, 9, 10,
    10, 11, 8,
    // Right
    12, 13, 14,
    14, 15, 12,
    // Top
    16, 17, 18,
    18, 19, 16,
    // Bottom
    20, 21, 22,
    22, 23, 20
};

@interface OpenGlRenderView()
@property(nonatomic,strong)CAEAGLLayer *eaglLayer;
@property(nonatomic,strong)EAGLContext *renderContext;
@property(nonatomic,assign)GLuint colorRenderBuffer;
@property(nonatomic,assign)GLuint shaderProgram;
@property(nonatomic,assign)GLuint positionHandler;
@property(nonatomic,assign)GLuint colorHandler;

@property(nonatomic,assign)GLuint modelMatrixHandler;
@property(nonatomic,assign)GLuint viewMatixHandler;
@property(nonatomic,assign)GLuint projectMatrixHandler;


@property(nonatomic,assign)GLKMatrix4 modelMatrix;
@property(nonatomic,assign)GLKMatrix4 viewMatix;
@property(nonatomic,assign)GLKMatrix4 projectMatrix;
@end

@implementation OpenGlRenderView

-(instancetype)init
{
    if ([self init]) {
        [self setup];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

-(void)setup
{
    [self setupLayer];
    [self setupContext];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self setupShader];
    [self setupVBOS];
    [self render:nil];
    [self setupDisplayLink];
}

+(Class)layerClass
{
    return [CAEAGLLayer class];
}

-(void)setupLayer
{
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES;
}

-(void)setupContext
{
    _renderContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_renderContext];
}

-(void)setupRenderBuffer
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_renderContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

-(void)setupFrameBuffer
{
    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
}

-(void)setupShader
{
    [OpenGlShaderUtil checkGLError:@"setupShader begine error"];
    _shaderProgram = [OpenGlShaderUtil createProgramWithVertexShaderFilepath:@"vertexShader.vs" withFragmentShaderFilepath:@"fragmentShader.fs"];
    [OpenGlShaderUtil checkGLError:@""];
    
    glUseProgram(_shaderProgram);
    _positionHandler = glGetAttribLocation(_shaderProgram, "position");
    _colorHandler = glGetAttribLocation(_shaderProgram, "sourceColor");
    
    _modelMatrixHandler = glGetUniformLocation(_shaderProgram, "m");
    _viewMatixHandler = glGetUniformLocation(_shaderProgram, "v");
    _projectMatrixHandler = glGetUniformLocation(_shaderProgram, "p");
    
    glEnableVertexAttribArray(_positionHandler);
    glEnableVertexAttribArray(_colorHandler);
    
    glEnableVertexAttribArray(_modelMatrixHandler);
    glEnableVertexAttribArray(_viewMatixHandler);
    glEnableVertexAttribArray(_projectMatrixHandler);
    
    [OpenGlShaderUtil checkGLError:@"setupShader end error"];
    
}

-(void)setupVBOS
{
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(vertexIndex), vertexIndex, GL_STATIC_DRAW);
    
    
    _modelMatrix = GLKMatrix4Identity;
    _modelMatrix = GLKMatrix4Scale(GLKMatrix4Identity, 0.5, 0.5, 0.5);
    _viewMatix = GLKMatrix4Identity;
    _projectMatrix = GLKMatrix4Identity;
//    CGSize size = self.bounds.size;
//    float aspect = fabs(size.width / size.height);
//    _projectMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0), aspect, -10.0f, 10.f);
//    float h = 4.0f * self.frame.size.height / self.frame.size.width;
//    _projectMatrix = GLKMatrix4MakeFrustum(-2, 2, -h/2, h/2, 4, 10);
}

// Add new method before init
- (void)setupDisplayLink {
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}


-(void)render:(CADisplayLink *)displayLink
{
    if (displayLink) {
        _modelMatrix = GLKMatrix4RotateX(_modelMatrix, GLKMathDegreesToRadians(1));
        _modelMatrix = GLKMatrix4RotateZ(_modelMatrix, GLKMathDegreesToRadians(1)); //GLKMatrix4MakeYRotation(GLKMathDegreesToRadians(5));
    }
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    glUseProgram(_shaderProgram);
    glUniformMatrix4fv(_modelMatrixHandler, 1, 0, _modelMatrix.m);
    glUniformMatrix4fv(_viewMatixHandler, 1, 0, _viewMatix.m);
    glUniformMatrix4fv(_projectMatrixHandler, 1, 0, _projectMatrix.m);
    
    
    glVertexAttribPointer(_positionHandler, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    
    glVertexAttribPointer(_colorHandler, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)(sizeof(float) * 3));
    
    glDrawElements(GL_TRIANGLES, sizeof(vertexIndex)/sizeof(vertexIndex[0]), GL_UNSIGNED_BYTE, 0);
    
    [_renderContext presentRenderbuffer:GL_RENDERBUFFER];
}

@end
