unit ScreenSpace;

{$mode ObjFPC}{$H+}
{$define DEBUG}


interface

uses
  RayLib, RayMath, Classes, SysUtils, ScreenManager, SpaceEngine, Lights;

type

  { TScreenSpace }

  TScreenSpace = class(TGameScreen)
  private
    Engine: TSpaceEngine;
    Ship, Ship2, Ship3: TSpaceShipActor;

    ShipModel, ShipModel2: TModel;

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

  ShipModel := LoadModel(GetAppDir('data' + '/models/ships/bomber.glb'));
  ShipModel2 := LoadModel(GetAppDir('data' + '/models/ships/bomber.glb'));

  Ship := TSpaceShipActor.Create(Engine);
  Ship.ActorModel := ShipModel;
  Ship.DoCollision := True;
  Ship.RadarStrinig:='Player';

  LightShader_init(LIGHT_POINT,Vector3Create(100,0,0), WHITE);

  Ship.ActorModel.materials[0].shader := Shader;
  Ship.ActorModel.materials[1].shader := Shader;
  Ship.RadarColor := ColorCreate(0,128,0,120);
  //Ship.ShipType:=stCobraMk3;

  Ship2 := TSpaceShipActor.Create(Engine);
  Ship2.ActorModel := ShipModel2;
  Ship2.Position := Vector3Create(10,10,10);
  Ship2.DoCollision:= TRUE;
  Ship2.RadarColor := BLUE;
  Ship2.RadarStrinig:='Neutral';

  Ship3 := TSpaceShipActor.Create(Engine);
  Ship3.ActorModel := ShipModel2;
  Ship3.Position := Vector3Create(-14, 30 ,-10);
  Ship3.DoCollision:= TRUE;
  Ship3.RadarColor := RED;
  Ship3.RadarStrinig:='Pirate';


end;

procedure TScreenSpace.Shutdown;
begin
  Engine.Destroy;
  UnloadModel(ShipModel);

end;

procedure TScreenSpace.Update(MoveCount: Single);
begin
  Engine.Update(MoveCount, Ship.Position);
  Engine.ClearDeadActor;
  Engine.Collision;
  // update the light shader with the camera view position
  SetShaderValue(shader, shader.locs[SHADER_LOC_VECTOR_VIEW], @Camera.Camera.position.x, SHADER_UNIFORM_VEC3);
  UpdateLightValues(shader, ToonLight);
  ApplyInputToShip(Ship, 1);

  Camera.FollowActor(Ship, MoveCount);
  Engine.CrosshairFar.PositionCrosshairOnActor(Ship, 30);
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
end;

procedure TScreenSpace.Hide;
begin
  inherited Hide;
end;

end.

