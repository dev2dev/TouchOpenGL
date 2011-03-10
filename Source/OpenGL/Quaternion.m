//
//  Quaternion.m
//  ModelViewer
//
//  Created by Jonathan Wight on 03/10/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#include "Quaternion.h"

#include <tgmath.h>

#import "OpenGLIncludes.h"
#import "OpenGLTypes.h"
#import "Matrix.h"

// Based on http://code.google.com/p/libgdx/source/browse/trunk/gdx/src/com/badlogic/gdx/math/Quaternion.java

#define NORMALIZATION_TOLERANCE 0.00001f

typedef struct {
    GLfloat x, y, z, w;
} Quaternion;

Quaternion QuaternionIdentity = { .x = 0.0, .y = 0.0, .z = 0.0, .w = 1.0 };

Quaternion QuaternionNormalize(Quaternion q);

Quaternion QuaternionSetAxisAngle(Vector3 inAxis, GLfloat inAngle)
    {
    const GLfloat l_sin = sin(inAngle * 0.5);
    const GLfloat l_cos = cos(inAngle * 0.5);
    Quaternion theQuat = { .x = inAxis.x * l_sin, .y = inAxis.y * l_sin, .z = inAxis.z * l_sin, .w = l_cos };
    theQuat = QuaternionNormalize(theQuat);
    return(theQuat);
    }

GLfloat QuaternionLength2(Quaternion inQuat)
    {
    return(inQuat.x * inQuat.x + inQuat.y * inQuat.y + inQuat.z * inQuat.z + inQuat.w * inQuat.w);
    }
        
Quaternion QuaternionNormalize(Quaternion inQuat)
    {
    GLfloat len = QuaternionLength2(inQuat);
    if (len != 0.0f && fabs(len - 1.0f) > NORMALIZATION_TOLERANCE)
        {
        len = sqrt(len);
        inQuat.w /= len;
        inQuat.x /= len;
        inQuat.y /= len;
        inQuat.z /= len;
        }
    return(inQuat);
    }
    
Quaternion QuaternionSetEuler(GLfloat inYaw, GLfloat inPitch, GLfloat inRoll)
    {
    const GLfloat num9 = inRoll * 0.5f;
    const GLfloat num6 = sin(num9);
    const GLfloat num5 = cos(num9);
    const GLfloat num8 = inPitch * 0.5f;
    const GLfloat num4 = sin(num8);
    const GLfloat num3 = cos(num8);
    const GLfloat num7 = inYaw * 0.5f;
    const GLfloat num2 = sin(num7);
    const GLfloat num = cos(num7);
    const Quaternion q = {
        .x = ((num * num4) * num5) + ((num2 * num3) * num6),
        .y = ((num2 * num3) * num5) - ((num * num4) * num6),
        .z = ((num * num3) * num6) - ((num2 * num4) * num5),
        .w = ((num * num3) * num5) + ((num2 * num4) * num6),
        };
    return(q);
    }
    
Quaternion QuaternionConjugate(Quaternion q)
    {
    q.x *= -1;
    q.y *= -1;
    q.z *= -1;
    return(q);
    }
        
Quaternion QuaternionMultiply(Quaternion inLHS, Quaternion inRHS)
    {
    Quaternion theResult = {
        .x = inLHS.w * inRHS.x + inLHS.x * inRHS.w + inLHS.y * inRHS.z - inLHS.z * inRHS.y,
        .y = inLHS.w * inRHS.y + inLHS.y * inRHS.w + inLHS.z * inRHS.x - inLHS.x * inRHS.z,
        .z = inLHS.w * inRHS.z + inLHS.z * inRHS.w + inLHS.x * inRHS.y - inLHS.y * inRHS.x,
        .w = inLHS.w * inRHS.w - inLHS.x * inRHS.x - inLHS.y * inRHS.y - inLHS.z * inRHS.z,
        };
    return(theResult);
    }    
    
Matrix4 Matrix4FromQuaternion(Quaternion q)
    {
    const GLfloat xx = q.x * q.x;
    const GLfloat xy = q.x * q.y;
    const GLfloat xz = q.x * q.z;
    const GLfloat xw = q.x * q.w;
    const GLfloat yy = q.y * q.y;
    const GLfloat yz = q.y * q.z;
    const GLfloat yw = q.y * q.w;
    const GLfloat zz = q.z * q.z;
    const GLfloat zw = q.z * q.w;
    
    Matrix4 theMatrix = {
        .m00 = 1.0 - 2.0 * (yy + zz),
        .m01 = 2.0 * (xy - zw),
        .m02 = 2.0 * (xz + yw),
        .m03 = 0.0,
        .m10 = 2.0 * (xy + zw),
        .m11 = 1.0 - 2.0 * (xx + zz),
        .m12 = 2.0 * (yz - xw),
        .m13 = 0.0,
        .m20 = 2.0 * (xz - yw),
        .m21 = 2.0 * (yz + xw),
        .m22 = 1.0 - 2.0 * (xx + yy),
        .m23 = 0.0,
        .m30 = 0.0,
        .m31 = 0.0,
        .m32 = 0.0,
        .m33 = 1.0,
        };
    return(theMatrix);
    }


