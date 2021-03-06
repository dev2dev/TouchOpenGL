//
//  COBJRenderer.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/16/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "COBJRenderer.h"

#import "CVertexBuffer.h"
#import "CVertexBufferReference.h"
#import "COpenGLAssetLibrary.h"
#import "CProgram.h"
#import "Color_OpenGLExtensions.h"
#import "CTexture.h"
#import "CMaterial.h"
#import "CRenderer_Extensions.h"
#import "CMesh.h"
#import "CMeshLoader.h"
#import "CGeometry.h"
#import "CVertexArrayBuffer.h"
#import "CLight.h"
#import "CCamera.h"

#define USE_PERSPECTIVE 0
#define DRAW_AXES 0
#define DRAW_BOUNDING_BOX 0

@interface COBJRenderer ()
@property (readwrite, nonatomic, retain) CProgram *lightingProgram;
@end

@implementation COBJRenderer

@synthesize camera;
@synthesize light;
@synthesize defaultMaterial;
@synthesize modelTransform;
@synthesize defaultProgramName;

@synthesize mesh;
@synthesize lightingProgram;

- (id)init
	{
	if ((self = [super init]) != NULL)
		{
        camera = [[CCamera alloc] init];
        camera.position = (Vector4){ .x = 0, .y = 0, .z = -10 };
        camera.xSize = 6.27450991f;
        camera.ySize = 8;
        camera.zSize = 8;
        
        light = [[CLight alloc] init];
        light.position = camera.position;
        defaultMaterial = [[CMaterial alloc] init];
        modelTransform = Matrix4Identity;
        defaultProgramName = [@"Lighting_PerPixel" retain];        
		}
	return(self);
	}

- (void)dealloc
    {
    [camera release];
    camera = NULL;
    
    [light release];
    light = NULL;
    
    [defaultMaterial release];
    defaultMaterial = NULL;

    [defaultProgramName release];
    defaultProgramName = NULL;
    
    [mesh release];
    mesh = NULL;
    
    [lightingProgram release];
    lightingProgram = NULL;

    if (_depthValues) {
        free(_depthValues);
    }
    //
    [super dealloc];
    }

- (void)setup
    {
    [super setup];
    //
    NSString *theProgramName = self.mesh.programName;
    if (theProgramName.length == 0)
        {
        theProgramName = self.defaultProgramName;
        }
    self.lightingProgram = [[[CProgram alloc] initWithName:theProgramName attributeNames:[NSArray arrayWithObjects:@"a_position", @"a_normal", NULL] uniformNames:[NSArray arrayWithObjects:@"u_modelViewMatrix", @"u_projectionMatrix", @"u_lightSource", @"u_lightModel", @"u_cameraPosition", @"s_texture0", NULL]] autorelease];

    // #### Set up lighting
	CProgram *theProgram = self.lightingProgram;
	glUseProgram(theProgram.name);

    GLuint theUniform = 0;

    // #### Light sources
    theUniform = [theProgram uniformIndexForName:@"u_lightSource.ambient"];
    if (theUniform != 0)
        {
        Color4f theColor = self.light.ambientColor;
        glUniform4fv(theUniform, 1, &theColor.r);
        }

    theUniform = [theProgram uniformIndexForName:@"u_lightSource.diffuse"];
    if (theUniform != 0)
        {
        Color4f theColor = self.light.diffuseColor;
        glUniform4fv(theUniform, 1, &theColor.r);
        }

    theUniform = [theProgram uniformIndexForName:@"u_lightSource.specular"];
    if (theUniform != 0)
        {
        Color4f theColor = self.light.specularColor;
        glUniform4fv(theUniform, 1, &theColor.r);
        }

    theUniform = [theProgram uniformIndexForName:@"u_lightSource.position"];
    if (theUniform != 0)
        {
        Vector4 theVector = self.light.position;
        glUniform4fv(theUniform, 1, &theVector.x);
        }

    // #### Light model
    if (theUniform != 0)
        {
        theUniform = [theProgram uniformIndexForName:@"u_lightModel.ambient"];
        glUniform4f(theUniform, 0.2, 0.2, 0.2, 1.0);
        }

    }

