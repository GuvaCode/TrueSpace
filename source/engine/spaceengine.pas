unit SpaceEngine;

{$mode ObjFPC}{$H+}

interface

uses
  RayLib, RayMath, RlGl, RLights, Math, DigestMath, Collider, Global, Classes, SysUtils;

type
  TSkyBoxQuality = (SBQOriginal, SBQLow, SBQVeryLow);

  { TRailRung }
  PTrailRung = ^TrailRung;
  TrailRung = record
    LeftPoint : array[0..12] of TVector3;
    RightPoint: array[0..12] of  TVector3;
    TimeToLive: Single;
  end;

  { Timer }
  PTimer = ^Timer;
  Timer = record
  Lifetime: single;
  end;

  { TSpaceDust }
  TSpaceDust = class
   private
     FPoints: array of TVector3;
     FColors: array of TColorB;
     FExtent: Single;
   public
     constructor Create(Size: single; Count:integer); virtual;
     procedure UpdateViewPosition(ViewPosition: TVector3);
     procedure Draw(ViewPosition, Velocity: TVector3; DrawDots: boolean);
   end;

  TSpaceActor = class;

  { TSpaceCrosshair }
  TSpaceCrosshair = class
  private
    FCrosshairColor: TColorB;
    FCrosshairModel: TModel;
  public
    constructor Create(const modelFileName: PChar); virtual;
    destructor Destroy; override;
    procedure PositionCrosshairOnActor(const Actor: TSpaceActor; distance: Single);
    procedure DrawCrosshair;
    property CrosshairColor: TColorB read FCrosshairColor write FCrosshairColor;
  end;

  { TSpaceCamera }
  TSpaceCamera = class
  private
    FSmoothPosition: TVector3;
    FSmoothTarget: TVector3;
    FSmoothUp: TVector3;
  public
    Camera: TCamera;
    constructor Create(isPerspective:boolean; fieldOfView: single); virtual;
    procedure BeginDrawing;
    procedure EndDrawing;
    procedure FollowActor(const Actor: TSpaceActor; deltaTime: Single);
    procedure MoveTo(position_, target, up: TVector3; deltaTime: Single);
    procedure SetPosition(position_ ,target, up: TVector3);
    function GetPosition: TVector3;
    function GetTarget: TVector3;
    function GetUp: TVector3;
    function GetFovy: Single;
  end;

  { TSpaceEngine }
  TSpaceEngine = class
  private
    FActorList: TList;
    FDeadActorList: TList;
    FDrawRadar: Boolean;
    FOutlineShader: Boolean;
    FSkyBoxQuality: TSkyBoxQuality;
    FSpaceDust: TSpaceDust;
    FSkyBox: TModel;
    FUsesSkyBox: Boolean;
    FNormShader, FOutline, FLightShader: TShader;
    FLight: TLight;
    FTarget: TRenderTexture2D;

    function GetCount: Integer;
    function GetModelActor(const Index: Integer): TSpaceActor;
  public
    CrosshairNear, CrosshairFar: TSpaceCrosshair;
    constructor Create;
    destructor Destroy; override;
    procedure Add(const ModelActor: TSpaceActor);
    procedure Remove(const ModelActor: TSpaceActor);
    procedure Change(ModelActor: TSpaceActor; Dest: TSpaceEngine);
    procedure Update(DeltaTime: Single; DustViewPosition: TVector3);
    procedure Render(Camera: TSpaceCamera; ShowDebugAxes, ShowDebugRay: Boolean; DustVelocity: TVector3; DustDrawDots: boolean);
    procedure Collision;
    procedure Clear;
    procedure ClearDeadActor;
    procedure GenerateSkyBox(Size: Integer; Color: TColorB; StarCount: Integer);
    procedure GenerateSkyBoxTexture(Filename: string);
    procedure SetSkyBoxFileName(AValue: String);

    property Items[const Index: Integer]: TSpaceActor read GetModelActor; default;
    property Count: Integer read GetCount;
    property UsesSkyBox: Boolean read FUsesSkyBox write FUsesSkyBox;
    property DrawRadar: Boolean read FDrawRadar write FDrawRadar;
    property SkyBoxQuality: TSkyBoxQuality read FSkyBoxQuality write FSkyBoxQuality;
    property OutlineShader: Boolean read FOutlineShader write FOutlineShader;

  end;

  { TSpaceActor }
  TSpaceActor = class
  private
    FActorIndex: Integer;
    FAlignToHorizon: Boolean;
    FDoCollision: Boolean;
    FEngine: TSpaceEngine;
    FMaxSpeed: Single;
    FModel: TModel;
    FRadarColor: TColorB;
    FRadarString: PChar;
    FSmoothForward: Single;
    FSmoothLeft: Single;
    FSmoothUp: Single;
    FSmoothPitchDown: Single;
    FSmoothRollRight: Single;
    FSmoothYawLeft: Single;
    FPosition: TVector3;
    FRotation: TQuaternion;
    FScale: Single;
    FTag: Integer;
    FIsDead: Boolean;
    FThrottleResponse: Single;
    FProject: TVector4; // projected 2d position and depth
    FTurnRate: Single;
    FTurnResponse: Single;
    FVelocity: TVector3;
    FVisualRotation: TQuaternion;
    FVisualBank: Single;
    FVisible: Boolean;
    FRay: TRay;
    FCollider: TCollider;
    procedure SetModel(AValue: TModel);
    procedure SetPosition(AValue: TVector3);
    procedure SetScale(AValue: Single);

  public
    InputForward: Single;
    InputLeft: Single;
    InputUp: Single;
    InputPitchDown: Single;
    InputRollRight: Single;
    InputYawLeft: Single;

    constructor Create(const AParent: TSpaceEngine); virtual;
    destructor Destroy; override;
    procedure Collision(const Other: TSpaceActor); overload; virtual;
    procedure Collision; overload; virtual;
    procedure Dead; virtual;
    procedure OnCollision(const {%H-}Actor: TSpaceActor); virtual;
    procedure Update(const DeltaTime: Single); virtual;
    procedure Render(ShowDebugAxes: Boolean; ShowDebugRay: Boolean); virtual;
    procedure SetShader(Shader: TShader);

    function GetForward:TVector3;
    function GetForward(Distance: Single): TVector3;

    function GetBack:TVector3;
    function GetBack(Distance: Single): TVector3;

    function GetRight:TVector3;
    function GetRight(Distance: Single): TVector3;

    function GetLeft:TVector3;
    function GetLeft(Distance: Single): TVector3;

    function GetUp:TVector3;
    function GetUp(Distance: Single): TVector3;

    function GetDown:TVector3;
    function GetDown(Distance: Single): TVector3;

    function TransformPoint(point: TVector3): TVector3;
    function VectorFromMesh(MeshNumber: integer; VertexNumber: integer): TVector3;

    procedure RotateLocalEuler(axis: TVector3; degrees: single);
    procedure RotationToActor(targetActor: TSpaceActor; z_axis: boolean = false; deflection: Single = 0.05);
    procedure RotationToVector(target: TVector3; z_axis: boolean = false; deflection: Single = 0.05);
    property ActorModel: TModel read FModel write SetModel;
    property MatixTransform: TMatrix read FModel.transform write FModel.transform;
    property Engine: TSpaceEngine read FEngine write FEngine;
    property Position: TVector3 read FPosition write SetPosition;
    property Rotation: TQuaternion read FRotation write FRotation;
    property Velocity: TVector3 read FVelocity write FVelocity;
    property RadarColor: TColorB read FRadarColor write FRadarColor;
    property RadarStrinig: PChar read FRadarString write FRadarString;
  published
    property IsDead: Boolean read FIsDead;
    property Visible: Boolean read FVisible write FVisible;
    property Tag: Integer read FTag write FTag;
    property Scale: Single read FScale write SetScale;
    property ActorIndex: Integer read FActorIndex write FActorIndex;
    property DoCollision: Boolean read FDoCollision write FDoCollision;
    property MaxSpeed: Single read FMaxSpeed write FMaxSpeed default 20;
    property ThrottleResponse: Single read FThrottleResponse write FThrottleResponse default 10;
    property TurnResponse: Single read FTurnResponse write FTurnResponse default 10;
    property TurnRate: Single read FTurnRate write FTurnRate default 180;
    property AlignToHorizon: Boolean read FAlignToHorizon write FAlignToHorizon default True;

  end;

  { TSpaceShipActor }
  TSpaceShipActor = class(TSpaceActor)
  private
    FBrightTrailColor: TColorB;
    RungCount: integer;
    RungIndex: integer;
    Rungs: array [0..16] of TrailRung;
    LastRungPosition: TVector3;
    FTrailColor: TColorB;
    FTrailLPoint: array[0..12] of TVector3;
    FTrailRPoint: array[0..12] of TVector3;
    FTrailEngineBright: Single;
    procedure PositionActiveTrailRung();
    procedure DrawTrail;
  public
    constructor Create(const AParent: TSpaceEngine); override;
    procedure OnCollision(const {%H-}Actor: TSpaceActor); override;
    procedure Update(const DeltaTime: Single); override;
    procedure Render(ShowDebugAxes: Boolean; ShowDebugRay: Boolean); override;
    procedure SetTrailLeftPoint(NumberPoint: Integer; Mesh: Integer; PointValue: TVector3);
    procedure SetTrailRightPoint(NumberPoint: Integer; Mesh: Integer; PointValue: TVector3);
    procedure SetTrailPointVector3(PointNumber, MeshNumber: Integer; TrailLeftVector, TrailRightVector: TVector3);
    function GetTrailVector3(MeshIndex: Integer; V1, V2, V3: Integer): TVector3;
    property TrailColor: TColorB read FTrailColor write FTrailColor;
    property BrightTrailColor: TColorB read FBrightTrailColor;
  end;

  procedure StartTimer(timer:PTimer; lifetime: single);
  procedure UpdateTimer(timer: PTimer);
  function TimerDone(timer: PTimer): boolean;


