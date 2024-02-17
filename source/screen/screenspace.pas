unit ScreenSpace;

{$mode ObjFPC}{$H+}
{.$define DEBUG}


interface

uses
  RayLib, RayMath, Classes, SysUtils, ScreenManager, SpaceEngine, Ships;

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


    Camera: TSpaceCamera;
    procedure ApplyInputToShip({%H-}Actor: TSpaceActor; step: Single);
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

procedure TScreenSpace.Init;

begin
  Engine := TSpaceEngine.Create;
  Engine.CrosshairFar.Create(GetAppDir('data' + '/models/hud/crosshair2.gltf'));

 // Engine.SkyBoxQuality:=SBQOriginal;
  Engine.SetSkyBoxFileName('data/textures/skybox/cubemap.png');



  Engine.UsesSkyBox := True;

  Engine.DrawRadar := True;
  Camera := TSpaceCamera.Create(True, 50);


 // Test := LoadModel(GetAppDir('data' + '/models/ships/panda.glb'));

  Ship := TSpaceShip.Create(Engine);
//  Ship.FModel := Test;

  Ship.ActorModel := LoadModel(GetAppDir('data' + '/models/ships/Challenger.glb'));
  Ship.DoCollision := True;
  Ship.RadarStrinig:='Player';
  //Ship.ShipType := stBob;
 // LightShader_init(LIGHT_POINT,Vector3Create(1000,0,0), WHITE);




//  Ship.ActorModel.materials[0].shader := Shader;
//  Ship.ActorModel.materials[1].shader := Shader;
  Ship.RadarColor := ColorCreate(0,128,0,120);
  //Ship.Scale:=0.1;
  Ship.ShipType:= stChallenger;
  Ship.TrailColor := PINK;
 // Randomize;
 // Ship.ShipAtlas:=Random(23);


  Ship2 := TSpaceShipActor.Create(Engine);


  Ship2.ActorModel := LoadModel(GetAppDir('data' + '/models/ships/Challenger.glb'));
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
  Ship3.ActorModel := LoadModel(GetAppDir('data' + '/models/ships/Challenger.glb'));
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
  Ship3.Scale:=4.1;
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
var Shot: TShot; vec: TVector3; tr: TMatrix;
begin
  Engine.Update(MoveCount, Ship.Position);
  Engine.ClearDeadActor;
  Engine.Collision;
  // update the light shader with the camera view position
 // SetShaderValue(shader, shader.locs[SHADER_LOC_VECTOR_VIEW], @Camera.Camera.position.x, SHADER_UNIFORM_VEC3);
  //UpdateLightValues(shader, ToonLight);
  ApplyInputToShip(Ship, 1);

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

  if (IsKeyDown(KEY_F)) then
  begin
  Shot := TShot.Create(Engine);
//  Shot.ActorModel := Ship.ShotModel;

 {
  Shot.Lifetime := 1000;
  Shot.MaxSpeed:=10.1;
  Shot.Scale := 1.5;
  tr := MatrixMultiply(QuaternionToMatrix(Ship.Rotation), Shot.MatixTransform);
  Shot.Rotation := QuaternionFromMatrix(Ship.MatixTransform);
  Shot.Position := vec;
      }
  end;

end;

procedure TScreenSpace.Render;
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
  EndDrawing();
end;

procedure TScreenSpace.Show;
begin
  inherited Show;
  //Ship.ShipAtlas:=Random(23);
end;

procedure TScreenSpace.Hide;
begin
  inherited Hide;
end;

end.

