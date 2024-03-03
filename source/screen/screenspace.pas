unit ScreenSpace;

{$mode ObjFPC}{$H+}
{.$define DEBUG}


interface

uses
  RayLib, RayMath,Cmem,  Classes, SysUtils, ScreenManager, SpaceEngine, Ships, WarpGate, Global;

type

  { TSpaceShip }

  { TShot }

  TShot = class(TSpaceShipActor)
    Lifetime: single;
    procedure Update(const DeltaTime: Single); override;
  end;



  { TScreenSpace }

  TScreenSpace = class(TGameScreen)
  private
    Engine: TSpaceEngine;
    Ship: TSpaceShip;
    Ship2, Ship3: TSpaceShipActor;
    WarpGlow: TWarpGlow;
    WarpIn: TWarpIn;
    WarpOut: TWarpOut;
    Camera: TSpaceCamera;
    procedure ApplyInputToShip({%H-}Actor: TSpaceActor; step: Single);
    procedure ApplyInputMouseToShip({%H-}Actor: TSpaceActor; MaxStep: Single);
  public
    procedure Init; override; // Init game screen
    procedure Shutdown; override; // Shutdown the game screen
    procedure Update(MoveCount: Single); override; // Update the game screen
    procedure Render; override;  // Render the game screen
    procedure Show; override;  // Celled when the screen is showned
    procedure Hide; override; // Celled when the screen is hidden
  end;


const  GLSL_VERSION = 330;

implementation

{ TShot }

procedure TShot.Update(const DeltaTime: Single);
begin
  inherited Update(DeltaTime);
  LifeTime := LifeTime - 1;
  InputForward := 1000.1;
  If LifeTime <=0 then Dead;
  // se,f.
end;



{ TScreenSpace }


procedure TScreenSpace.ApplyInputToShip(Actor: TSpaceActor; step: Single);
var triggerRight, triggerLeft: Single;
begin
  ship.InputForward := 0;
  if (IsKeyDown(KEY_W)) then ship.InputForward += step;
  if (IsKeyDown(KEY_S)) then ship.InputForward -= step;

  ship.InputForward -= GetGamepadAxisMovement(0, GAMEPAD_AXIS_LEFT_Y);
  ship.InputForward := Clamp(ship.InputForward, -step, step);

  ship.InputLeft := 0;
  if (IsKeyDown(KEY_D)) then ship.InputLeft -= step;
  if (IsKeyDown(KEY_A)) then ship.InputLeft += step;

  ship.InputLeft -= GetGamepadAxisMovement(0, GAMEPAD_AXIS_LEFT_X);
  ship.InputLeft := Clamp(ship.InputLeft, -step, step);

  ship.InputUp := 0;
  if (IsKeyDown(KEY_SPACE)) then ship.InputUp += step;
  if (IsKeyDown(KEY_LEFT_CONTROL)) then ship.InputUp -= step;


  triggerRight := GetGamepadAxisMovement(0, GAMEPAD_AXIS_RIGHT_TRIGGER);
  triggerRight := Remap(triggerRight, -step, step, 0, step);

  triggerLeft := GetGamepadAxisMovement(0, GAMEPAD_AXIS_LEFT_TRIGGER);
  triggerLeft := Remap(triggerLeft, -step, step, 0, step);

  ship.InputUp += triggerRight;
  ship.InputUp -= triggerLeft;
  ship.InputUp := Clamp(ship.InputUp, -step, step);

  ship.InputYawLeft := 0;
  if (IsKeyDown(KEY_RIGHT)) then ship.InputYawLeft -= step;
  if (IsKeyDown(KEY_LEFT)) then ship.InputYawLeft += step;

  ship.InputYawLeft -= GetGamepadAxisMovement(0, GAMEPAD_AXIS_RIGHT_X);
  ship.InputYawLeft := Clamp(ship.InputYawLeft, -step, step);

  ship.InputPitchDown := 0;
  if (IsKeyDown(KEY_UP)) then ship.InputPitchDown += step;
  if (IsKeyDown(KEY_DOWN)) then ship.InputPitchDown -= step;

  ship.InputPitchDown += GetGamepadAxisMovement(0, GAMEPAD_AXIS_RIGHT_Y);
  ship.InputPitchDown := Clamp(ship.InputPitchDown, -step, step);

  ship.InputRollRight := 0;
  if (IsKeyDown(KEY_Q)) then ship.InputRollRight -= step;
  if (IsKeyDown(KEY_E)) then ship.InputRollRight += step;


