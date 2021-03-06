//
//  CFrameBuffer.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 02/15/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CFrameBuffer.h"

#import "CRenderBuffer.h"

#import "CTexture.h"

@implementation CFrameBuffer

@synthesize name;

- (id)init
	{
	if ((self = [super init]) != NULL)
		{
        glGenFramebuffers(1, &name);

        AssertOpenGLNoError_();
		}
	return(self);
	}

- (void)dealloc
    {
    if (glIsFramebuffer(name))
        {
        NSLog(@"FOO");
        glDeleteFramebuffers(1, &name);
        name = 0;
        }
    //
    [super dealloc];
    }

- (BOOL)isComplete:(GLenum)inTarget
    {
    NSAssert(glIsFramebuffer(name), @"name is not a framebuffer");
    GLenum theStatus = glCheckFramebufferStatus(inTarget);
    return(theStatus == GL_FRAMEBUFFER_COMPLETE);
    }

- (void)bind:(GLenum)inTarget
    {
    glBindFramebuffer(inTarget, self.name);
    }

- (void)attachRenderBuffer:(CRenderBuffer *)inRenderBuffer attachment:(GLenum)inAttachment
    {
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, inAttachment, GL_RENDERBUFFER, inRenderBuffer.name);
    AssertOpenGLNoError_();
    }
    
- (void)attachTexture:(CTexture *)inTexture attachment:(GLenum)inAttachment
    {
    glFramebufferTexture2D(GL_FRAMEBUFFER, inAttachment, GL_TEXTURE_2D, inTexture.name, 0);
    AssertOpenGLNoError_();
    }

@end
