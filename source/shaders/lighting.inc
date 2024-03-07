lightingVs = '#version 330' + #10 + #13 + 

// Input vertex attributes
'in vec3 vertexPosition;' + #10 + #13 + 
'in vec2 vertexTexCoord;' + #10 + #13 + 
'in vec3 vertexNormal;' + #10 + #13 + 
'in vec4 vertexColor;' + #10 + #13 + 

// Input uniform values
'uniform mat4 mvp;' + #10 + #13 + 
'uniform mat4 matModel;' + #10 + #13 + 
'uniform mat4 matNormal;' + #10 + #13 + 

// Output vertex attributes (to fragment shader)
'out vec3 fragPosition;' + #10 + #13 + 
'out vec2 fragTexCoord;' + #10 + #13 + 
'out vec4 fragColor;' + #10 + #13 + 
'out vec3 fragNormal;' + #10 + #13 + 

// NOTE: Add here your custom variables

'void main()' + #10 + #13 + 
'{' + #10 + #13 + 
    // Send vertex attributes to fragment shader
    'fragPosition = vec3(matModel*vec4(vertexPosition, 1.0));' + #10 + #13 + 
    'fragTexCoord = vertexTexCoord;' + #10 + #13 + 
    'fragColor = vertexColor;' + #10 + #13 + 
    'fragNormal = normalize(vec3(matNormal*vec4(vertexNormal, 1.0)));' + #10 + #13 + 

    // Calculate final vertex position
    'gl_Position = mvp*vec4(vertexPosition, 1.0);' + #10 + #13 + 
'}';

lightingFs = '#version 330' + #10 + #13 +

// Input vertex attributes (from vertex shader)
'in vec3 fragPosition;' + #10 + #13 +
'in vec2 fragTexCoord;' + #10 + #13 +
//in vec4 fragColor;
'in vec3 fragNormal;' + #10 + #13 +

// Input uniform values
'uniform sampler2D texture0;' + #10 + #13 +
'uniform vec4 colDiffuse;' + #10 + #13 +

// Output fragment color
'out vec4 finalColor;' + #10 + #13 +

// NOTE: Add here your custom variables

'#define     MAX_LIGHTS              4' + #10 + #13 +
'#define     LIGHT_DIRECTIONAL       0' + #10 + #13 +
'#define     LIGHT_POINT             1' + #10 + #13 +

'struct Light {' + #10 + #13 +
    'int enabled;' + #10 + #13 +
    'int type;' + #10 + #13 +
    'vec3 position;' + #10 + #13 +
    'vec3 target;' + #10 + #13 +
    'vec4 color;' + #10 + #13 +
'};' + #10 + #13 +

// Input lighting values
'uniform Light lights[MAX_LIGHTS];' + #10 + #13 +
'uniform vec4 ambient;' + #10 + #13 +
'uniform vec3 viewPos;' + #10 + #13 +

'void main()' + #10 + #13 +
'{' + #10 + #13 +
    // Texel color fetching from texture sampler
    'vec4 texelColor = texture(texture0, fragTexCoord);' + #10 + #13 +
    'vec3 lightDot = vec3(0.0);' + #10 + #13 +
    'vec3 normal = normalize(fragNormal);' + #10 + #13 +
    'vec3 viewD = normalize(viewPos - fragPosition);' + #10 + #13 +
    'vec3 specular = vec3(0.0);' + #10 + #13 +

    // NOTE: Implement here your fragment shader code

    'for (int i = 0; i < MAX_LIGHTS; i++)' + #10 + #13 +
    '{
        'if (lights[i].enabled == 1)' + #10 + #13 +
        '{' + #10 + #13 +
            'vec3 light = vec3(0.0);' + #10 + #13 +

            'if (lights[i].type == LIGHT_DIRECTIONAL)' + #10 + #13 +
            '{' + #10 + #13 +
                'light = -normalize(lights[i].target - lights[i].position);' + #10 + #13 +
            '}' + #10 + #13 +

            'if (lights[i].type == LIGHT_POINT)' + #10 + #13 +
            '{' + #10 + #13 +
                'light = normalize(lights[i].position - fragPosition);' + #10 + #13 +
            '}' + #10 + #13 +

            'float NdotL = max(dot(normal, light), 0.0);' + #10 + #13 +
            'lightDot += lights[i].color.rgb*NdotL;' + #10 + #13 +

            'float specCo = 0.0;' + #10 + #13 +
            'if (NdotL > 0.0) specCo = pow(max(0.0, dot(viewD, reflect(-(light), normal))), 16.0); // 16 refers to shine' + #10 + #13 +
            'specular += specCo;' + #10 + #13 +
        '}' + #10 + #13 +
    '}' + #10 + #13 +

    'finalColor = (texelColor*((colDiffuse + vec4(specular, 1.0))*vec4(lightDot, 1.0)));' + #10 + #13 +
    'finalColor += texelColor*(ambient/10.0)*colDiffuse;' + #10 + #13 +

    // Gamma correction
    'finalColor = pow(finalColor, vec4(1.0/2.2));' + #10 + #13 +
'}';
