//
//  Shader.fsh
//  Racing Genes
//
//  Created by Jonathan Wight on 09/05/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_color;

void main()
    {
    gl_FragColor = v_color;
    }
