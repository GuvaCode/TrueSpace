// Mask Shader
MaskFs := '#version 330'                + #10 + #13 +
          'in vec2 fragTexCoord;'       + #10 + #13 +
          'in vec4 fragColor;'          + #10 + #13 +
          'uniform sampler2D texture0;' + #10 + #13 +
          'uniform sampler2D mask;'     + #10 + #13 +
          'uniform int frame;'          + #10 + #13 +
          'out vec4 finalColor;'        + #10 + #13 +
          'void main()'                 + #10 + #13 +
          '{'                           + #10 + #13 +
          'vec4 maskColour = texture(mask, fragTexCoord + vec2(sin(-frame/150.0)/10.0, cos(-frame/170.0)/10.0));'+ #10 + #13 +
          'if (maskColour.r < 0.25) discard;'  + #10 + #13 +
          'vec4 texelColor = texture(texture0, fragTexCoord + vec2(sin(frame/90.0)/8.0, cos(frame/60.0)/8.0));'+ #10 + #13 +
          'finalColor = texelColor*maskColour;'+ #10 + #13 +
          '}';
