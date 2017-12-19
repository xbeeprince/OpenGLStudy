//
//  OpenGlShaderUtil.h
//  OpenGLStudy
//
//  Created by prince on 2017/12/18.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface OpenGlShaderUtil : NSObject

+(void)checkGLError:(NSString *)op;

+(BOOL)checkFileExistForPath:(NSString *)path;

+(GLuint)createProgramWithVertexShaderFilepath:(NSString *)vertexShaderFilepath withFragmentShaderFilepath:(NSString *)fragmentShaderFilepath;
@end
