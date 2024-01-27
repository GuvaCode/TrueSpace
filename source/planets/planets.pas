unit planets;

{$mode ObjFPC}{$H+}

interface

uses
  RayLib, RayMath, SpaceEngine;

type

  { TSpaceShipActor }

  TSpaceShipActor = class(TSpaceActor)
  private
    FTextureCloudMask: TTexture;
    FTextureGroundMask: TTexture;
    FGroundShader: TShader;
    FCloudShader: TShader;
    FShaderFrame: integer;
    procedure SetTextureCloudMask(AValue: TTexture);
    procedure SetTextureGroundMask(AValue: TTexture);
    procedure ApplyShader;
  public
    constructor Create(const AParent: TSpaceEngine); override;
    procedure OnCollision(const {%H-}Actor: TSpaceActor); override;
    procedure Update(const DeltaTime: Single); override;
    procedure Render(ShowDebugAxes: Boolean; ShowDebugRay: Boolean); override;
    property TextureGroundMask: TTexture read FTextureGroundMask write SetTextureGroundMask;
    property TextureCloudMask: TTexture read FTextureCloudMask write SetTextureCloudMask;
  end;


implementation

{ TSpaceShipActor }

procedure TSpaceShipActor.SetTextureGroundMask(AValue: TTexture);
begin
  FTextureGroundMask:=AValue;
  ApplyShader;
end;

procedure TSpaceShipActor.ApplyShader;
begin
  ActorModel.Materials[1].Maps[MATERIAL_MAP_EMISSION].Texture := FTextureGroundMask;
  ActorModel.Materials[2].Maps[MATERIAL_MAP_EMISSION].Texture := FTextureCloudMask;

  FGroundShader.Locs[SHADER_LOC_MAP_EMISSION] := GetShaderLocation(FGroundShader, 'mask');
  FCloudShader.Locs[SHADER_LOC_MAP_EMISSION] := GetShaderLocation(FCloudShader, 'mask');
  FShaderFrame := GetShaderLocation(FCloudShader, 'frame');   // cloud
  ActorModel.materials[1].shader := FGroundShader;
  ActorModel.materials[2].shader := FCloudShader;
end;

procedure TSpaceShipActor.SetTextureCloudMask(AValue: TTexture);
begin
  FTextureCloudMask:=AValue;
  ApplyShader;
end;

constructor TSpaceShipActor.Create(const AParent: TSpaceEngine);
var maskFs: PChar;
begin
  inherited Create(AParent);
   {$I ../shaders/mask.inc}
  FCloudShader := LoadShaderFromMemory(nil,maskFs);
  FGroundShader := LoadShaderFromMemory(nil,maskFs);
end;

procedure TSpaceShipActor.OnCollision(const Actor: TSpaceActor);

begin
  inherited OnCollision(Actor);

end;

procedure TSpaceShipActor.Update(const DeltaTime: Single);
begin
  inherited Update(DeltaTime);
end;

procedure TSpaceShipActor.Render(ShowDebugAxes: Boolean; ShowDebugRay: Boolean);
begin
  inherited Render(ShowDebugAxes, ShowDebugRay);
end;

end.

