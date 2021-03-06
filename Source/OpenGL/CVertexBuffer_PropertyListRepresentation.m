//
//  CVertexBuffer_PropertyListRepresentation.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/21/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CVertexBuffer_PropertyListRepresentation.h"

#import "OpenGLTypes.h"
#import "NSData_NumberExtensions.h"

#define NO_DEFAULTS 1

@implementation CVertexBuffer (CVertexBuffer_PropertyListRepresentation)

- (id)initWithPropertyListRepresentation:(id)inRepresentation error:(NSError **)outError;
    {
    NSString *theString = [(NSDictionary *)inRepresentation objectForKey:@"target"];
    NSAssert(NO_DEFAULTS && theString.length > 0, @"No target specified.");
    GLenum theTarget = GLenumFromString(theString) ?: GL_ARRAY_BUFFER;
    
    theString = [(NSDictionary *)inRepresentation objectForKey:@"usage"];
    NSAssert(NO_DEFAULTS && theString.length > 0, @"No usage specified.");
    GLenum theUsage = GLenumFromString(theString) ?: GL_STATIC_DRAW;
    
    NSData *theData = NULL;

    if ((theString = [(NSDictionary *)inRepresentation objectForKey:@"floats"]) != NULL && theString.length > 0)
        {
        theData = [NSData dataWithNumbersInString:theString type:kCFNumberFloat32Type error:outError];
        if (theData == NULL)
            {
            return(NULL);
            }
        }
    else if ((theString = [(NSDictionary *)inRepresentation objectForKey:@"shorts"]) != NULL && theString.length > 0)
        {
        theData = [NSData dataWithNumbersInString:theString type:kCFNumberShortType error:outError];
        if (theData == NULL)
            {
            return(NULL);
            }
        }
    else
        {
        NSString *theHREF = [(NSDictionary *)inRepresentation objectForKey:@"href"];
        
        NSURL *theURL = [[NSBundle mainBundle] URLForResource:theHREF withExtension:NULL];
        theData = [NSData dataWithContentsOfURL:theURL];
        }

	if ((self = [self initWithTarget:theTarget usage:theUsage data:theData]) != NULL)
		{
		}
	return(self);
	}

@end