implementation

const RungDistance = 0.5;
const RungTimeToLive = 0.5;

procedure StartTimer(timer: PTimer; lifetime: single);
begin
  if timer <> nil then  timer^.Lifetime:=lifetime;
end;

procedure UpdateTimer(timer: PTimer);
begin
  // subtract this frame from the timer if it's not allready expired
  if (timer <> nil) and (timer^.Lifetime > 0) then
      timer^.Lifetime -= GetFrameTime;
end;

function TimerDone(timer: PTimer): boolean;
begin
  if timer <> nil then result:= timer^.Lifetime  <= 0 else
  result:= false;
end;

{ TSpaceDust }
constructor TSpaceDust.Create(Size: single; Count: integer);
var point: TVector3; color: TColorB; i: integer;
begin
  FExtent := size * 0.5;
  SetLength(FPoints,count);
  SetLength(FColors,count);
  for i:=0 to count-1 do
  begin
    point := Vector3Create(
    GetPrettyBadRandomFloat(-FExtent, FExtent),
    GetPrettyBadRandomFloat(-FExtent, FExtent),
    GetPrettyBadRandomFloat(-FExtent, FExtent));
    FPoints[i]:= point;
    color := ColorCreate(GetRandomValue(192, 255), GetRandomValue(192, 255), GetRandomValue(192, 255),255);
    Fcolors[i]:= Color;
  end;
end;

procedure TSpaceDust.UpdateViewPosition(ViewPosition: TVector3);
var size:single; i: integer;
begin
  size := FExtent * 2;
  for i:=0 to Length(FPoints) -1 do
  begin
    if (FPoints[i].x > viewPosition.x + FExtent) then FPoints[i].x -= size;
    if (FPoints[i].x < viewPosition.x - FExtent) then FPoints[i].x += size;
    if (FPoints[i].y > viewPosition.y + FExtent) then FPoints[i].y -= size;
    if (FPoints[i].y < viewPosition.y - FExtent) then FPoints[i].y += size;
    if (FPoints[i].z > viewPosition.z + FExtent) then FPoints[i].z -= size;
    if (FPoints[i].z < viewPosition.z - FExtent) then FPoints[i].z += size;
  end;
end;

procedure TSpaceDust.Draw(ViewPosition, Velocity: TVector3; DrawDots: boolean);
var i, farAlpha: integer;  distance, farLerp, cubeSize: single;
begin
  BeginBlendMode(BLEND_ADDITIVE);
  for i:=0 to Length(FPoints) -1 do
  begin
    distance := Vector3Distance(viewPosition, FPoints[i]);
    farLerp := Clamp(Normalize(distance, FExtent * 0.9, FExtent), 0, 1);
    farAlpha := round(Lerp(255, 0, farLerp));
    cubeSize := 0.01;
    if (drawDots) then DrawSphereEx(FPoints[i], cubeSize, 2, 2, ColorCreate(FColors[i].r, FColors[i].g, FColors[i].b, farAlpha));
    DrawLine3D(Vector3Add(FPoints[i], Vector3Scale(velocity, 0.01)),
    FPoints[i], ColorCreate(FColors[i].r, FColors[i].g, FColors[i].b, farAlpha));
  end;
  rlDrawRenderBatchActive();
  EndBlendMode();
end;

{ TSpaceCrosshair }
constructor TSpaceCrosshair.Create(const modelFileName: PChar);
begin
  FCrosshairColor := DARKGREEN;
  if modelFileName <> nil then
  FCrosshairModel := LoadModel(modelFileName)
  else TraceLog(LOG_ERROR, 'Space Engine: crosshair not load.');
