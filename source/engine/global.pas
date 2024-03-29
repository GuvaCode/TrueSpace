unit global;

{$mode ObjFPC}{$H+}

interface

uses
  Raylib, SysUtils;

  procedure LoadTextures;
  procedure UnloadTextures;

  var
    FModelAtlas: array [0..23] of TTexture; // текстуры
    FModelEmission: array [0..4] of TTexture;
    FLogoTexture: TTexture;
    FLoadingTexture: TTexture;


const
  // константы для экранов
  SCREEN_LOADING = $0001;
  SCREEN_SPACE = $0002;
  // for shadow map shader
  SHADOWMAP_RESOLUTION = 1024 * 2;
  CameraSpeed = 0.05;

implementation

procedure LoadTextures;
var LoadCounter: integer;
begin
  for LoadCounter := 0 to 23 do
  begin
    FModelAtlas[LoadCounter] := LoadTexture(GetAppDir('data/textures/atlas/'+IntTostr(LoadCounter)+'.png'));
  end;
end;

procedure UnloadTextures;
var LoadCounter: integer;
begin
  for LoadCounter := 0 to 23 do UnLoadTexture(FModelAtlas[LoadCounter]);
  UnloadTexture(FLoadingTexture);
end;

end.

