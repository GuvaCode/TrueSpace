unit WarpGate;

{$mode ObjFPC}{$H+}

interface

uses
  RayLib, RayMath, SpaceEngine, Global, Classes, SysUtils;

type

  { TWarpGlow }

  TWarpGlow = class(TSpaceActor)
  private
    //WarpTimer: Timer;
    MaskFs: PChar;
    MaskShader: TShader;
    texDiffuse, texMask: TTexture;
    shaderFrame: Integer;
  //  framesCounter: Integer;
  //  baseTime : Double;
  public
    constructor Create(const AParent: TSpaceEngine); override;
    destructor Destroy; override;
    procedure Update(const DeltaTime: Single); override;
    procedure Render(ShowDebugAxes: Boolean; ShowDebugRay: Boolean); override;
    procedure SetTexture(AMaterialNumber: Integer; ATexture: TTexture);
end;

  { TWarpIn }

  TWarpIn = class(TSpaceActor)
  private

  public
    constructor Create(const AParent: TSpaceEngine); override;
    destructor Destroy; override;
    procedure Update(const DeltaTime: Single); override;
    procedure Render(ShowDebugAxes: Boolean; ShowDebugRay: Boolean); override;
    procedure SetTexture(AMaterialNumber: Integer; ATexture: TTexture);
end;

  { TWarpOut }

  TWarpOut = class(TSpaceActor)
  private

  public
    constructor Create(const AParent: TSpaceEngine); override;
    destructor Destroy; override;
    procedure Update(const DeltaTime: Single); override;
    procedure Render(ShowDebugAxes: Boolean; ShowDebugRay: Boolean); override;
    procedure SetTexture(AMaterialNumber: Integer; ATexture: TTexture);
  end;


implementation

{ TWarpGlow }

constructor TWarpGlow.Create(const AParent: TSpaceEngine);
begin
   inherited Create(AParent);
  Engine := AParent;
  ActorModel := LoadModel(GetAppDir('data' + '/models/building/warp_glow.glb'));

  {$I ../shaders/mask.inc}
  MaskShader := LoadShaderFromMemory(nil, MaskFs);
  texDiffuse := LoadTexture(GetAppDir('data' + '/textures/chaos.png'));

  ActorModel.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture := texDiffuse;
  texMask := LoadTexture(GetAppDir('data' + '/textures/Hex_glow_roughness.png'));

  ActorModel.materials[0].maps[MATERIAL_MAP_EMISSION].texture := texMask;
  MaskShader.locs[SHADER_LOC_MAP_EMISSION] := GetShaderLocation(MaskShader, 'mask');

  shaderFrame := GetShaderLocation(MaskShader, 'frame');

  DoCollision:=False;

  //ActorModel.materials[0].shader := MaskShader;
  //scale := 0.1;
// StartTimer(@WarpTimer,6000);

end;

destructor TWarpGlow.Destroy;
begin
  UnloadShader(MaskShader);
  UnloadTexture(texDiffuse);
  UnloadTexture(texMask);
  UnloadModel(ActorModel);
  inherited Destroy;
end;

procedure TWarpGlow.Update(const DeltaTime: Single);
begin
  inherited Update(DeltaTime);
  InputYawLeft :=  - 0.02;
   {if TimerDone (@WarpTimer) then StartTimer(@WarpTimer,100 * Deltatime) else
   begin
    framesCounter :=1;//framesCounter + Round(WarpTimer.Lifetime);//  + 1;// div Round(DeltaTime);
    SetShaderValue(MaskShader, shaderFrame, @framesCounter, SHADER_UNIFORM_INT);
    UpdateTimer(@WarpTimer);
    end;// else  }
end;

procedure TWarpGlow.Render(ShowDebugAxes: Boolean; ShowDebugRay: Boolean);
begin
  inherited Render(ShowDebugAxes, ShowDebugRay);

end;

procedure TWarpGlow.SetTexture(AMaterialNumber: Integer; ATexture: TTexture);
begin
  if AMaterialNumber <= ActorModel.materialCount - 1 then
  ActorModel.materials[AMaterialNumber].maps[MATERIAL_MAP_DIFFUSE].texture := ATexture else
  TraceLog(LOG_ERROR,'WarpGlow: materials value not exits');
end;

{ TWarpIn }

constructor TWarpIn.Create(const AParent: TSpaceEngine);
begin
  inherited Create(AParent);
  Engine := AParent;
  ActorModel := LoadModel(GetAppDir('data' + '/models/building/warp_in.glb'));
  DoCollision:=False;
  //scale := 0.8;
end;

destructor TWarpIn.Destroy;
begin
  inherited Destroy;
end;

procedure TWarpIn.Update(const DeltaTime: Single);
begin
  inherited Update(DeltaTime);
  InputYawLeft :=  0.02;
end;

procedure TWarpIn.Render(ShowDebugAxes: Boolean; ShowDebugRay: Boolean);
begin
  inherited Render(ShowDebugAxes, ShowDebugRay);
end;

procedure TWarpIn.SetTexture(AMaterialNumber: Integer; ATexture: TTexture);
begin
  if AMaterialNumber <= ActorModel.materialCount - 1 then
  ActorModel.materials[AMaterialNumber].maps[MATERIAL_MAP_DIFFUSE].texture := ATexture else
  TraceLog(LOG_ERROR,'WarpGlow: materials value not exits');
end;

{ TWarpOut }

constructor TWarpOut.Create(const AParent: TSpaceEngine);
begin
  inherited Create(AParent);
  Engine := AParent;
  ActorModel := LoadModel(GetAppDir('data' + '/models/building/warp_out.glb'));
  DoCollision:=False;
end;

destructor TWarpOut.Destroy;
begin
  inherited Destroy;
end;

procedure TWarpOut.Update(const DeltaTime: Single);
begin
  inherited Update(DeltaTime);
end;

procedure TWarpOut.Render(ShowDebugAxes: Boolean; ShowDebugRay: Boolean);
begin
  inherited Render(ShowDebugAxes, ShowDebugRay);
end;

procedure TWarpOut.SetTexture(AMaterialNumber: Integer; ATexture: TTexture);
begin

end;

end.