end;

destructor TSpaceCrosshair.Destroy;
begin
  if @FCrosshairModel <> nil then
  begin
    UnloadModel(FCrosshairModel);
    TraceLog(LOG_INFO, 'Space Engine: crosshair destroy and unload.');
  end else TraceLog(LOG_ERROR, 'Space Engine: crosshair not destroy');
inherited Destroy;
end;

procedure TSpaceCrosshair.PositionCrosshairOnActor(const Actor: TSpaceActor; distance: Single);
var crosshairPos: TVector3;
    crosshairTransform: TMatrix;
begin
  crosshairPos := Vector3Add(Vector3Scale(Actor.GetForward(), distance), Actor.Position);
  crosshairTransform := MatrixTranslate(crosshairPos.x, crosshairPos.y, crosshairPos.z);
  crosshairTransform := MatrixMultiply(QuaternionToMatrix(Actor.Rotation), crosshairTransform);
  FCrosshairModel.transform := crosshairTransform;
end;

procedure TSpaceCrosshair.DrawCrosshair;
begin
  BeginBlendMode(BLEND_ADDITIVE);
  rlDisableDepthTest();
  DrawModel(FCrosshairModel, Vector3Zero(), 1, FCrosshairColor);
  rlEnableDepthTest();
  EndBlendMode();
end;

{ TSpaceCamera }
constructor TSpaceCamera.Create(isPerspective: boolean; fieldOfView: single);
begin
  Camera.position := Vector3Create(0, 10, -10);
  Camera.target := Vector3Create(0, 0, 0);
  Camera.up := Vector3Create(0, 1, 0);
  Camera.fovy := fieldOfView;

  if isPerspective then
  Camera.projection:=CAMERA_PERSPECTIVE
  else
  Camera.projection:= CAMERA_ORTHOGRAPHIC;

  FSmoothPosition := Vector3Zero();
  FSmoothTarget := Vector3Zero();
  FSmoothUp := Vector3Zero();
end;

procedure TSpaceCamera.BeginDrawing;
begin
  BeginMode3D(Camera);
end;

procedure TSpaceCamera.EndDrawing;
begin
  EndMode3D();
end;

procedure TSpaceCamera.FollowActor(const Actor: TSpaceActor; deltaTime: Single);
var  pos, actorForwards, target, up: TVector3;
begin
  pos := Actor.TransformPoint(Vector3Create( 0, 1, -3 ));
  actorForwards := Vector3Scale(Actor.GetForward(), 25);
  target := Vector3Add(Actor.FPosition, ActorForwards);
  up := Actor.GetUp();
  MoveTo(pos, target, up, deltaTime);
end;

procedure TSpaceCamera.MoveTo(position_, target, up: TVector3; deltaTime: Single);
begin
  Camera.position := SmoothDamp(Camera.position, position_, 10, deltaTime);
  Camera.target := SmoothDamp(Camera.target, target, 5, deltaTime);
  Camera.up := SmoothDamp(Camera.up, up, 5, deltaTime);
end;

procedure TSpaceCamera.SetPosition(position_, target, up: TVector3);
begin
  Camera.position := position_;
  Camera.target := target;
  Camera.up := up;
  FSmoothPosition := position_;
  FSmoothTarget := target;
  FSmoothUp := up;
end;

function TSpaceCamera.GetPosition: TVector3;
begin
  result:=Camera.position;
end;

function TSpaceCamera.GetTarget: TVector3;
begin
  result:=Camera.target;
end;

function TSpaceCamera.GetUp: TVector3;
begin
  result:=Camera.up;
end;

function TSpaceCamera.GetFovy: Single;
begin
  result:=Camera.fovy;
end;

{ TSpaceEngine }
function TSpaceEngine.GetCount: Integer;
begin
  if FActorList <> nil then Result := FActorList.Count
  else Result := 0;
end;

function TSpaceEngine.GetModelActor(const Index: Integer): TSpaceActor;
begin
  if (FActorList <> nil) and (Index >= 0) and (Index < FActorList.Count) then
  Result := TSpaceActor(FActorList[Index])
  else
  Result := nil;
end;

constructor TSpaceEngine.Create;
var CubeMesh: TMesh;
    skyboxVs, skyboxFs: PChar;
    toonFs, toonVs, normFs, normVs, outlineFs: PChar;
    SkyBoxMap: Integer = MATERIAL_MAP_CUBEMAP;
    UsesHDR: Boolean = False;
    atlasNumber: integer;
begin
  FActorList := TList.Create;
  FDeadActorList := TList.Create;
  FSpaceDust := TSpaceDust.Create(50, 500);
  CrosshairNear := TSpaceCrosshair.Create(nil);
  CrosshairFar := TSpaceCrosshair.Create(nil);
  UsesHDR := False;
  CubeMesh := GenMeshCube(1, 1, 1);
  FSkyBox := LoadModelFromMesh(CubeMesh);
  FSkyBoxQuality := SBQOriginal;
  FUsesSkyBox := false;

  // skybox shader
  {$I ../shaders/skybox.inc}
  FSkyBox.materials[0].shader := LoadShaderFromMemory(SkyBoxVs, SkyBoxFs);
  TraceLog(LOG_Info,PChar('Space Engine: Shader skybox load.'));
  SkyBoxMap := MATERIAL_MAP_CUBEMAP;

  SetShaderValue(FSkyBox.materials[0].shader,
  GetShaderLocation(FSkyBox.materials[0].shader, 'environmentMap'),
  @SkyBoxMap, SHADER_UNIFORM_INT);

  SetShaderValue(FSkyBox.materials[0].shader,
  GetShaderLocation(FSkyBox.materials[0].shader, 'vflipped'),
  @UsesHDR, SHADER_UNIFORM_INT);


  // normal shader
  {$I ../shaders/toon_light.inc}
  FNormShader := LoadShaderFromMemory(normVs, normFs);
  FNormShader.locs[SHADER_LOC_MATRIX_MODEL] := GetShaderLocation(FNormShader, 'matModel');

  // outline shader
  FOutline := LoadShaderFromMemory(nil, outlineFs);

  // lighting shader
  FLightShader := LoadShaderFromMemory(toonVs, toonFs);
  FLightShader.locs[SHADER_LOC_MATRIX_MODEL] := GetShaderLocation(FLightShader, 'matModel');


  // make a light (max 4 but we're only using 1)   // todo set light position
  FLight := CreateLight(LIGHT_POINT, Vector3Create( 2,4,4 ), Vector3Zero(), WHITE, FLightShader);
  FTarget := LoadRenderTexture(GetScreenWidth, GetScreenHeight);


