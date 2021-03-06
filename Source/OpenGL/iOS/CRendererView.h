//
//  EAGLView.h
//  TouchOpenGL
//
//  Created by Jonathan Wight on 09/05/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "CRenderer.h"
#import "OpenGLTypes.h"
#import "Matrix.h"

@class EAGLContext;
@class CAEAGLLayer;
@class CFrameBuffer;
@class CRenderBuffer;

@interface CRendererView : UIView {    
}

@property (readwrite, nonatomic, assign) SIntSize backingSize;
@property (readwrite, nonatomic, retain) EAGLContext *context;
@property (readwrite, nonatomic, assign) NSInteger animationFrameInterval;
@property (readwrite, nonatomic, retain) CRenderer *renderer;
@property (readwrite, nonatomic, assign) BOOL multisampleAntialiasing;

@property (readonly, nonatomic, assign) BOOL animating;

@property (readwrite, nonatomic, retain) CFrameBuffer *frameBuffer;
@property (readwrite, nonatomic, retain) CRenderBuffer *colorRenderBuffer;
@property (readwrite, nonatomic, retain) CRenderBuffer *depthRenderBuffer;

@property (readwrite, nonatomic, retain) CFrameBuffer *sampleFrameBuffer;
@property (readwrite, nonatomic, retain) CRenderBuffer *sampleColorRenderBuffer;
@property (readwrite, nonatomic, retain) CRenderBuffer *sampleDepthRenderBuffer;




- (void)startAnimation;
- (void)stopAnimation;

- (void)render;

@end
