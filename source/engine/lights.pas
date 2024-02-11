unit Lights;

interface

{$MINENUMSIZE 4}

uses
  raylib, raymath;

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------
const
  MAX_LIGHTS = 4; // Max dynamic lights supported by shader
  LE =  #10 + #13;

  normVs = '#version 330' + LE +
  // Input vertex attributes
  'in vec3 vertexPosition;' + LE +
  'in vec3 vertexNormal;' + LE +
  // Input uniform values
  'uniform mat4 mvp;' + LE +
  'uniform mat4 matModel;' + LE +
  // Output vertex attributes (to fragment shader)
  'out vec3 modNorm;' + LE +
  'void main()' + LE +
  '{' + LE +
  'modNorm = vec3(vec4(vertexNormal,1)*matModel);' + LE +
  'gl_Position = mvp*vec4(vertexPosition, 1.0);' + LE +
  '}';

  normFS = '#version 330' + LE +
  'in vec3 modNorm;' + LE +
  'out vec4 finalColor;' + LE +
  'void main()' + LE +
  '{' + LE +
  'finalColor = vec4(modNorm,1);' + LE +
  '}';

  toonVs = '#version 330' + LE +
  'in vec3 vertexPosition;' + LE +
  'in vec2 vertexTexCoord;' + LE +
  'in vec3 vertexNormal;' + LE +
  'in vec4 vertexColor;' + LE +
  'uniform mat4 mvp;' + LE +
  'uniform mat4 matModel;' + LE +
  'out vec2 fragTexCoord;' + LE +
  'out vec4 fragColor;' + LE +
  'out vec3 fragPosition;' + LE +
  'out vec3 fragNormal;' + LE +
  'out vec3 modNorm;' + LE +
  'void main() ' + LE +
  '{' + LE +
  '    fragTexCoord = vertexTexCoord; ' + LE +
  '    fragColor = vertexColor;  ' + LE +
  '    fragPosition = vec3(matModel*vec4(vertexPosition, 1.0f));  ' + LE +
  '    mat3 normalMatrix = transpose(inverse(mat3(matModel))); ' + LE +
  '    fragNormal = normalize(normalMatrix*vertexNormal);' + LE +
  '    modNorm = vertexNormal;' + LE +
  '    gl_Position = mvp*vec4(vertexPosition, 1.0);' + LE +
  '}';

  toonFs = '#version 330' + LE +
  // Input vertex attributes (from vertex shader)
  'in vec2 fragTexCoord;' + LE +
  'in vec4 fragColor;' + LE +
  'in vec3 fragPosition;' + LE +
  'in vec3 fragNormal;' + LE +
  // Input uniform values
  'uniform sampler2D texture0;' + LE +
  'uniform vec4 colDiffuse;' + LE +
  // Output fragment color
  'out vec4 finalColor;' + LE +

  '#define     MAX_LIGHTS              4' + LE +
  '#define     LIGHT_DIRECTIONAL       0' + LE +
  '#define     LIGHT_POINT             1' + LE +
  'struct MaterialProperty {' + LE +
  'vec3 color;' + LE +
  'int useSampler;' + LE +
  'sampler2D sampler;' + LE +
  '};' + LE +
  'struct Light {' + LE +
  'int enabled;' + LE +
  'int type;' + LE +
  'vec3 position;' + LE +
  'vec3 target;' + LE +
  'vec4 color;' + LE +
  '};' + LE +
  // Input lighting values
  'uniform Light lights[MAX_LIGHTS];' + LE +
  'uniform vec4 ambient;' + LE +
  'uniform vec3 viewPos;' + LE +
  'void main()' + LE +
  '{' + LE +

  'vec4 texelColor = texture(texture0, fragTexCoord);' + LE +
  'vec3 lightDot = vec3(0.0);' + LE +
  'vec3 normal = normalize(fragNormal);' + LE +
  'vec3 viewD = normalize(viewPos - fragPosition);' + LE +

  'float NdotL;' + LE +
  'for (int i = 0; i < MAX_LIGHTS; i++)' + LE +
  '{' + LE +
  'if (lights[i].enabled == 1)' + LE +
  '{' + LE +
  'vec3 light = vec3(0.0);' + LE +
  'if (lights[i].type == LIGHT_DIRECTIONAL) {' + LE +
  'light = -normalize(lights[i].target - lights[i].position);' + LE +
  '} ' + LE +
  'if (lights[i].type ==LIGHT_POINT) {' + LE +
  'light = normalize(lights[i].position - fragPosition);' + LE +
  '} ' + LE +
  'NdotL = max(dot(normal, light), 0.0);' + LE +
  'lightDot += lights[i].color.rgb * NdotL;' + LE +
  '}' + LE +
  '}' + LE +
  // create a banding effect

  'if (NdotL > 0.95)' + LE +
  'NdotL = 1;' + LE +

  'else if (NdotL > 0.6)' + LE +
  'NdotL = .9;' + LE +

  'else if (NdotL > 0.4)' + LE +
  'NdotL = .8;' + LE +

  'else' + LE +
  'NdotL = .7;' + LE +

  'finalColor = texelColor * colDiffuse * NdotL; ' + LE +

  'finalColor.a = 1.0;' + LE +
  '}';