end;

destructor TSpaceEngine.Destroy;
var i: integer;
begin
  for i := 0 to FActorList.Count - 1 do
  begin
    TSpaceActor(FActorList.Items[i]).Dead;
  end;

  ClearDeadActor;

  FActorList.Free;
  FDeadActorList.Free;

  TraceLog(LOG_Info,PChar('Space Engine: Engine Destroy'));
  inherited Destroy;
end;

procedure TSpaceEngine.Add(const ModelActor: TSpaceActor);
var L, H, I: Integer;
begin
  L := 0;
  H := FActorList.Count - 1;
  while (L <= H) do
  begin
    I := (L + H) div 2;
    L := I + 1
  end;
  FActorList.Insert(L, ModelActor);
end;

procedure TSpaceEngine.Remove(const ModelActor: TSpaceActor);
begin
  FActorList.Remove(ModelACtor);
end;

procedure TSpaceEngine.Change(ModelActor: TSpaceActor; Dest: TSpaceEngine);
begin
  Dest.Add(ModelActor);
  ModelActor.Engine := Dest;
  FActorList.Remove(ModelActor);
end;

procedure TSpaceEngine.Update(DeltaTime: Single; DustViewPosition: TVector3);
var i: Integer;
begin
  FSpaceDust.UpdateViewPosition(DustViewPosition);
  for i := 0 to FActorList.Count - 1 do
  begin
    TSpaceActor(FActorList.Items[i]).Update(DeltaTime);
  end;
end;

procedure TSpaceEngine.Render(Camera: TSpaceCamera; ShowDebugAxes,
  ShowDebugRay: Boolean; DustVelocity: TVector3; DustDrawDots: boolean);
var i ,px, py, playerX, playerY: Integer;  view, perps: TMatrix; p: TVector4;
    hsw, hsh: single; TestPos: TVector2;
begin
  hsw := GetScreenWidth / 2.0;
  hsh := GetScreenHeight / 2.0;

  view := MatrixLookAt(camera.Camera.position, camera.Camera.target, camera.Camera.up);
  perps := MatrixPerspective(camera.Camera.fovy, GetScreenWidth / GetScreenHeight, 0.01, 1000.0);

  // update the light shader with the camera view position

  SetShaderValue(FLightShader, FLightShader.locs[SHADER_LOC_VECTOR_VIEW], @camera.Camera.position.x, SHADER_UNIFORM_VEC3);
  SetShaderValue(FNormShader, FLightShader.locs[SHADER_LOC_VECTOR_VIEW], @camera.Camera.position.x, SHADER_UNIFORM_VEC3);
  UpdateLightValues(FLightShader, Flight);
  UpdateLightValues(FNormShader, Flight);

  if FUsesSkyBox then
  begin
    Camera.BeginDrawing;
      // render skybox
      rlDisableBackfaceCulling();
      rlDisableDepthMask();
      DrawModel(FSkyBox, Vector3Create(0, 0, 0), 1.0, WHITE);
      rlEnableBackfaceCulling();
      rlEnableDepthMask();
    Camera.EndDrawing;
  end;


 // render first to the normals texture for outlining
 // to a texture

 BeginTextureMode(FTarget);
     ClearBackground(ColorCreate(255,255,255,255));
     Camera.BeginDrawing;
     for i := 0 to FActorList.Count - 1 do
     begin
       if not TSpaceActor(FActorList.Items[i]).ClassNameIs('TWarpGlow') then
       TSpaceActor(FActorList.Items[i]).SetShader(FNormShader);
       TSpaceActor(FActorList.Items[i]).Render(ShowDebugAxes,ShowDebugRay);
       TSpaceActor(FActorList.Items[i]).FProject := Projection(TSpaceActor(FActorList.Items[i]).FPosition, view, perps);
     end;
     Camera.EndDrawing;
 EndTextureMode();


  Camera.BeginDrawing;

  CrosshairNear.DrawCrosshair();
  CrosshairFar.DrawCrosshair();


  for i := 0 to FActorList.Count - 1 do
  begin
    if not TSpaceActor(FActorList.Items[i]).ClassNameIs('TWarpGlow') then
    TSpaceActor(FActorList.Items[i]).SetShader(FLightShader);
    TSpaceActor(FActorList.Items[i]).Render(ShowDebugAxes,ShowDebugRay);
    TSpaceActor(FActorList.Items[i]).FProject := Projection(TSpaceActor(FActorList.Items[i]).FPosition, view, perps);
  end;

  CrosshairNear.DrawCrosshair();
  CrosshairFar.DrawCrosshair();

  DrawGrid(10, 1.0);        // Draw a grid

  FSpaceDust.Draw(Camera.GetPosition(), DustVelocity, DustDrawDots);


  Camera.EndDrawing;

  // show the modified normals texture
  //DrawTexturePro(Ftarget.texture,
  //RectangleCreate( 0, 0, Ftarget.texture.width, -Ftarget.texture.height ),
  //RectangleCreate( 0, 0, Ftarget.texture.width/8.0, Ftarget.texture.height/8.0 ),
  //Vector2Create(0,0), 0, WHITE);


  // outline shader uses the normal texture to overlay outlines
 if FOutlineShader then
 begin
 BeginShaderMode(Foutline);
     DrawTexturePro(Ftarget.texture,
     RectangleCreate( 0, 0, Ftarget.texture.width, -Ftarget.texture.height ),
     RectangleCreate( 0, 0, Ftarget.texture.width, Ftarget.texture.height ),
     Vector2Create(0,0), 0, WHITE);
 EndShaderMode();
 end;

  if FDrawRadar then
  for i := 0 to FActorList.Count - 1 do
  begin
    p :=  TSpaceActor(FActorList.Items[i]).FProject;
    p.x/=p.w;
    p.y/=p.w;
    px := Round( hsw + p.x * (hsw / 920));
    py := Round(GetScreenHeight - (hsh / 3 ) + p.y * (hsh / 920));

    if px > GetScreenWidth then px := GetScreenWidth - 30 else
    if px < 0 then px := 30;

    if py > GetScreenHeight then py := GetScreenHeight -30 else
    if py < 0 then py := 30;

 //   BeginBlendMode(BLEND_ADDITIVE);
    DrawCircle( px, py, 3, TSpaceActor(FActorList.Items[i]).FRadarColor);

    //if TSpaceActor(FActorList.Items[i]).Tag = 0 then
    //DrawText(TSpaceActor(FActorList.Items[i]).FRadarString, px + 6, py - 4 ,8, TSpaceActor(FActorList.Items[i]).FRadarColor)
    //else
    //DrawText(PChar( IntToStr(px) + ' ' +   IntToStr(py)    ), px +6 , py -8 , 8 ,red);
    if TSpaceActor(FActorList.Items[i]).Tag = 0 then
    begin
      playerY := py;
      playerX := px;
    end;
    if (pY > playerY) then DrawLine(px, py ,px , py + 5, TSpaceActor(FActorList.Items[i]).FRadarColor);
    if (pY < playerY) then DrawLine(px, py ,px , py - 5, TSpaceActor(FActorList.Items[i]).FRadarColor);
    if (pX > playerX) then DrawLine(px, py ,px + 5 , py, TSpaceActor(FActorList.Items[i]).FRadarColor);
    if (pX < playerX) then DrawLine(px, py ,px - 5, py, TSpaceActor(FActorList.Items[i]).FRadarColor);


  //  TestPos :=GetWorldToScreenEX(TSpaceActor(FActorList.Items[i]).Position,Camera.Camera, GetScreenWidth,GetScreenHeight);
  //  DrawText(PChar( IntToStr(Round(TestPos.x)) + ' ' +   IntToStr(Round(TestPos.y))    ), px +6 , py -8 , 8 ,red);

    //

    DrawText(TSpaceActor(FActorList.Items[i]).FRadarString, px + 8, py - 4 ,8, TSpaceActor(FActorList.Items[i]).FRadarColor);
      //   EndBlendMode();
  end;
