//
//  OpenGlShaderUtil.m
//  OpenGLStudy
//
//  Created by prince on 2017/12/18.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "OpenGlShaderUtil.h"
#import "FileHander.h"

@implementation OpenGlShaderUtil

+(void)checkGLError:(NSString *)op
{
    int error = glGetError();
    
    if (error != GL_NO_ERROR) {
        NSString *msg = [op stringByAppendingString:[NSString stringWithFormat:@":glError 0x%X",error]];
        
        NSLog(@"%@",msg);
    }
}

+(BOOL)checkFileExistForPath:(NSString *)path
{
    NSString *filePath = [FileHander getPathForResource:path];
    if (filePath) {
        return YES;
    }
    
    return NO;
}

+(GLuint)createProgramWithVertexShaderFilepath:(NSString *)vertexShaderFilepath withFragmentShaderFilepath:(NSString *)fragmentShaderFilepath
{
    // Load the vertex/fragment shaders
    GLuint vertexShader = [self createShaderWithType:GL_VERTEX_SHADER
                                        withFilepath:vertexShaderFilepath];
    if (vertexShader == 0)
        return 0;
    
    GLuint fragmentShader = [self createShaderWithType:GL_FRAGMENT_SHADER
                                          withFilepath:fragmentShaderFilepath];
    if (fragmentShader == 0) {
        glDeleteShader(vertexShader);
        return 0;
    }
    
    // Create the program object
    GLuint programHandle = glCreateProgram();
    if (programHandle == 0)
        return 0;
    
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    
    // Link the program
    glLinkProgram(programHandle);
    
    // Check the link status
    GLint linked;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linked);
    
    if (!linked) {
        GLint infoLen = 0;
        glGetProgramiv(programHandle, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 1){
            char * infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog(programHandle, infoLen, NULL, infoLog);
            
            NSLog(@"Error linking program:\n%s\n", infoLog);
            
            free(infoLog);
        }
        
        glDeleteProgram(programHandle );
        return 0;
    }
    
    // Free up no longer needed shader resources
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    return programHandle;
}

+(GLuint)createShaderWithType:(GLenum)type withFilepath:(NSString *)shaderFilepath
{
    NSString *path = [self getResourceFilePath:shaderFilepath];
    if ([self checkFileExistForPath:path] == NO) {
        NSLog(@"Error: No file:%@", path);
        return 0;
    }
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:path
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
    if (!shaderString) {
        NSLog(@"Error: loading shader file: %@ %@", shaderFilepath, error.localizedDescription);
        return 0;
    }
    
    return [self createShaderWithType:type withString:shaderString];
}

+(GLuint)createShaderWithType:(GLenum)type withString:(NSString *)shaderString
{
    // Create the shader object
    GLuint shader = glCreateShader(type);
    [self checkGLError: @"glCreateShader error"];
    if (shader == 0) {
        NSLog(@"Error: failed to create shader.");
        return 0;
    }
    
    // Load the shader source
    const char * shaderStringUTF8 = [shaderString UTF8String];
    glShaderSource(shader, 1, &shaderStringUTF8, NULL);
    
    // Compile the shader
    glCompileShader(shader);
    
    // Check the compile status
    GLint compiled = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    
    if (!compiled) {
        GLint infoLen = 0;
        glGetShaderiv ( shader, GL_INFO_LOG_LENGTH, &infoLen );
        
        if (infoLen > 1) {
            char * infoLog = malloc(sizeof(char) * infoLen);
            glGetShaderInfoLog (shader, infoLen, NULL, infoLog);
            NSLog(@"Error compiling shader:\n%s\n", infoLog );
            
            free(infoLog);
        }
        
        glDeleteShader(shader);
        return 0;
    }
    
    return shader;
}

+(NSString *)getResourceFilePath:(NSString *)filePath
{
    return [FileHander getPathForResource:filePath inDir:@"resource"];
}

@end
