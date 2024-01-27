// Star Shader
StarFs := '#version 330' + #10 + #13 +
          // Input vertex attributes (from vertex shader)
          'in vec2 fragTexCoord;'+ #10 + #13 +
          'in vec4 fragColor;'+ #10 + #13 +
          // Input uniform values
          'uniform vec3 viewPos;'+ #10 + #13 +
          'uniform float fovY;'+ #10 + #13 +
          'uniform vec2 screenSize;'+ #10 + #13 +
          'uniform mat4 matView;'+ #10 + #13 +
          // Output fragment color
          'out vec4 finalColor;'+ #10 + #13 +
          '#define PI 3.14159265358979323846f'+ #10 + #13 +
          '#define DEG2RAD PI/180.f'+ #10 + #13 +
          //! `nmzHash33` and `stars` are from https://www.shadertoy.com/view/XsyGWV
          'vec3 nmzHash33(vec3 q)'+ #10 + #13 +
          '{'+ #10 + #13 +
          'uvec3 p = uvec3(ivec3(q));'+ #10 + #13 +
          'p = p*uvec3(374761393U, 1103515245U, 668265263U) + p.zxy + p.yzx;'+ #10 + #13 +
          'p = p.yzx*(p.zxy^(p >> 3U));'+ #10 + #13 +
          'return vec3(p^(p >> 16U))*(1.0/vec3(0xffffffffU));'+ #10 + #13 +
          '}'+ #10 + #13 +
          'vec3 stars(in vec3 p)' + #10 + #13 +
          '{'+ #10 + #13 +
          'vec3 c = vec3(0.);'+ #10 + #13 +
          'float res = screenSize.x*0.8;'+ #10 + #13 +
          'for (float i=0.;i<3.;i++)' + #10 + #13 +
          '{'+ #10 + #13 +
          'vec3 q = fract(p*(.15*res))-0.5;'+ #10 + #13 +
          'vec3 id = floor(p*(.15*res));'+ #10 + #13 +
          'vec2 rn = nmzHash33(id).xy;'+ #10 + #13 +
          'float c2 = 1.-smoothstep(0.,.9,length(q));'+ #10 + #13 +
          'c2 *= step(rn.x,.0005+i*i*0.001);'+ #10 + #13 +
          'c += c2*(mix(vec3(1.0,0.49,0.1),vec3(0.75,0.9,1.),rn.y)*0.25+0.75);'+ #10 + #13 +
          'p *= 1.4;'+ #10 + #13 +
          '}'+ #10 + #13 +
          'return c*c*.7;'+ #10 + #13 +
          '}'+ #10 + #13 +

          'void main() {'+ #10 + #13 +
          // convert fov to radians, mod is ok because trig funcs are cyclic
          'float clampedFovInRads = mod(fovY, 360.0f) * DEG2RAD;'+ #10 + #13 +
          'clampedFovInRads = clamp(clampedFovInRads, 0.0001f, PI-0.001f);' + #10 + #13 + // Clamp fov
          // tan(pi/2) is undef, nudge away from there
          'if (clampedFovInRads == PI) { clampedFovInRads -= 0.01f; }'+ #10 + #13 +
          'float dst = 1.0f/tan(clampedFovInRads/2.0f);' + #10 + #13 + // Cotangent, distance of "eye" from screen
          'vec3 viewPointLocal = vec3(fragTexCoord-0.5, -dst/2);' + #10 + #13 + // negative is because you're facing -z and need to invert it. 1/2 is because UV is on [0,1] and not [-1,1]
          // dst calculation is needed to prevent unrealistic sliding of the stars on the horizon -- stars will stay in the same spot when turning
          'viewPointLocal.x *= screenSize.x / screenSize.y;' + #10 + #13 + // stretch aspect ratio issue
          'vec3 ro = viewPos;' + #10 + #13 + // Ray origin (camera pos)
          'vec3 rd = normalize((matView * vec4(viewPointLocal, 1)).xyz);' + #10 + #13 + // Ray direction, multiplied by the camera's rotation transform
          'vec3 bg = stars(rd);' + #10 + #13 +
          'finalColor = vec4(bg, 1);' + #10 + #13 +
          '}';
