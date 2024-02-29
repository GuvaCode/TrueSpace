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