end;

procedure TScreenSpace.ApplyInputMouseToShip(Actor: TSpaceActor; MaxStep: Single);
var MouseVector, StepVector: TVector2; Step: Single;
begin
  MouseVector := Vector2Subtract(Vector2Create(GetScreenWidth / 2, GetScreenHeight / 2), GetMousePosition);
  StepVector := Vector2Divide(MouseVector,Vector2Create(GetScreenWidth / 2, GetScreenHeight / 2));

  Step := Vector2Length(StepVector);
  if Step > MaxStep then Step := MaxStep;

  ship.InputYawLeft := 0;
  if MouseVector.x < -1 then ship.InputYawLeft -= step;
  if MouseVector.x > 1 then ship.InputYawLeft += step;

  ship.InputPitchDown := 0;
  if MouseVector.y < -1 then ship.InputPitchDown += step;
  if MouseVector.y > 1 then ship.InputPitchDown -= step;

end;

procedure TScreenSpace.Init;

begin
  Engine := TSpaceEngine.Create;
  Engine.CrosshairFar.Create(GetAppDir('data' + '/models/hud/crosshair2.gltf'));

  Engine.SkyBoxQuality:=SBQOriginal;
  Engine.SetSkyBoxFileName('data/textures/skybox/cubemap.png');



  Engine.UsesSkyBox := True;

  Engine.DrawRadar := True;
  //Engine.OutlineShader:= False;

  Camera := TSpaceCamera.Create(True, 50);

  Ship := TSpaceShip.Create(Engine);
  Ship.ActorModel := LoadModel(GetAppDir('data' + '/models/ships/Forwarder.glb'));
  Ship.DoCollision := True;
  Ship.RadarStrinig:='Player';
  Ship.RadarColor := ColorCreate(0,128,0,120);
  Ship.ShipType:= stForwarder;
  Ship.TrailColor := BLUE;
  Randomize;
  //Ship.ShipTextureNumber:=5;// Random(23);


  Ship2 := TSpaceShipActor.Create(Engine);


  Ship2.ActorModel := LoadModel(GetAppDir('data' + '/models/ships/Striker.glb'));
  Ship2.Position := Vector3Create(10,10,10);
  Ship2.DoCollision:= TRUE;
  Ship2.RadarColor := BLUE;
  Ship2.RadarStrinig:='Neutral';
 // Ship2.ActorModel.materials[0].shader := Shader;
 // Ship2.ActorModel.materials[1].shader := Shader;
 // Ship2.ActorModel.materials[1].maps[MATERIAL_MAP_DIFFUSE].color := GREEN;
 Ship2.Scale:=5.1;
 Ship2.Tag:=1;

  Ship3 := TSpaceShipActor.Create(Engine);
//  Ship3.ActorModel := Test.model;
  Ship3.ActorModel := LoadModel(GetAppDir('data' + '/models/ships/Forwarder.glb'));
 // Ship3.Assign(Ship2.ActorModel);


  Ship3.Position := Vector3Create(-14, 30 ,-30);
  Ship3.DoCollision:= TRUE;
  Ship3.RadarColor := RED;
  Ship3.RadarStrinig:='Pirate';
//  Ship3.SetShader(Shader);
//  Ship3.ActorModel.materials[0].maps[MATERIAL_MAP_DIFFUSE].color := BLUE;
//  Ship3.ActorModel.materials[1].maps[MATERIAL_MAP_DIFFUSE].color := BLUE;
 // Ship3.Scale:=0.5;
  Ship3.Tag:=2;
  //Ship3.Scale:=4.1;


  WarpGlow := TWarpGlow.Create(Engine);
  WarpGlow.Position := Vector3Create(20,0,0);
  WarpGlow.RadarColor := ORANGE;
  WarpGlow.RadarStrinig:='WARP';


  WarpIn := TWarpIn.Create(Engine);
  WarpIn.Position := Vector3Create(20,0,0);

  WarpOut := TWarpOut.Create(Engine);
  WarpOut.Position := Vector3Create(20,0,0);



  //GetWorldToScreen(
 {
  LazerModel :=  LoadModel(GetAppDir('data' + '/models/ships/laser.glb'));
  Lazer:= TSpaceShipActor.Create(Engine);

  Lazer.ActorModel :=  LoadModel(GetAppDir('data' + '/models/ships/laser.glb'));
  Lazer.Position := Vector3Create(2,1,1);
  Lazer.DoCollision:= TRUE;
  Lazer.Scale:=0.2;
   }