end;

procedure TSpaceEngine.Collision;
var
  i, j: Integer;
begin
  for i := 0 to FActorList.Count - 1 do
  begin
    for j := i + 1 to FActorList.Count - 1 do
    begin
      if (TSpaceActor(FActorList.Items[i]).DoCollision) and
         (TSpaceActor(FActorList.Items[j]).DoCollision) then
     TSpaceActor(FActorList.Items[i]).Collision(TSpaceActor(FActorList.Items[j]));
    end;
  end;
end;

procedure TSpaceEngine.Clear;
begin
  while Count > 0 do
  begin
    Items[Count - 1].Free;
  end;
end;

procedure TSpaceEngine.ClearDeadActor;
begin
  while FDeadActorList.Count -1 >= 0 do
  begin
    TSpaceActor(FDeadActorList.Items[FDeadActorList.Count - 1]).Free;
  end;
end;

procedure TSpaceEngine.GenerateSkyBox(Size: Integer; Color: TColorB; StarCount: Integer);
var TempImage: TImage; i: integer;
begin
  TempImage := GenImageColor(Size * 5, Size, Color);
  for i := 0 to StarCount do
  begin
    ImageDrawPixel(@TempImage, GetRandomValue(1 , TempImage.width),GetRandomValue(1 , TempImage.height), white);
  end;
  FSkyBox.materials[0].maps[MATERIAL_MAP_CUBEMAP].texture :=
  LoadTextureCubemap(TempImage, CUBEMAP_LAYOUT_LINE_HORIZONTAL);
  UnloadImage(TempImage);
  TraceLog(LOG_Info,PChar('Space Engine: Skybox generate'));
end;

procedure TSpaceEngine.GenerateSkyBoxTexture(Filename: string);
var TempImage: TImage;
begin
 TempImage := LoadImage(GetAppDir(Filename));
 FSkyBox.materials[0].maps[MATERIAL_MAP_CUBEMAP].texture :=
 LoadTextureCubemap(TempImage, CUBEMAP_LAYOUT_LINE_HORIZONTAL);
 UnloadImage(TempImage);
 TraceLog(LOG_Info,PChar('Space Engine: Skybox generate'));
end;

procedure TSpaceEngine.SetSkyBoxFileName(AValue: String);
var TempImage: TImage;
begin
  TempImage.format:=PIXELFORMAT_UNCOMPRESSED_R32G32B32A32;
  TempImage := LoadImage(GetAppDir(AValue));

  case FSkyBoxQuality of
  SBQOriginal:
    TraceLog(LOG_Info,PChar('Space Engine: Original image quality of the skybox is used.'));
  SBQLow:
    begin
      ImageResize(@TempImage, TempImage.width div 2, TempImage.height div 2);
      TraceLog(LOG_Info,PChar('Space Engine: Low image quality of the skybox is used.'));
    end;
  SBQVeryLow:
    begin
      ImageResize(@TempImage, TempImage.width div 4, TempImage.height div 4);
      TraceLog(LOG_Info,PChar('Space Engine:: Very low image quality of the skybox is used.'));
    end;
  end;

  TraceLog(LOG_Info,PChar('Space Engine:: File loading: ' + Avalue));

  FSkyBox.materials[0].maps[MATERIAL_MAP_CUBEMAP].texture :=
  LoadTextureCubemap(TempImage, CUBEMAP_LAYOUT_AUTO_DETECT);

  UnloadImage(TempImage);
  TraceLog(LOG_Info,PChar('Space Engine: Image unload: ' + Avalue));
end;



{ TGearSpaceActor }

procedure TSpaceActor.SetModel(AValue: TModel);
begin
  FModel:=AValue;
  FCollider := CreateCollider(Vector3Scale(GetModelBoundingBox(Self.FModel).min,FScale),
                              Vector3Scale(GetModelBoundingBox(Self.FModel).max,FScale));

  SetColliderRotation(@FCollider, FVisualRotation);
  SetColliderTranslation(@FCollider, FPosition);

  FModel.transform := GetColliderTransform(@FCollider);
end;

procedure TSpaceActor.SetPosition(AValue: TVector3);
begin
  FPosition:=AValue;
  SetColliderRotation(@self.FCollider,FVisualRotation);
  SetColliderTranslation(@self.FCollider, FPosition);
end;

procedure TSpaceActor.SetScale(AValue: Single);
begin
  if FScale=AValue then Exit;
  FScale:=AValue;
  FCollider := CreateCollider(Vector3Scale(GetModelBoundingBox(FModel).min,FScale),
                              Vector3Scale(GetModelBoundingBox(FModel).max,FScale));
end;



constructor TSpaceActor.Create(const AParent: TSpaceEngine);
begin
  FEngine := AParent;
  FIsDead := False;
  FVisible := True;
  FTag := 0;
  FScale := 1;
  Fmodel := Default(TModel);
  FPosition := Vector3Zero();
  FVelocity := Vector3Zero();
  FRotation := QuaternionIdentity();
  FScale:= 1;
  FMaxSpeed:= 20;
  FThrottleResponse:= 10;
  TurnRate:= 180;
  TurnResponse:= 10;

  FAlignToHorizon := True;



  Engine.Add(Self);
end;

destructor TSpaceActor.Destroy;
begin
  Engine.Remove(Self);
  Engine.FDeadActorList.Remove(Self);
 // UnloadModel(Self.ActorModel);
  inherited Destroy;