//  'finalColor =  (texelColor * ((colDiffuse+vec4(specular,1)) * vec4(lightDot, 1.0)));' + LE +
//  'finalColor += texelColor * (ambient/10.0);' + LE +
  // gamma
//  'finalColor = pow(finalColor, vec4(1.0/2.2));' + LE +


  SimpleLightVs ='#version 330' + LE +
  // Input vertex attributes
  'in vec3 vertexPosition;' + LE +
  'in vec2 vertexTexCoord;' + LE +
  'in vec3 vertexNormal;' + LE +
  'in vec4 vertexColor;' + LE +
  // Input uniform values
  'uniform mat4 mvp;' + LE +
  'uniform mat4 matModel;' + LE +
  // Output vertex attributes (to fragment shader)
  'out vec2 fragTexCoord;' + LE +
  'out vec4 fragColor;' + LE +
  'out vec3 fragPosition;' + LE +
  'out vec3 fragNormal;' + LE +
  // NOTE: Add here your custom variables
  'void main()' + LE +
  '{' + LE +
  // Send vertex attributes to fragment shader
  'fragTexCoord = vertexTexCoord;' + LE +
  'fragColor = vertexColor;' + LE +
  'fragPosition = vec3(matModel*vec4(vertexPosition, 1.0f));' + LE +
  'mat3 normalMatrix = transpose(inverse(mat3(matModel)));' + LE +
  'fragNormal = normalize(normalMatrix*vertexNormal);' + LE +
  // Calculate final vertex position
  'gl_Position = mvp*vec4(vertexPosition, 1.0);' + LE +
  '}';

  SimpleLightFs = '#version 330' + LE +
  // Input vertex attributes (from vertex shader)
  'in vec2 fragTexCoord;' + LE +
  'in vec4 fragColor;' + LE +
  'in vec3 fragPosition;' + LE +
  'in vec3 fragNormal;' + LE +
  // Input uniform values
  'uniform sampler2D texture0;' + LE +
  'uniform vec4 colDiffuse;' + LE +
  // Output fragment color
  'out vec4 finalColor;' + LE +
  // NOTE: Add here your custom variables
  '#define     MAX_LIGHTS              4' + LE +
  '#define     LIGHT_DIRECTIONAL       0' + LE +
  '#define     LIGHT_POINT             1' + LE +
  'struct MaterialProperty {' + LE +
  'vec3 color;' + LE +
  'int useSampler;' + LE +
  'sampler2D sampler;' + LE +
  '};' + LE +
  'struct Light {' + LE +
  'int enabled;' + LE +
  'int type;' + LE +
  'vec3 position;' + LE +
  'vec3 target;' + LE +
  'vec4 color;' + LE +
  '};' + LE +
  // Input lighting values
  'uniform Light lights[MAX_LIGHTS];' + LE +
  'uniform vec4 ambient;' + LE +
  'uniform vec3 viewPos;' + LE +
  'void main()' + LE +
  '{' + LE +
  // Texel color fetching from texture sampler
  'vec4 texelColor = texture(texture0, fragTexCoord);' + LE +
  'vec3 lightDot = vec3(0.0);' + LE +
  'vec3 normal = normalize(fragNormal);' + LE +
  'vec3 viewD = normalize(viewPos - fragPosition);' + LE +
  'vec3 specular = vec3(0.0);' + LE +
  // NOTE: Implement here your fragment shader code
  'for (int i = 0; i < MAX_LIGHTS; i++)' + LE +
  '{' + LE +
  'if (lights[i].enabled == 1)' + LE +
  '{' + LE +
  'vec3 light = vec3(0.0);' + LE +
  'if (lights[i].type == LIGHT_DIRECTIONAL) {' + LE +
  'light = -normalize(lights[i].target - lights[i].position);' + LE +
  '}' + LE +
  'if (lights[i].type == LIGHT_POINT) {' + LE +
  'light = normalize(lights[i].position - fragPosition);' + LE +
  '}' + LE +
  'float NdotL = max(dot(normal, light), 0.0);' + LE +
  'lightDot += lights[i].color.rgb * NdotL;' + LE +
  'float specCo = 0.0;' + LE +
  'if(NdotL > 0.0)' + LE +
  'specCo = pow(max(0.0, dot(viewD, reflect(-(light), normal))), 16);' + LE +
  'specular += specCo;' + LE +
  '}' + LE +
  '}' + LE +
  'finalColor =  (texelColor * ((colDiffuse+vec4(specular,1)) * vec4(lightDot, 1.0)));' + LE +
  'finalColor += texelColor * (ambient/10.0);' + LE +
  // gamma
  'finalColor = pow(finalColor, vec4(1.0/2.2));' + LE +
  '}';

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------