- (void)prerender
    {
    [super prerender];


    const float kSinMinus60Degrees = -0.866025404f;
    const float kCosMinus60Degrees = 0.5f;
    Vector3 cameraPosition = Vector3FromVector4(self.camera.position);
    GLfloat cameraDistance = Vector3Length(cameraPosition);
    GLfloat r = cameraDistance / kCosMinus60Degrees;
    if (r > 0.0f) {
        // Get an axis, A, that isn't parallel to the camera position, Cam.
        // Then Y = Cam x A is perpendicular to Cam.
        // Put the light in a position such that it makes a 60 degree
        // angle with Cam in the plane defined by (Cam, Y).
        Vector3 A;
        if (cameraPosition.y != 0.0f || cameraPosition.z != 0.0f) {
            // Camera position does not lie along the x-axis.  Put A on the x-axis.
            A.x = 1.0f;
            A.y = 0.0f;
            A.z = 0.0f;
        } else {
            // Camera position lies along the x-axis.  Put A on the (minus) z-axis.
            A.x = 0.0f;
            A.y = 0.0f;
            A.z = -1.0f;
        }
        Vector3 Y = Vector3Normalize(Vector3CrossProduct(cameraPosition, A));
        Vector3 X = Vector3Normalize(cameraPosition);
        Vector3 lightPosition;
        lightPosition.x = r * (X.x * kCosMinus60Degrees + Y.x * kSinMinus60Degrees);
        lightPosition.y = r * (X.y * kCosMinus60Degrees + Y.y * kSinMinus60Degrees);
        lightPosition.z = r * (X.z * kCosMinus60Degrees + Y.z * kSinMinus60Degrees);
        self.light.position = (Vector4) { lightPosition.x, lightPosition.y, lightPosition.z, 0.0f };
    } else {
        // Camera is at the origin, just put the light any old place.
        self.light.position = (Vector4) { 0.0f, 0.0f, -10.0f, 0.0f };
    }

    self.projectionTransform = self.camera.transform;
    }