end;
{
procedure TSpaceActor.Assign(const Value: TSpaceActor);
begin

end;
}

procedure TSpaceActor.Collision(const Other: TSpaceActor);
var IsCollide: Boolean; Correction: TVector3;
begin
  IsCollide := false;

  SetColliderRotation(@FCollider, FVisualRotation);
  SetColliderTranslation(@FCollider, FPosition);

  Correction := GetCollisionCorrection(@FCollider, @Other.FCollider);
  AddColliderTranslation(@FCollider, Correction);

  IsCollide := TestColliderPair(@FCollider,@Other.FCollider);

  if IsCollide then
  begin
    FPosition := Vector3Transform(Vector3Zero, Fcollider.matTranslate);
    Other.FPosition := Vector3Transform(Vector3Zero, Other.FCollider.matTranslate);

    OnCollision(Other);
    Other.OnCollision(Self);
  end;

end;

procedure TSpaceActor.Collision;
var
   i: Integer;
begin
 for i:=0 to Engine.Count-1 do
 begin
   Collision(Engine.Items[i]);
 end;
end;

procedure TSpaceActor.Dead;
begin
  if not FIsDead then
  begin
    FIsDead := True;
    FEngine.FDeadActorList.Add(Self);
  end;
end;

procedure TSpaceActor.OnCollision(const Actor: TSpaceActor);
begin
 // FPosition := Vector3Transform(Vector3Zero, Fcollider.matTranslate);
end;

procedure TSpaceActor.Update(const DeltaTime: Single);
var forwardSpeedMultipilier, autoSteerInput, targetVisualBank: single;
    targetVelocity: TVector3;
    transform: TMatrix;
begin
  // Give the ship some momentum when accelerating. Придать кораблю импульс при ускорении.
  FSmoothForward := SmoothDamp(FSmoothForward, InputForward, ThrottleResponse, deltaTime);
  FSmoothLeft := SmoothDamp(FSmoothLeft, InputLeft, ThrottleResponse, deltaTime);
  FSmoothUp := SmoothDamp(FSmoothUp, InputUp, ThrottleResponse, deltaTime);
  // Flying in reverse should be slower. Полет задним ходом должен быть медленнее.
  forwardSpeedMultipilier := ifthen(FSmoothForward > 0.0, 1.0, 0.33);

  targetVelocity := Vector3Zero();
  targetVelocity := Vector3Add(
  targetVelocity,Vector3Scale(GetForward(), MaxSpeed * forwardSpeedMultipilier * FSmoothForward));

  targetVelocity := Vector3Add(
   		    targetVelocity,
   		    Vector3Scale(GetUp(), MaxSpeed * 0.5 * FSmoothUp));

  targetVelocity := Vector3Add(
   		    targetVelocity,
   		    Vector3Scale(GetLeft(), MaxSpeed * 0.5 * FSmoothLeft));

  FVelocity := SmoothDamp(FVelocity, targetVelocity, 2.5, deltaTime);
  FPosition := Vector3Add(FPosition, Vector3Scale(FVelocity, deltaTime));

  //Give the ship some inertia when turning. These are the pilot controlled rotations.
  //Придаем кораблю инерцию при повороте. Это управляемые пилотом вращения.
  FSmoothPitchDown := SmoothDamp(FSmoothPitchDown, InputPitchDown, TurnResponse, deltaTime);
  FSmoothRollRight := SmoothDamp(FSmoothRollRight, InputRollRight, TurnResponse, deltaTime);
  FSmoothYawLeft := SmoothDamp(FSmoothYawLeft, InputYawLeft, TurnResponse, deltaTime);

  RotateLocalEuler(Vector3Create(0, 0, 1), FSmoothRollRight * TurnRate * deltaTime);
  RotateLocalEuler(Vector3Create(1, 0, 0), FSmoothPitchDown * TurnRate * deltaTime);
  RotateLocalEuler(Vector3Create(0, 1, 0), FSmoothYawLeft * TurnRate * deltaTime);

  //Auto-roll to align to horizon
  //Автоматический поворот для выравнивания по горизонту
  if (FAlignToHorizon) and (abs(GetForward().y) < 0.8) then
  begin
    autoSteerInput := GetRight().y;
    RotateLocalEuler(Vector3Create( 0, 0, 1 ), autoSteerInput * TurnRate * 0.5 * deltaTime);
  end;

  //When yawing and strafing, there's some bank added to the model for visual flavor.
  //При стрейфе к модели добавляется некоторый банк для визуального вкуса.
  targetVisualBank := (-30 * DEG2RAD * FSmoothYawLeft) + (-15 * DEG2RAD * FSmoothLeft);
  FVisualBank := SmoothDamp(FVisualBank, targetVisualBank, 10, deltaTime);
  FVisualRotation := QuaternionMultiply(FRotation, QuaternionFromAxisAngle(Vector3Create( 0, 0, 1 ), FVisualBank));

  //En: Sync up the raylib representation of the model with the ship's position so that processing
  // doesn't have to happen at the render stage.
  //Ru: Синхронизируем представление модели в raylib с позицией корабля
  // не обязательно на этапе рендеринга.
  transform := MatrixTranslate(FPosition.x, FPosition.y, FPosition.z);
  transform := MatrixMultiply(QuaternionToMatrix(FvisualRotation), transform);
  transform := MatrixMultiply(MatrixScale(Scale,Scale,Scale),transform);
  //FModel.transform := transform;
  SetColliderRotation(@self.FCollider, FvisualRotation);
  SetColliderTranslation(@self.FCollider, Self.FPosition);

  FModel.transform := MatrixMultiply(MatrixScale(FScale,FScale,FScale),GetColliderTransform(@FCollider));

  // TODO
  FRay.direction := GetForward;
  FRay.position := Position;
end;