end;

procedure TScreenSpace.Shutdown;
begin
  Engine.Destroy;
 // UnloadModel(ShipModel);

end;

procedure TScreenSpace.Update(MoveCount: Single);
var lDir: TVector3;
begin
  Engine.Update(MoveCount, Ship.Position);
  Engine.ClearDeadActor;
  Engine.Collision;
  // update the light shader with the camera view position
 // SetShaderValue(shader, shader.locs[SHADER_LOC_VECTOR_VIEW], @Camera.Camera.position.x, SHADER_UNIFORM_VEC3);
  //UpdateLightValues(shader, ToonLight);



  ApplyInputToShip(Ship, 1);
 // ApplyInputMouseToShip(Ship, 0.5);

  Camera.FollowActor(Ship, MoveCount);
  Engine.CrosshairFar.PositionCrosshairOnActor(Ship, 30);

  ///  //DrawSphere(Vector3Transform(vec, FModel.transform), 0.01,RED);
//  Lazer.Position :=Vector3Transform(Ship.VectorFromMesh(1,0), Ship.ActorModel.transform);
//  Transform := MatrixTranslate(Ship.Position.x, Ship.Position.y, Ship.Position.z);
 // Transform := MatrixMultiply(QuaternionToMatrix(Ship.Rotation), Transform);
  //LazerModel.transform := Transform;
  //  Lazer.ActorModel.transform := Transform;
 //L//azer.ActorModel := LazerModel;

 //  Lazer.RotationToVector(Ship.Position);
   // vec := Vector3Add(Vector3Scale(Ship.GetForward(), 0), Ship.Position);
  //DrawLine3D(Vector3Transform(Ship.VectorFromMesh(1,0),Ship.ActorModel.transform), vec,RED);
  //vec := Vector3Transform(Ship.VectorFromMesh(1,0),Ship.ActorModel.transform);

   //Rungs[RungIndex].LeftPoint[j] :=  Vector3Transform( TrailLPoint[j], FModel.transform);

 // vec := Vector3Transform( Ship.VectorFromMesh(1,0),Ship.ActorModel.transform);
  //vec := Vector3Add(Ship.Position, Ship.GetForward);
  if  IsKeyPressed(KEY_L) then Engine.OutlineShader := not Engine.OutlineShader;
  if  IsKeyPressed(KEY_K) then Engine.DrawRadar := not Engine.DrawRadar;
  if (IsKeyDown(KEY_F)) then
  begin
//  Shot := TShot.Create(Engine);

  end;

  lDir := Engine.LightDir;

  if (IsKeyDown(KEY_SIX)) then
      begin
        if (lDir.x < 120.6) then
            lDir.x += cameraSpeed * 5 * MoveCount
      end;

      if (IsKeyDown(KEY_SEVEN)) then
      begin
        if (lDir.x > -120.6) then
           lDir.x -= cameraSpeed * 5 * MoveCount;
      end;

      if (IsKeyDown(KEY_EIGHT)) then
      begin
        if (lDir.y < 120.6) then
            lDir.y += cameraSpeed * 5 * MoveCount;
      end;

      if (IsKeyDown(KEY_NINE)) then
      begin
        if (lDir.y > -120.6) then
            lDir.y -= cameraSpeed * 5 * MoveCount;
      end;

     Engine.LightPosition :=  Ship.Position;
     Engine.LightDir := Ship.GetForward(Vector3Distance(WarpIn.Position ,Ship.Position));
end;

procedure TScreenSpace.Render;
var vX,Vy: Single;
    VV, V1: TVector2;
begin
  inherited Render;
  BeginDrawing();
    ClearBackground( ColorCreate(32, 32, 64, 255) );
    {$IFDEF DEBUG}
    Engine.Render(Camera,True,True,Ship.Velocity,False);

    DrawFPS(10,10);
    {$ELSE}
    Engine.Render(Camera,False,False,Ship.Velocity,False);
    {$ENDIF}
    DrawFPS(10,10);
    VV := Vector2Subtract(Vector2Create(GetScreenWidth / 2, GetScreenHeight / 2), GetMousePosition);

    VV := Vector2Divide(VV,Vector2Create(GetScreenWidth / 2, GetScreenHeight / 2));

    DrawText(Pchar(FloatToStr(VV.x) + ' ' + FloatToStr(VV.y)), 10,40,10,RED);
    DrawText(Pchar(FloatToStr(Vector2Length(VV)   ))  , 10,60,10,RED);
  EndDrawing();
