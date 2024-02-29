// Shader ShadowMap
shadowMapVs := '#version 330' + #10 + #13 +
            'in vec3 vertexPosition;' + #10 + #13 +
            'in vec2 vertexTexCoord;' + #10 + #13 +
            'in vec3 vertexNormal;' + #10 + #13 +
            'in vec4 vertexColor;' + #10 + #13 +
            'uniform mat4 mvp;' + #10 + #13 +
            'uniform mat4 matModel;' + #10 + #13 +
            'uniform mat4 matNormal;' + #10 + #13 +
            'out vec3 fragPosition;' + #10 + #13 +
            'out vec2 fragTexCoord;' + #10 + #13 +
            'out vec4 fragColor;' + #10 + #13 +
            'out vec3 fragNormal;' + #10 + #13 +
            'void main()' + #10 + #13 +
            '{' + #10 + #13 +
            'fragPosition = vec3(matModel*vec4(vertexPosition, 1.0));' + #10 + #13 +
            'fragTexCoord = vertexTexCoord;' + #10 + #13 +
            'fragColor = vertexColor;' + #10 + #13 +
            'fragNormal = normalize(vec3(matNormal*vec4(vertexNormal, 1.0)));' + #10 + #13 +
            'gl_Position = mvp*vec4(vertexPosition, 1.0);' + #10 + #13 +
            '}';

shadowMapFs := '#version 330' + #10 + #13 +
            'in vec3 fragPosition;' + #10 + #13 +
            'in vec2 fragTexCoord;' + #10 + #13 +
            'in vec3 fragNormal;' + #10 + #13 +
            'uniform sampler2D texture0;' + #10 + #13 +
            'uniform vec4 colDiffuse;' + #10 + #13 +
            'out vec4 finalColor;' + #10 + #13 +
            'uniform vec3 lightDir;' + #10 + #13 +
            'uniform vec4 lightColor;' + #10 + #13 +
            'uniform vec4 ambient;' + #10 + #13 +
            'uniform vec3 viewPos;' + #10 + #13 +
            'uniform mat4 lightVP;' + #10 + #13 + 
            'uniform sampler2D shadowMap;' + #10 + #13 +
            'uniform int shadowMapResolution;' + #10 + #13 +
            'void main()' + #10 + #13 +
            '{' + #10 + #13 +
            'vec4 texelColor = texture(texture0, fragTexCoord);' + #10 + #13 +
            'vec3 lightDot = vec3(0.0);' + #10 + #13 +
            'vec3 normal = normalize(fragNormal);' + #10 + #13 +
            'vec3 viewD = normalize(viewPos - fragPosition);' + #10 + #13 +
            'vec3 specular = vec3(0.0);' + #10 + #13 +
            'vec3 l = -lightDir;' + #10 + #13 +
            'float NdotL = max(dot(normal, l), 0.0);' + #10 + #13 +
            'lightDot += lightColor.rgb*NdotL;' + #10 + #13 +
            'float specCo = 0.0;' + #10 + #13 +
            'if (NdotL > 0.0) specCo = pow(max(0.0, dot(viewD, reflect(-(l), normal))), 16.0);' + #10 + #13 + 
            'specular += specCo;' + #10 + #13 +
            'finalColor = (texelColor*((colDiffuse + vec4(specular, 1.0))*vec4(lightDot, 1.0)));' + #10 + #13 +
            'vec4 fragPosLightSpace = lightVP * vec4(fragPosition, 1);' + #10 + #13 +
            'fragPosLightSpace.xyz /= fragPosLightSpace.w;' + #10 + #13 + 
            'fragPosLightSpace.xyz = (fragPosLightSpace.xyz + 1.0f) / 2.0f;' + #10 + #13 + 
            'vec2 sampleCoords = fragPosLightSpace.xy;' + #10 + #13 +
            'float curDepth = fragPosLightSpace.z;' + #10 + #13 +
            'float bias = max(0.0002 * (1.0 - dot(normal, l)), 0.00002) + 0.00001;' + #10 + #13 +
            'int shadowCounter = 0;' + #10 + #13 +
            'const int numSamples = 9;' + #10 + #13 +
            'vec2 texelSize = vec2(1.0f / float(shadowMapResolution));' + #10 + #13 +
            'for (int x = -1; x <= 1; x++)' + #10 + #13 +
            '{' + #10 + #13 +
            'for (int y = -1; y <= 1; y++)' + #10 + #13 +
            '{' + #10 + #13 +
            'float sampleDepth = texture(shadowMap, sampleCoords + texelSize * vec2(x, y)).r;' + #10 + #13 +
            'if (curDepth - bias > sampleDepth)' + #10 + #13 +
            '{' + #10 + #13 +
            'shadowCounter++;' + #10 + #13 +
            '}' + #10 + #13 +
            '}' + #10 + #13 +
            '}' + #10 + #13 +
            'finalColor = mix(finalColor, vec4(0, 0, 0, 1), float(shadowCounter) / float(numSamples));' + #10 + #13 +
            'finalColor += texelColor*(ambient/5.0)*colDiffuse;' + #10 + #13 +
            'finalColor = pow(finalColor, vec4(1.0/2.2));' + #10 + #13 +
            '}'; 