- (void)render
    {
    AssertOpenGLValidContext_();
    
    AssertOpenGLNoError_();

    if (self.mesh.cullBackFaces == YES)
        {
        glCullFace(GL_BACK);
        glEnable(GL_CULL_FACE);
        }
    else
        {
        glDisable(GL_CULL_FACE);
        }

    Matrix4 theModelTransform = Matrix4Concat(self.mesh.transform, self.modelTransform);
    Matrix4 theProjectionTransform = self.projectionTransform;

#if DRAW_AXES
    [self drawAxes:theModelTransform];
#endif
    
	Vector3 theCenter = self.mesh.center;
	theModelTransform = Matrix4Concat(Matrix4MakeTranslation(-theCenter.x, -theCenter.y, -theCenter.z), theModelTransform);

#if DRAW_BOUNDING_BOX
	Vector3 P1 = self.mesh.p1;
	Vector3 P2 = self.mesh.p2;
    [self drawBoundingBox:theModelTransform v1:P1 v2:P2];
#endif

    [self drawBackgroundGradient];

	// #### Use shader program
	CProgram *theProgram = self.lightingProgram;
	glUseProgram(theProgram.name);

    GLuint theUniform = 0;

    // #### Update transform uniform
    theUniform = [theProgram uniformIndexForName:@"u_modelViewMatrix"];
    glUniformMatrix4fv(theUniform, 1, NO, &theModelTransform.m[0][0]);

    theUniform = [theProgram uniformIndexForName:@"u_projectionMatrix"];
    glUniformMatrix4fv(theUniform, 1, NO, &theProjectionTransform.m[0][0]);

    AssertOpenGLNoError_();
    
    // #### Now render each geometry in mesh.
	for (CGeometry *theGeometry in self.mesh.geometries)
		{
        // #### Material
        CMaterial *theMaterial = theGeometry.material;
        if (theMaterial == NULL)
            {
            theMaterial = self.defaultMaterial;
            }
        
        theUniform = [theProgram uniformIndexForName:@"u_frontMaterial.ambient"];
        if (theUniform != 0)
            {
            Color4f theColor = theMaterial.ambientColor;
            glUniform4fv(theUniform, 1, &theColor.r);
            }

        theUniform = [theProgram uniformIndexForName:@"u_frontMaterial.diffuse"];
        if (theUniform != 0)
            {
            Color4f theColor = theMaterial.diffuseColor;
            glUniform4fv(theUniform, 1, &theColor.r);
            }

        theUniform = [theProgram uniformIndexForName:@"u_frontMaterial.specular"];
        if (theUniform != 0)
            {
            Color4f theColor = theMaterial.specularColor;
            glUniform4fv(theUniform, 1, &theColor.r);
            }

        theUniform = [theProgram uniformIndexForName:@"u_frontMaterial.shininess"];
        if (theUniform != 0)
            {
            glUniform1f(theUniform, theMaterial.shininess);    
            }

        theUniform = [theProgram uniformIndexForName:@"u_cameraPosition"];
        if (theUniform != 0)
            {
            Vector4 theCameraPosition = self.camera.position;            
            glUniform4fv(theUniform, 1, &theCameraPosition.x);
            }

        if (theMaterial.texture != NULL)
            {
            theUniform = [theProgram uniformIndexForName:@"s_texture0"];
            if (theUniform != 0)
                {
                glActiveTexture(GL_TEXTURE0);
                glBindTexture(GL_TEXTURE_2D, theMaterial.texture.name);
                glUniform1i(theUniform, 0);
                }
            }
        else
            {
            theUniform = [theProgram uniformIndexForName:@"s_texture0"];
            if (theUniform != 0)
                {
                glActiveTexture(GL_TEXTURE0);
                glBindTexture(GL_TEXTURE_2D, 0);
                }
            }

        // #### Vertices
        [theGeometry.vertexArrayBuffer bind];
        
        if (theGeometry.vertexArrayBuffer == NULL || theGeometry.vertexArrayBuffer.populated == NO)
            {
            // Update position attribute
            NSAssert(theGeometry.positions != NULL, @"No positions.");
            GLuint theAttributesIndex = [theProgram attributeIndexForName:@"a_position"];        
            [theGeometry.positions use:theAttributesIndex];
            glEnableVertexAttribArray(theAttributesIndex);

            // Update normal attribute
            NSAssert(theGeometry.normals != NULL, @"No normals.");
            theAttributesIndex = [theProgram attributeIndexForName:@"a_normal"];        
            [theGeometry.normals use:theAttributesIndex];
            glEnableVertexAttribArray(theAttributesIndex);

            // Update texcoord attribute
            if (theMaterial.texture != NULL)
                {
                NSAssert(theMaterial.texture.isValid == YES, @"Invalid texture");
                
                NSAssert(theGeometry.texCoords != NULL, @"No tex coords.");
                theAttributesIndex = [theProgram attributeIndexForName:@"a_texCoord"];        
                [theGeometry.texCoords use:theAttributesIndex];
                glEnableVertexAttribArray(theAttributesIndex);
                            
                AssertOpenGLNoError_();
                }
            
            theGeometry.vertexArrayBuffer.populated = YES;

            if (theGeometry.indices != NULL)
                {
                [theGeometry.indices bind];
                }
            }

		AssertOpenGLNoError_();

        // Validate program before drawing. This is a good check, but only really necessary in a debug build. DEBUG macro must be defined in your debug configurations if that's not already the case.
        #if defined(DEBUG)
            NSError *theError = NULL;
            if ([theProgram validate:&theError] == NO)
                {
                NSLog(@"Failed to validate program: %@", theError);
                return;
                }
        #endif

        if (theGeometry.indices == NULL)
            {
            glDrawArrays(GL_TRIANGLES, 0, theGeometry.positions.rowCount);
            }
        else
            {
            glDrawElements(GL_TRIANGLES, theGeometry.indices.rowCount, GL_UNSIGNED_SHORT, 0);
            }
		}

    #if TARGET_OS_IPHONE
    glBindVertexArrayOES(0);
    #endif /* TARGET_OS_IPHONE */

    #if TARGET_OS_IPHONE == 0
    SIntSize size = self.size;
    glReadPixels(0, 0, size.width, size.height, GL_DEPTH_COMPONENT, GL_FLOAT, _depthValues);
    #endif /* TARGET_OS_IPHONE */
    }

- (void)setSize:(SIntSize)size
{
    [super setSize:size];

    if (_depthValues) {
        free(_depthValues);
    }
    _depthValues = (GLfloat *)malloc(sizeof(GLfloat) * size.width * size.height);
}

- (float)depthAtPoint:(CGPoint)point
{
    GLint x = (GLint)point.x;
    GLint y = (GLint)point.y;
    SIntSize size = self.size;
    if (x >= size.width || y >= size.height) {
        return 0.0f;
    }
    GLfloat theZSize = self.camera.zSize;
    GLfloat rawDepth = _depthValues[x + size.width * y];
    return -(rawDepth * theZSize * 2.0f - theZSize);
}

@end
