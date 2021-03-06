//
//  OpenGLTypes.h
//  TouchOpenGL
//
//  Created by Jonathan Wight on 9/7/2010.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//


#import "OpenGLIncludes.h"

typedef struct Matrix4 {
    GLfloat m[4][4];
} Matrix4;

typedef struct Matrix3 {
    GLfloat m[3][3];
} Matrix3;



extern const Matrix4 Matrix4Identity;

extern BOOL Matrix4IsIdentity(Matrix4 t);
extern BOOL Matrix4EqualToTransform(Matrix4 a, Matrix4 b);
extern Matrix4 Matrix4MakeTranslation(GLfloat tx, GLfloat ty, GLfloat tz);
extern Matrix4 Matrix4MakeScale(GLfloat sx, GLfloat sy, GLfloat sz);
extern Matrix4 Matrix4MakeRotation(GLfloat angle, GLfloat x, GLfloat y, GLfloat z);
extern Matrix4 Matrix4Translate(Matrix4 t, GLfloat tx, GLfloat ty, GLfloat tz);
extern Matrix4 Matrix4Scale(Matrix4 t, GLfloat sx, GLfloat sy, GLfloat sz);
extern Matrix4 Matrix4Rotate(Matrix4 t, GLfloat angle, GLfloat x, GLfloat y, GLfloat z);
extern Matrix4 Matrix4Concat(Matrix4 a, Matrix4 b);
extern Matrix4 Matrix4Invert(Matrix4 t);
extern Matrix4 Matrix4Transpose(Matrix4 t);
extern NSString *NSStringFromMatrix4(Matrix4 t);

extern Matrix4 Matrix4FromPropertyListRepresentation(id inPropertyListRepresentation);

extern Matrix4 Matrix4Perspective(GLfloat fovy, GLfloat aspect, GLfloat zNear, GLfloat zFar);
extern Matrix4 Matrix4Ortho(float left, float right, float bottom, float top, float nearZ, float farZ);

extern Matrix3 Matrix3FromMatrix4Lossy(Matrix4 inM4);