procedure TSpaceActor.Render(ShowDebugAxes: Boolean; ShowDebugRay: Boolean);
var vec: TVector3; i: integer;
begin
  if not FVisible then Exit;
  DrawModel(FModel, Vector3Zero, 1, White);
  //DrawTrail;

  if (ShowDebugAxes) then
  begin
    BeginBlendMode(BLEND_ADDITIVE);

    DrawLine3D(Position, Vector3Add(Position, GetForward),ColorCreate( 0, 0, 255, 255 ));
    DrawLine3D(Position, Vector3Add(Position, GetLeft), ColorCreate( 255, 0, 0, 255 ));
    DrawLine3D(Position, Vector3Add(Position, GetUp), ColorCreate( 0, 255, 0, 255 ));

  {
    vec := Vector3Add(Vector3Scale(GetForward(), 90), Position);
    DrawLine3D(Vector3Transform(VectorFromMesh(1,0),FModel.transform), vec,RED);
      }

     {
    for i := 0  to Fmodel.meshes[1].vertexCount -1 do
    begin
    vec := Vector3Create(FModel.meshes[1].vertices[i * 3],
                         FModel.meshes[1].vertices[i * 3 + 1],
                         FModel.meshes[1].vertices[i * 3 + 2]);

      }


    //DrawCubeV(Vector3Transform(Self.GetTrailVector3(1, 0,1,2) , FModel.transform),Vector3Create(0.01,0.01,0.01),RED);

    //DrawSphere(Vector3Transform(vec, FModel.transform), 0.01,RED);
    //end;
    //end;

   // vec := Vector3Create(FModel.meshes[1].vertices[2 * 3],
    //                     FModel.meshes[1].vertices[2 * 3 + 1],
     //                    FModel.meshes[1].vertices[2 * 3 + 2]);


    DrawCubeV(Vector3Transform(vec, FModel.transform),Vector3Create(0.01,0.01,0.01),Green);


    DrawLine3D(FCollider.vertGlobal[0], FCollider.vertGlobal[1], SKYBLUE);
    DrawLine3D(FCollider.vertGlobal[2], FCollider.vertGlobal[3], SKYBLUE);

    DrawLine3D(FCollider.vertGlobal[4], FCollider.vertGlobal[5], SKYBLUE);
    DrawLine3D(FCollider.vertGlobal[6], FCollider.vertGlobal[7], SKYBLUE);

    DrawLine3D(FCollider.vertGlobal[0], FCollider.vertGlobal[2], SKYBLUE);
    DrawLine3D(FCollider.vertGlobal[1], FCollider.vertGlobal[3], SKYBLUE);

    DrawLine3D(FCollider.vertGlobal[4], FCollider.vertGlobal[6], SKYBLUE);
    DrawLine3D(FCollider.vertGlobal[5], FCollider.vertGlobal[7], SKYBLUE);

    DrawLine3D(FCollider.vertGlobal[1], FCollider.vertGlobal[5], SKYBLUE);
    DrawLine3D(FCollider.vertGlobal[3], FCollider.vertGlobal[7], SKYBLUE);

    DrawLine3D(FCollider.vertGlobal[0], FCollider.vertGlobal[4], SKYBLUE);
    DrawLine3D(FCollider.vertGlobal[2], FCollider.vertGlobal[6], SKYBLUE);

    EndBlendMode();
   end;
  if (ShowDebugRay) then DrawRay(FRay, WHITE);
end;

procedure TSpaceActor.SetShader(Shader: TShader);
var i: Integer;
begin
  for i:=0 to FModel.materialCount-1  do
  FModel.materials[i].shader := Shader;
end;


function TSpaceActor.GetForward: TVector3;
begin
  result:= Vector3RotateByQuaternion(Vector3Create(0,0,1), FRotation);
end;

function TSpaceActor.GetForward(Distance: Single): TVector3;
begin
  result:= Vector3RotateByQuaternion(Vector3Create(0,0,Distance), FRotation);
end;

function TSpaceActor.GetBack: TVector3;
begin
  result:= Vector3RotateByQuaternion(Vector3Create(0,0,-1), FRotation);
end;

function TSpaceActor.GetBack(Distance: Single): TVector3;
begin
  result:= Vector3RotateByQuaternion(Vector3Create(0,0,-Distance), FRotation);
end;

function TSpaceActor.GetRight: TVector3;
begin
  result:= Vector3RotateByQuaternion(Vector3Create(-1,0,0), FRotation);
end;

function TSpaceActor.GetRight(Distance: Single): TVector3;
begin
  result:= Vector3RotateByQuaternion(Vector3Create(-Distance,0,0), FRotation);
end;

function TSpaceActor.GetLeft: TVector3;
begin
  result:= Vector3RotateByQuaternion(Vector3Create(1,0,0), FRotation);
end;

function TSpaceActor.GetLeft(Distance: Single): TVector3;
begin
  result:= Vector3RotateByQuaternion(Vector3Create(Distance,0,0), FRotation);
end;

function TSpaceActor.GetUp: TVector3;
begin
  result:= Vector3RotateByQuaternion(Vector3Create(0,1,0), FRotation);
end;

function TSpaceActor.GetUp(Distance: Single): TVector3;
begin
  result:= Vector3RotateByQuaternion(Vector3Create(0,Distance,0), FRotation);
end;

function TSpaceActor.GetDown: TVector3;
begin
  result:= Vector3RotateByQuaternion(Vector3Create(0,-1,0), FRotation);
end;

function TSpaceActor.GetDown(Distance: Single): TVector3;
begin
  result:= Vector3RotateByQuaternion(Vector3Create(0,-Distance,0), FRotation);
end;

function TSpaceActor.TransformPoint(point: TVector3): TVector3;
var mPos, mRot, matrix: TMatrix;
begin
  mPos:= MatrixTranslate(FPosition.x, FPosition.y, FPosition.z);
  mRot:= QuaternionToMatrix(FRotation);
  matrix:= MatrixMultiply(mRot, mPos);
  result:= Vector3Transform(point, matrix);
end;

function TSpaceActor.VectorFromMesh(MeshNumber: integer; VertexNumber: integer): TVector3;
begin
  result := Vector3Create(FModel.meshes[MeshNumber].vertices[VertexNumber * 3],
                          FModel.meshes[MeshNumber].vertices[VertexNumber * 3 + 1],
                          FModel.meshes[MeshNumber].vertices[VertexNumber * 3 + 2]);
end;

procedure TSpaceActor.RotateLocalEuler(axis: TVector3; degrees: single);
var radians: single;
begin
  radians:= degrees * DEG2RAD;
  FRotation:= QuaternionMultiply(FRotation, QuaternionFromAxisAngle(axis, radians));
end;

procedure TSpaceActor.RotationToActor(targetActor: TSpaceActor;
  z_axis: boolean; deflection: Single);
var
  matrix: TMatrix;
  rotation_: TQuaternion;
  dis, direction: TVector3;
begin
  dis := Vector3Subtract(FPosition, targetActor.Position);
  direction := Vector3Normalize(dis);
  if z_axis then // Get look at and rotation.
  matrix := MatrixLookAt(Vector3Zero, direction, Vector3Create(0,1,1))
  else
  matrix := MatrixLookAt(Vector3Zero, direction, Vector3Create(0,1,0));
  rotation_ := QuaternionInvert(QuaternionFromMatrix(matrix));
  FRotation := QuaternionSlerp(FRotation, rotation_, GetFrameTime * deflection * RAD2DEG);
end;

procedure TSpaceActor.RotationToVector(target: TVector3; z_axis: boolean; deflection: Single);
var
  matrix: TMatrix;
  rotation_: TQuaternion;
  dis, direction: TVector3;
