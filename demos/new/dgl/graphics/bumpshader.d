/*
Copyright (c) 2015 Timur Gafarov 

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

module dgl.graphics.bumpshader;

import dlib.core.memory;
import dgl.core.event;
import dgl.graphics.shader;
import dgl.graphics.glslshader;

// TODO: shadow support

private string _bumpVertexShader = q{
    varying vec3 position;
    varying vec3 n, t, b;
		
    void main(void)
    {
        gl_TexCoord[0] = gl_MultiTexCoord0;
        gl_TexCoord[1] = gl_MultiTexCoord1;

        n = normalize(gl_NormalMatrix * gl_Normal);
        t = normalize(gl_NormalMatrix * gl_Color.xyz);
        b = cross(n, t);
	    vec4 pos = gl_ModelViewMatrix * gl_Vertex;
	    position = pos.xyz;
	    gl_Position = ftransform();
    }
};

private string _bumpFragmentShader = q{

    varying vec3 position;
    varying vec3 n, t, b;
		
    uniform sampler2D dgl_Texture0;
    uniform sampler2D dgl_Texture1;
    uniform sampler2D dgl_Texture2;

    void main (void) 
    { 
        vec3 normal = 2.0 * texture2D(dgl_Texture1, gl_TexCoord[0].st).rgb - 1.0;
        normal = normalize(normal);
	
        vec3 V_tan;
        V_tan.x = dot(position, t);
        V_tan.y = dot(position, b);
        V_tan.z = dot(position, n);
        V_tan = -normalize(V_tan);
	
	    float Csh = 64.0; //gl_FrontMaterial.shininess;

        vec3 lightDirection;
        float attenuation; 
        vec3 L_tan;
        const float lightRadiusSqr = 20.0;

        vec4 tex = texture2D(dgl_Texture0, gl_TexCoord[0].st);
        vec4 emit = vec4(0.0, 0.0, 0.0, 1.0);
        if (gl_FrontMaterial.emission.w > 0.0)
            emit = texture2D(dgl_Texture2, gl_TexCoord[0].st) * gl_FrontMaterial.emission.w;
            
        vec4 col = vec4(0.0, 0.0, 0.0, 1.0);
    
        vec3 halfVector;
        float distance;
        float diffuse;
        float specular;

        for (int i = 0; i < 4; i++)
	    {
	        if (gl_LightSource[i].position.w < 2.0)
	        {
	            vec4 Ca = gl_FrontMaterial.ambient * gl_LightSource[i].ambient; 
	            vec4 Cd = gl_FrontMaterial.diffuse * gl_LightSource[i].diffuse; 
	            vec4 Cs = gl_FrontMaterial.specular * gl_LightSource[i].specular;  
            
	            vec3 positionToLightSource = vec3(gl_LightSource[i].position.xyz - position);
	
	            distance = length(positionToLightSource);
            
                lightDirection = normalize(positionToLightSource);
            
                attenuation = clamp(1.0 - distance/lightRadiusSqr, 0.0, 1.0);
   
                L_tan.x = dot(lightDirection, t);
                L_tan.y = dot(lightDirection, b);
                L_tan.z = dot(lightDirection, n);
                L_tan = normalize(L_tan);

	            diffuse = attenuation * max(dot(L_tan, normal), 0.0);
	            vec3 R = -reflect(normal, L_tan); 
	            specular = pow(max(dot(L_tan, normal), 0.0), Csh);
                specular = attenuation * clamp(specular, 0.0, 1.0); 
                
	            col += Ca + (Cd*diffuse) + (Cs*specular*2); 
	        }
	    }

	    gl_FragColor = tex * col + emit;
	    gl_FragColor.a = 1.0;
    }
};

Shader bumpShader(EventManager emgr)
{
    return New!GLSLShader(emgr, _bumpVertexShader, _bumpFragmentShader);
}