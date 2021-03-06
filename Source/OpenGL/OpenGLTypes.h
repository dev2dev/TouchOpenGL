//
//  OpenGLTypes.h
//  TouchOpenGL
//
//  Created by Jonathan Wight on 1/1/2000.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "OpenGLIncludes.h"

typedef struct Vector2 {
    GLfloat x, y;
    } Vector2;

typedef struct Vector3 {
    GLfloat x, y, z;
    } Vector3;

typedef struct Vector4 {
    GLfloat x, y, z, w;
    } Vector4;

typedef struct Color4ub {
    GLubyte r,g,b,a;
    } Color4ub;

typedef struct Color4f {
    GLfloat r,g,b,a;
    } Color4f;

typedef struct Color3ub {
    GLubyte r,g,b;
    } Color3ub;

typedef struct Color3f {
    GLfloat r,g,b;
    } Color3f;

typedef struct SIntPoint {
    GLint x, y;
    } SIntPoint;

typedef struct SIntSize {
    GLint width, height;
    } SIntSize;

// TODO -- inline these suckers.

extern GLfloat DegreesToRadians(GLfloat inDegrees);
extern GLfloat RadiansToDegrees(GLfloat inDegrees);

#define D2R(v) DegreesToRadians((v))
#define R2D(v) RadiansToDegrees((v))

extern GLfloat Vector3Length(Vector3 inVector);
extern Vector3 Vector3CrossProduct(Vector3 inLHS, Vector3 inRHS);
extern GLfloat Vector3DotProduct(Vector3 inLHS, Vector3 inRHS);
extern Vector3 Vector3Normalize(Vector3 inVector);
extern Vector3 Vector3Add(Vector3 inLHS, Vector3 inRHS);
extern Vector3 Vector3FromVector4(Vector4 inVector);

extern NSString *NSStringFromVector3(Vector3 inVector);
extern NSString *NSStringFromVector4(Vector4 inVector);

extern Color4f Color4fFromPropertyListRepresentation(id inPropertyListRepresentation);

extern Vector3 Vector3FromPropertyListRepresentation(id inPropertyListRepresentation);

extern GLenum GLenumFromString(NSString *inString);
extern NSString *NSStringFromGLenum(GLenum inEnum);

#if DEBUG == 1

#define AssertOpenGLNoError_() do { GLint theError = glGetError(); if (theError != GL_NO_ERROR) NSLog(@"glGetError() returned %@ (0x%X)", NSStringFromGLenum(theError), theError); NSAssert1(theError == GL_NO_ERROR, @"Code entered with existing OGL error 0x%X", theError); } while(0)

#if TARGET_OS_IPHONE == 1

#define AssertOpenGLValidContext_() NSAssert([EAGLContext currentContext] != NULL, @"No current context")

#else

#define AssertOpenGLValidContext_() NSAssert(CGLGetCurrentContext() != NULL, @"No current context")

#endif /* TARGET_OS_IPHONE == 1 */

#else

#define AssertOpenGLNoError_()
#define AssertOpenGLValidContext_()

#endif /* DEBUG == 1 */
