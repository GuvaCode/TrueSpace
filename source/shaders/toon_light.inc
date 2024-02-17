// MyShader Pack
toonFs := '#version 330' + #10 + #13 +

// Input vertex attributes (from vertex shader)
'in vec2 fragTexCoord;' + #10 + #13 +
'in vec4 fragColor;' + #10 + #13 +
'in vec3 fragPosition;' + #10 + #13 +
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

'struct MaterialProperty {' + #10 + #13 +
'    vec3 color;'           + #10 + #13 +
'    int useSampler;'       + #10 + #13 +
'    sampler2D sampler;'    + #10 + #13 +
'};' + #10 + #13 +

'struct Light {'     + #10 + #13 +
'    int enabled;'   + #10 + #13 +
'    int type;'      + #10 + #13 +
'    vec3 position;' + #10 + #13 +
'    vec3 target;'   + #10 + #13 +
'    vec4 color;'    + #10 + #13 +
'};' + #10 + #13 +

// Input lighting values
'uniform Light lights[MAX_LIGHTS];' + #10 + #13 +
'uniform vec4 ambient;' + #10 + #13 +
'uniform vec3 viewPos;' + #10 + #13 +

'void main()' + #10 + #13 +
'{' + #10 + #13 +
    // Texel color fetching from texture sampler
'    vec4 texelColor = texture(texture0, fragTexCoord);' + #10 + #13 +
'    vec3 lightDot = vec3(0.0);' + #10 + #13 +
'    vec3 normal = normalize(fragNormal);' + #10 + #13 +
'    vec3 viewD = normalize(viewPos - fragPosition);' + #10 + #13 +

    // NOTE: Implement here your fragment shader code
'    float NdotL;' + #10 + #13 +
'    for (int i = 0; i < MAX_LIGHTS; i++)' + #10 + #13 +
'    {' + #10 + #13 +
'        if (lights[i].enabled == 1)' + #10 + #13 +
'        {' + #10 + #13 +
'            vec3 light = vec3(0.0);' + #10 + #13 +
'            if (lights[i].type == LIGHT_DIRECTIONAL) {' + #10 + #13 +
'                light = -normalize(lights[i].target - lights[i].position);' + #10 + #13 +
'            }' + #10 + #13 +
'            if (lights[i].type == LIGHT_POINT) {' + #10 + #13 +
'                light = normalize(lights[i].position - fragPosition);' + #10 + #13 +
'            }' + #10 + #13 +
'            NdotL = max(dot(normal, light), 0.0);' + #10 + #13 +
'            lightDot += lights[i].color.rgb * NdotL;' + #10 + #13 +
'        }' + #10 + #13 +
'    }' + #10 + #13 +

    // create a banding effect
'    if (NdotL > 0.95)' + #10 + #13 +
'		NdotL = 1;' + #10 + #13 +
'	else if (NdotL > 0.6)' + #10 + #13 +
'		NdotL = .9;' + #10 + #13 +
'	else if (NdotL > 0.4)' + #10 + #13 +
'		NdotL = .8;' + #10 + #13 +
'	else' + #10 + #13 +
'		NdotL = .7;' + #10 + #13 +

'    finalColor = texelColor * colDiffuse * NdotL;' + #10 + #13 +
'    finalColor.a = 1.0;' + #10 + #13 +

'}';

toonVs := '#version 330' + #10 + #13 +

// Input vertex attributes
'in vec3 vertexPosition;' + #10 + #13 +
'in vec2 vertexTexCoord;' + #10 + #13 +
'in vec3 vertexNormal;' + #10 + #13 +
'in vec4 vertexColor;' + #10 + #13 +

// Input uniform values
'uniform mat4 mvp;' + #10 + #13 +
'uniform mat4 matModel;' + #10 + #13 +

// Output vertex attributes (to fragment shader)
'out vec2 fragTexCoord;' + #10 + #13 +
'out vec4 fragColor;' + #10 + #13 +
'out vec3 fragPosition;' + #10 + #13 +
'out vec3 fragNormal;' + #10 + #13 +
'out vec3 modNorm;' + #10 + #13 +

// NOTE: Add here your custom variables

'void main()' + #10 + #13 +
'{' + #10 + #13 +
    // Send vertex attributes to fragment shader
'    fragTexCoord = vertexTexCoord;' + #10 + #13 +
'    fragColor = vertexColor;' + #10 + #13 +
'    fragPosition = vec3(matModel*vec4(vertexPosition, 1.0f));' + #10 + #13 +
'    mat3 normalMatrix = transpose(inverse(mat3(matModel)));' + #10 + #13 +
'    fragNormal = normalize(normalMatrix*vertexNormal);' + #10 + #13 +
'    modNorm = vertexNormal;' + #10 + #13 +

    // Calculate final vertex position
'    gl_Position = mvp*vec4(vertexPosition, 1.0);' + #10 + #13 +
'}';

