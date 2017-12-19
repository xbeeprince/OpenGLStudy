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

typedef struct {
    float position[4];
    float color[4];
    
}Vertex;

const Vertex vertex[] = {
    {{1, -1, 0, 1}, {1, 0, 0, 1}},
    {{1, 1, 0, 1}, {0, 1, 0, 1}},
    {{-1, 1, 0, 1}, {0, 0, 1, 1}},
    {{-1, -1, 0, 1}, {0, 0, 0, 1}}
};

const GLubyte vertexIndex[] = {
    0,1,2,
    2,3,0
};

@interface OpenGlRenderView()
@property(nonatomic,strong)CAEAGLLayer *eaglLayer;
@property(nonatomic,strong)EAGLContext *renderContext;
@property(nonatomic,assign)GLuint colorRenderBuffer;
@property(nonatomic,assign)GLuint shaderProgram;
@property(nonatomic,assign)GLuint positionHandler;
@property(nonatomic,assign)GLuint colorHandler;

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
    [self render];
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
    
    glEnableVertexAttribArray(_positionHandler);
    glEnableVertexAttribArray(_colorHandler);
    
    [OpenGlShaderUtil checkGLError:@"setupShader end error"];
    
}

-(void)setupVBOS
{
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertex), vertex, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(vertexIndex), vertexIndex, GL_STATIC_DRAW);
}

-(void)render
{
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    glVertexAttribPointer(_positionHandler, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    
    glVertexAttribPointer(_colorHandler, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)(sizeof(float) * 4));
    
    glDrawElements(GL_TRIANGLES, sizeof(vertexIndex)/sizeof(vertexIndex[0]), GL_UNSIGNED_BYTE, 0);
    
    [_renderContext presentRenderbuffer:GL_RENDERBUFFER];
}

@end