end;


function CloneModel(Model: PModel): TModel;
var outModel: PModel; meshIndex, matIndex: Integer;
begin
  outModel := new(PModel);
  outModel^.meshCount := Model^.meshCount;
  outModel^.meshes := MemAlloc(sizeof(TMesh) * outModel^.meshCount);

  outModel^.materialCount := Model^.materialCount;
  outModel^.materials := MemAlloc(sizeof(TMaterial) * outModel^.materialCount);

  outModel^.meshMaterial := MemAlloc(sizeof(Integer) * outModel^.meshCount);

  writeLn('MESHES COUNT ------------------------------------------------------');
  writeLn(outModel^.meshCount);
  writeLn(Model^.meshCount);
  writeLn('-------------------------------------------------------------------');

  for meshIndex := 0 to outModel^.meshCount -1 do
  begin
    outModel^.meshes[meshIndex] := model^.meshes[meshIndex];
    outModel^.meshMaterial[meshIndex] := model^.meshMaterial[meshIndex];
  end;

  for matIndex := 0 to outModel^.materialCount - 1 do
  begin
    outModel^.materials[matIndex] := model^.materials[matIndex];
  end;

  result := outModel^;

end;

procedure TScreenSpace.Show;
var Ship22: array [0..1] of TSpaceShip;
    TempMaterial: TMaterial;
    i: integer;
begin
  inherited Show;
//  HideCursor;
  Randomize;
  Ship.SetShipTexture(1, MATERIAL_MAP_DIFFUSE, FModelAtlas[GetRandomValue(0,23)]);


  Ship22[0] := TSpaceShip.Create(Engine);
  Ship22[0].ActorModel := LoadModel(GetAppDir('data' + '/models/ships/Striker.glb'));
  Ship22[0].Position := Vector3Create(8,8,-8);
  Ship22[0].DoCollision:= TRUE;
  Ship22[0].RadarColor := BLUE;
  Ship22[0].RadarStrinig:='Neutral';
  Ship22[0].Scale:=5.1;
  Ship22[0].Tag:=12;
  Ship22[0].SetShipTexture(1,MATERIAL_MAP_DIFFUSE, FModelAtlas[GetRandomValue(0,23)]);

  Ship.ActorModel := CloneModel(@Ship22[0].ActorModel);
  Ship.Scale:=3;

  TempMaterial := Ship22[0].ActorModel.materials^;
  Ship22[1] := TSpaceShip.Create(Engine);


  Ship22[1].ActorModel :=  CloneModel(@Ship22[0].ActorModel);
  //(Ship22[1].ActorModel.materials^);

//  for i:= 0 to Ship22[0].ActorModel.meshCount-1 do
//  Ship22[1].ActorModel.meshes[i] := Ship22[0].ActorModel.meshes[i];
  //LoadModelFromMesh( Ship22[0].ActorModel.meshes[1]);//  LoadModel(GetAppDir('data' + '/models/ships/Striker.glb'));




 { Ship22[1].ActorModel.materials^:=TempMaterial;


  for i:= 0 to Ship22[0].ActorModel.meshCount-1 do
  SetModelMeshMaterial(@Ship22[1].ActorModel  ,i, MATERIAL_MAP_DIFFUSE);
    }


  Ship22[1].Position := Vector3Create(8, 6,- 9);
  Ship22[1].DoCollision:= TRUE;
  Ship22[1].RadarColor := BLUE;

  Ship22[1].RadarStrinig:='Neutral';
  Ship22[1].Scale:=5.1;
  Ship22[1].Tag:=13;
//  Ship22[1].SetShipTexture(0,MATERIAL_MAP_DIFFUSE, FModelAtlas[GetRandomValue(0,23)]);

  //  Ship22[1].BrightTrailColor := BLUE;
  // Ship22[1].TrailColor := BLUE;
  //Ship22[0].SetShipTexture(0,MATERIAL_MAP_DIFFUSE, FModelAtlas[GetRandomValue(0,23)]);
end;

procedure TScreenSpace.Hide;
begin
  inherited Hide;
end;

end.

