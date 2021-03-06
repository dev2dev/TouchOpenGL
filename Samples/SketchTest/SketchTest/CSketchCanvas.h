//
//  CSketchCanvas.h
//  TouchOpenGL
//
//  Created by Jonathan Wight on 02/15/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CImageRenderer;

@interface CSketchCanvas : NSObject {
    
}

@property (readwrite, nonatomic, assign) CGSize size;
@property (readwrite, nonatomic, retain) CImageRenderer *imageRenderer;

- (void)drawAtPoint:(CGPoint)inPoint;

@end