type TLightType = (LIGHT_DIRECTIONAL, LIGHT_POINT);
     TLightShaderType = (TYPE_OLD, TYPE_NEW);

// Light data
type TLight = record
  LightType: TLightType;
  Enabled: Boolean;
  Position: TVector3;
  Target: TVector3;
  Color: TColor;
  Attenuation: Single;

  // Shader locations
  EnabledLoc: Integer;
  TypeLoc: Integer;
  PositionLoc: Integer;
  TargetLoc: Integer;
  ColorLoc: Integer;
  AttenuationLoc: Integer;
end;

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------
var lightsCount: Integer = 0; // Current amount of created lights
    //normShader: TShader;
    Shader: TShader;
    outline: TShader;
    ambientLoc: integer;
//    light: TLight;
    ToonLight: TLight ;
    SimpleLight: TLight;
//----------------------------------------------------------------------------------
// Module Functions Declaration
//----------------------------------------------------------------------------------

// Create a light and get shader locations
function CreateLight(LightType: TLightType; Position: TVector3; Target: TVector3; Color: TColor; Shader: TShader): TLight;
// Send light properties to shader
procedure UpdateLightValues(Shader: TShader; Light: TLight);

procedure LightShader_init(LightType:TLightType; Position: TVector3; Color: TColorB);



implementation


function CreateLight(LightType: TLightType; Position: TVector3; Target: TVector3; Color: TColor; Shader: TShader): TLight;
begin
  Result := Default(TLight);

  if LightsCount < MAX_LIGHTS then
  begin
    Result.Enabled := True;
    Result.LightType := LightType;
    Result.Position := Position;
    Result.Target := Target;
    Result.Color := Color;

    // NOTE: Lighting shader naming must be the provided ones
    Result.EnabledLoc := GetShaderLocation(Shader, TextFormat('lights[%i].enabled', LightsCount));
    Result.TypeLoc := GetShaderLocation(Shader, TextFormat('lights[%i].type', LightsCount));
    Result.PositionLoc := GetShaderLocation(Shader, TextFormat('lights[%i].position', LightsCount));
    Result.TargetLoc := GetShaderLocation(Shader, TextFormat('lights[%i].targe', LightsCount));
    Result.ColorLoc := GetShaderLocation(Shader, TextFormat('lights[%i].color', LightsCount));

    UpdateLightValues(Shader, Result);

    Inc(LightsCount);
  end;
end;

procedure UpdateLightValues(Shader: TShader; Light: TLight);
var
  Position, Target, Color: array of Single;
begin
  // Send to shader light enabled state and type
  SetShaderValue(Shader, Light.EnabledLoc, @Light.Enabled, SHADER_UNIFORM_INT);
  SetShaderValue(Shader, Light.TypeLoc, @Light.LightType, SHADER_UNIFORM_INT);

  // Send to shader light position values
  Position := [Light.Position.X, Light.Position.Y, Light.Position.Z];
  SetShaderValue(Shader, Light.PositionLoc, @Position[0], SHADER_UNIFORM_VEC3);

  // Send to shader light target position values
  Target := [Light.Target.X, Light.Target.Y, Light.Target.Z];
  SetShaderValue(Shader, Light.TargetLoc, @Target[0], SHADER_UNIFORM_VEC3);

  // Send to shader light color values
  Color := [Light.Color.R / 255, Light.Color.G / 255, Light.Color.B / 255, Light.Color.A / 255];
  SetShaderValue(Shader, Light.ColorLoc, @Color[0], SHADER_UNIFORM_VEC4);
end;

procedure LightShader_init(LightType: TLightType; Position: TVector3; Color: TColorB);
var shaderVol: array [0..3] of single;

begin
 //shader := LoadShader(TextFormat(GetAppDir('shaders/glsl%i/lighting.vs'), GLSL_VERSION),
 //TextFormat(GetAppDir('shaders/glsl%i/lighting.fs'), GLSL_VERSION));

  // lighting shader
//  shader := LoadShaderFromMemory(SimpleLightVs, SimpleLightFs);
  shader := LoadShaderFromMemory(toonVs, toonFs);

 // Get some required shader loactions
 shader.locs[SHADER_LOC_VECTOR_VIEW] := GetShaderLocation(shader, 'viewPos');
 // NOTE: "matModel" location name is automatically assigned on shader loading,
 // no need to get the location again if using that uniform name
// shader.locs[SHADER_LOC_MATRIX_MODEL] := GetShaderLocation(shader, 'matModel');

 // Ambient light level (some basic lighting)
 ambientLoc := GetShaderLocation(shader, 'ambient');

 shaderVol[0]:=0.1;
 shaderVol[1]:=0.1;
 shaderVol[2]:=0.1;
 shaderVol[3]:=0.1;
 SetShaderValue(shader, ambientLoc, @shaderVol, SHADER_UNIFORM_VEC4);
       //Vector3Create(1000,0,0)
  // make a light (max 4 but we're only using 1)
 ToonLight:= CreateLight(LightType, Position, Vector3Zero(), Color, shader);

end;

end.
