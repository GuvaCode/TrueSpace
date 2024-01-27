// Shader SkyBox 
SkyBoxVs := '#version 330'                             + #10 + #13 +
            'in vec3 vertexPosition;'                    + #10 + #13 +
            'uniform mat4 matProjection;'                + #10 + #13 +
            'uniform mat4 matView;'                      + #10 + #13 +
            'out vec3 fragPosition;'                     + #10 + #13 +
            'void main()'                                + #10 + #13 +
            '{'                                          + #10 + #13 +
            'fragPosition = vertexPosition;'             + #10 + #13 +
            'mat4 rotView = mat4(mat3(matView));'        + #10 + #13 +
            'vec4 clipPos = matProjection*rotView*vec4(vertexPosition, 1.0);' + #10 + #13 +
            'gl_Position = clipPos;' + #10 + #13 +
            '}';

SkyBoxFs := '#version 330'                              + #10 + #13 +
            'in vec3 fragPosition;'                       + #10 + #13 +
            'uniform samplerCube environmentMap;'         + #10 + #13 +
            'uniform bool vflipped;'                      + #10 + #13 +
            'uniform bool doGamma;'                       + #10 + #13 +
            'out vec4 finalColor;'                        + #10 + #13 +
            'void main()'                                 + #10 + #13 +
            '{'                                           + #10 + #13 +
            'vec3 color = vec3(0.0);'                     + #10 + #13 +
            'if (vflipped) color = texture(environmentMap, vec3(fragPosition.x, -fragPosition.y, fragPosition.z)).rgb;'   + #10 + #13 +
            'else color = texture(environmentMap, fragPosition).rgb;'  + #10 + #13 +
            'if (doGamma)'                                + #10 + #13 +
            '{'                                           + #10 + #13 +
            'color = color/(color + vec3(1.0));'          + #10 + #13 +
            'color = pow(color, vec3(1.0/2.2));'          + #10 + #13 +
            '}'                                           + #10 + #13 +
            'finalColor = vec4(color, 1.0);'              + #10 + #13 +
            '}';