normFs := '#version 330'                  + #10 + #13 +
          'in vec3 modNorm;'              + #10 + #13 +
          'out vec4 finalColor;'          + #10 + #13 +
          'void main()'                   + #10 + #13 +
          '{'                             + #10 + #13 +
          'finalColor = vec4(modNorm,1);' + #10 + #13 +
          '}';

normVs := '#version 330' + #10 + #13 +
          'in vec3 vertexPosition;' + #10 + #13 +
          'in vec3 vertexNormal;' + #10 + #13 +
          'uniform mat4 mvp;' + #10 + #13 +
          'uniform mat4 matModel;' + #10 + #13 +
          'out vec3 modNorm;' + #10 + #13 +
          'void main()' + #10 + #13 +
          '{'  + #10 + #13 +
          'modNorm = vec3(vec4(vertexNormal,1)*matModel);' + #10 + #13 +
          'gl_Position = mvp*vec4(vertexPosition, 1.0);' + #10 + #13 +
          '}';

outlineFs := '#version 330' + #10 + #13 +

// modified sobel shader to create outlines from map of model/view rotated normals


// Input vertex attributes (from vertex shader)
'in vec2 fragTexCoord;' + #10 + #13 +
'in vec4 fragColor;' + #10 + #13 +

// Input uniform values
'uniform sampler2D texture0;' + #10 + #13 +
'uniform vec4 colDiffuse;' + #10 + #13 +

// Output fragment color
'out vec4 finalColor;' + #10 + #13 +

// NOTE: Add here your custom variables
'uniform vec2 resolution = vec2(1280, 720);' + #10 + #13 +

'void main()' + #10 + #13 +
'{' + #10 + #13 +
'	float x = 1.0/resolution.x;' + #10 + #13 +
'	float y = 1.0/resolution.y;' + #10 + #13 +

'	vec4 horizEdge = vec4(0.0);' + #10 + #13 +
'	horizEdge -= texture2D(texture0, vec2(fragTexCoord.x - x, fragTexCoord.y - y))*0.5;' + #10 + #13 +
	//horizEdge -= texture2D(texture0, vec2(fragTexCoord.x - x, fragTexCoord.y    ))*2.0;
'	horizEdge -= texture2D(texture0, vec2(fragTexCoord.x - x, fragTexCoord.y    ))*1.0;' + #10 + #13 +
'	horizEdge -= texture2D(texture0, vec2(fragTexCoord.x - x, fragTexCoord.y + y))*0.5;' + #10 + #13 +
'	horizEdge += texture2D(texture0, vec2(fragTexCoord.x + x, fragTexCoord.y - y))*0.5;' + #10 + #13 +
	//horizEdge += texture2D(texture0, vec2(fragTexCoord.x + x, fragTexCoord.y    ))*2.0;
'	horizEdge += texture2D(texture0, vec2(fragTexCoord.x + x, fragTexCoord.y    ))*1.0;' + #10 + #13 +
'	horizEdge += texture2D(texture0, vec2(fragTexCoord.x + x, fragTexCoord.y + y))*0.5;' + #10 + #13 +

'	vec4 vertEdge = vec4(0.0);' + #10 + #13 +
'	vertEdge -= texture2D(texture0, vec2(fragTexCoord.x - x, fragTexCoord.y - y))*0.5;' + #10 + #13 +
	//vertEdge -= texture2D(texture0, vec2(fragTexCoord.x    , fragTexCoord.y - y))*2.0;
'	vertEdge -= texture2D(texture0, vec2(fragTexCoord.x    , fragTexCoord.y - y))*1.0;' + #10 + #13 +
'	vertEdge -= texture2D(texture0, vec2(fragTexCoord.x + x, fragTexCoord.y - y))*0.5;' + #10 + #13 +
'	vertEdge += texture2D(texture0, vec2(fragTexCoord.x - x, fragTexCoord.y + y))*0.5;' + #10 + #13 +
	//vertEdge += texture2D(texture0, vec2(fragTexCoord.x    , fragTexCoord.y + y))*2.0;
'	vertEdge += texture2D(texture0, vec2(fragTexCoord.x    , fragTexCoord.y + y))*1.0;' + #10 + #13 +
'	vertEdge += texture2D(texture0, vec2(fragTexCoord.x + x, fragTexCoord.y + y))*0.5;' + #10 + #13 +

'	vec3 edge = sqrt((horizEdge.rgb*horizEdge.rgb) + (vertEdge.rgb*vertEdge.rgb));' + #10 + #13 +

'    const float t = .6; // should be a uniform ' + #10 + #13 +

'    if (length(edge)>t) {' + #10 + #13 +
'        finalColor = vec4(0,0,0,1);' + #10 + #13 +
'    } else {' + #10 + #13 +
'        finalColor = vec4(0,0,0,0);' + #10 + #13 +
'    }' + #10 + #13 +

'}';