begin
  dis := Vector3Subtract(FPosition, target);
  direction := Vector3Normalize(dis);
  if z_axis then // Get look at and rotation.
  matrix := MatrixLookAt(Vector3Zero, direction, Vector3Create(0,1,1))
  else
  matrix := MatrixLookAt(Vector3Zero, direction, Vector3Create(0,1,0));
  rotation_ := QuaternionInvert(QuaternionFromMatrix(matrix));
  FRotation := QuaternionSlerp(FRotation, rotation_, GetFrameTime * deflection * RAD2DEG);
end;

{ TSpaceShipActor }
procedure TSpaceShipActor.PositionActiveTrailRung();
var j: integer;
begin
  Rungs[RungIndex].TimeToLive := RungTimeToLive;
  for j := 0 to 12 do
  begin
    Rungs[RungIndex].LeftPoint[j] :=  Vector3Transform( FTrailLPoint[j], FModel.transform);
    Rungs[RungIndex].RightPoint[j] := Vector3Transform( FTrailRPoint[j],FModel.transform);
  end;
end;

procedure TSpaceShipActor.DrawTrail;
var i, j: Integer;
    thisRung, nextRung: TrailRung;
    color, fill: TColorB;
begin
  BeginBlendMode(BLEND_ALPHA);
  rlDisableDepthMask();

  for i := 0 to RungCount -1 do
  begin
    if (Rungs[i].TimeToLive <= 0) then continue;
    thisRung := Rungs[i mod RungCount];


    color := TrailColor;
    color.a := 255 * Round(thisRung.TimeToLive / RungTimeToLive);

    fill := color;
    fill.a := Round(color.a / 16);//  (RungCount -1) + i  ); // alpha

    //color.a := Round(thisRung.TimeToLive / RungTimeToLive);



    // The current rung is dragged along behind the ship, so the crossbar shouldn't be drawn.
    // If the crossbar is drawn when the ship is slow, it looks weird having a line behind it.
    nextRung := Rungs[(i + 1) mod RungCount];


    if (nextRung.TimeToLive > 0) and (thisRung.TimeToLive < nextRung.TimeToLive) then
    begin
      if FTrailEngineBright < 0.0 then FTrailEngineBright += 0.05;
      for j := 0 to 12 do
      begin
        DrawTriangle3D(thisRung.LeftPoint[j], thisRung.RightPoint[j], nextRung.LeftPoint[j], fill);
        DrawTriangle3D(nextRung.LeftPoint[j], thisRung.RightPoint[j], nextRung.RightPoint[j], fill);
        DrawTriangle3D(nextRung.LeftPoint[j], thisRung.RightPoint[j], thisRung.LeftPoint[j], fill);
        DrawTriangle3D(nextRung.RightPoint[j], thisRung.RightPoint[j], nextRung.LeftPoint[j], fill);
      end;
    end
     else
     if FTrailEngineBright > - 0.4 then FTrailEngineBright -= 0.05;
  end;

   color := ColorContrast(fill, FTrailEngineBright);
   FBrightTrailColor := Color;
  // ActorModel.materials[2].maps[MATERIAL_MAP_ALBEDO].color := color;   // toto ship type fix

  rlDrawRenderBatchActive();
  rlEnableDepthMask();
  rlEnableDepthTest;
  EndBlendMode();
end;



constructor TSpaceShipActor.Create(const AParent: TSpaceEngine);
begin
  FEngine := AParent;
  FIsDead := False;
  FVisible := True;
  FTag := 0;
  FScale := 1;
  FPosition := Vector3Zero();
  FVelocity := Vector3Zero();
  FRotation := QuaternionIdentity();
  FScale:= 1;
  FMaxSpeed:= 20;
  FThrottleResponse:= 10;
  TurnRate:= 180;
  TurnResponse:= 10;
  FAlignToHorizon := True;
  FModel := Default(TModel);

  TrailColor:= RED;
  RungCount:= 10;
  LastRungPosition := Position;

  Engine.Add(Self);
end;

procedure TSpaceShipActor.OnCollision(const Actor: TSpaceActor);
begin
  inherited OnCollision(Actor);
end;

procedure TSpaceShipActor.Update(const DeltaTime: Single);
var i: Integer;
begin
  inherited Update(DeltaTime);
  // The currently active trail rung is dragged directly behind the ship for a smoother trail.
  PositionActiveTrailRung();
  if (Vector3Distance(FPosition, LastRungPosition) > RungDistance)  then
  begin
    RungIndex := (RungIndex + 1) mod RungCount;
    LastRungPosition := FPosition;
  end;
  for i:= 0 to RungCount -1 do
  begin
    Rungs[i].TimeToLive -= DeltaTime;
  end;
end;

procedure TSpaceShipActor.Render(ShowDebugAxes: Boolean; ShowDebugRay: Boolean);
begin
  inherited Render(ShowDebugAxes, ShowDebugRay);
  DrawTrail;
  DrawCubeV(Vector3Transform(GetTrailVector3(1 , 66 , 67, 68) ,FModel.transform),Vector3Create(0.01,0.01,0.01),RED);
end;

procedure TSpaceShipActor.SetTrailLeftPoint(NumberPoint: Integer;
  Mesh: Integer; PointValue: TVector3);
begin
  FTrailLPoint[NumberPoint] := GetTrailVector3(Mesh, Round(PointValue.x), Round(PointValue.y), Round(PointValue.z));
end;

procedure TSpaceShipActor.SetTrailRightPoint(NumberPoint: Integer;
  Mesh: Integer; PointValue: TVector3);
begin
  FTrailRPoint[NumberPoint] := GetTrailVector3(Mesh, Round(PointValue.x), Round(PointValue.y), Round(PointValue.z));
end;

procedure TSpaceShipActor.SetTrailPointVector3(PointNumber,
  MeshNumber: Integer; TrailLeftVector, TrailRightVector: TVector3);
begin
  FTrailLPoint[PointNumber] := GetTrailVector3(MeshNumber, Round(TrailLeftVector.x), Round(TrailLeftVector.y), Round(TrailLeftVector.z));
  FTrailRPoint[PointNumber] := GetTrailVector3(MeshNumber, Round(TrailRightVector.x), Round(TrailRightVector.y), Round(TrailRightVector.z));
end;

function TSpaceShipActor.GetTrailVector3(MeshIndex: Integer; V1, V2, V3: Integer): TVector3;
begin
  if MeshIndex <= FModel.meshCount-1 then
  result := Vector3Create(FModel.meshes[MeshIndex].vertices[V1],
                          FModel.meshes[MeshIndex].vertices[V2],
                          FModel.meshes[MeshIndex].vertices[V3]) else
  TraceLog(LOG_Error,PChar('Space Engine: Mesh index lagre '));
end;



end.

