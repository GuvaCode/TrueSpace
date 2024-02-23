unit WarpGate;

{$mode ObjFPC}{$H+}

interface

uses
  RayLib, RayMath, SpaceEngine, Global, Classes, SysUtils;

type

  { TWarpGlow }

  TWarpGlow = class(TSpaceActor)
  private
    MaskFs: PChar;
    MaskShader: TShader;
    texDiffuse, texMask: TTexture;
    shaderFrame: Integer;
    framesCounter: Integer;
  public
    constructor Create(const AParent: TSpaceEngine); override;
    procedure Update(const DeltaTime: Single); override;
    procedure Render(ShowDebugAxes: Boolean; ShowDebugRay: Boolean); override;
    procedure SetTexture(AMaterialNumber: Integer; ATexture: TTexture);
end;



implementation

{ TWarpGlow }

constructor TWarpGlow.Create(const AParent: TSpaceEngine);
begin
   inherited Create(AParent);
  Self.Engine := AParent;
   //Model model2 = LoadModelFromMesh(cube);
  //ActorModel := LoadModelFromMesh(GenMeshCylinder(1, 2, 16));
 // ActorModel := LoadModelFromMesh(GenMeshSphere(2, 32, 32));
 //ActorModel := LoadModelFromMesh(GenMeshPlane(5, 5, 4, 3));
 // ActorModel := LoadModelFromMesh(cube);
  ActorModel := LoadModel(GetAppDir('data' + '/models/building/warp_glow.glb'));

  {$I ../shaders/mask.inc}
  MaskShader := LoadShaderFromMemory(nil, MaskFs);
  texDiffuse := LoadTexture(GetAppDir('data' + '/textures/caustics.png'));


  ActorModel.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture := texDiffuse;
 // ActorModel.materials[1].maps[MATERIAL_MAP_DIFFUSE].texture := texDiffuse;
  texMask := LoadTexture(GetAppDir('data' + '/textures/plasma0.png'));

  ActorModel.materials[0].maps[MATERIAL_MAP_EMISSION].texture := texMask;
  //ActorModel.materials[1].maps[MATERIAL_MAP_EMISSION].texture := texMask;

  MaskShader.locs[SHADER_LOC_MAP_EMISSION] := GetShaderLocation(MaskShader, 'mask');

  shaderFrame := GetShaderLocation(MaskShader, 'frame');

  DoCollision:=False;
 // ActorModel.materials[0].shader := MaskShader;
  ActorModel.materials[0].shader := MaskShader;
  scale := 0.1;


  //Engine.Add(Self);
end;

procedure TWarpGlow.Update(const DeltaTime: Single);
begin

  inherited Update(DeltaTime);
  // ActorModel.materials[0].shader := MaskShader;
  //ActorModel.materials[1].shader := MaskShader;
  Inc(framesCounter);// :=   FramesCounter + 0.0001;
  SetShaderValue(MaskShader, shaderFrame, @framesCounter, SHADER_UNIFORM_INT);
end;

procedure TWarpGlow.Render(ShowDebugAxes: Boolean; ShowDebugRay: Boolean);
begin
  inherited Render(ShowDebugAxes, ShowDebugRay);
//  ActorModel.materials[1].shader := MaskShader;
end;

procedure TWarpGlow.SetTexture(AMaterialNumber: Integer; ATexture: TTexture);
begin
  if AMaterialNumber <= ActorModel.materialCount - 1 then
  ActorModel.materials[AMaterialNumber].maps[MATERIAL_MAP_DIFFUSE].texture := ATexture else
  TraceLog(LOG_ERROR,'WarpGlow: materials value not exits');
end;

end.

