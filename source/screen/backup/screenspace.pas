unit ScreenSpace;

{$mode ObjFPC}{$H+}
{$define DEBUG}


interface

uses
  RayLib, RayMath, Classes, SysUtils, ScreenManager, SpaceEngine;

type

  { TScreenSpace }

  TScreenSpace = class(TGameScreen)
  private
    Engine: TSpaceEngine;
    Ship, Ship2: TSpaceShipActor;
    ShipModel, ShipModel2: TModel;
    Camera: TSpaceCamera;
    procedure ApplyInputToShip(Ship_: TSpaceActor; step: Single);
  public
    procedure Init; override; // Init game screen
    procedure Shutdown; override; // Shutdown the game screen
    procedure Update(MoveCount: Single); override; // Update the game screen
    procedure Render; override;  // Render the game screen
    procedure Show; override;  // Celled when the screen is showned
    procedure Hide; override; // Celled when the screen is hidden
  end;

implementation

{ TScreenSpace }

procedure TScreenSpace.ApplyInputToShip(Ship_: TSpaceActor; step: Single);
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
  Engine.UsesSkyBox := True;
  Engine.GenerateSkyBox(1024, ColorCreate(32, 32, 64, 255), 2048);

  Camera := TSpaceCamera.Create(True, 50);

  ShipModel := LoadModel(GetAppDir('data' + '/models/ships/bomber_01.glb'));
  ShipModel2 := LoadModel(GetAppDir('data' + '/models/ships/bomber_01.glb'));

  Ship := TSpaceShipActor.Create(Engine);
  Ship.ActorModel := ShipModel;
  Ship.DoCollision := True;
  //Ship.Scale:=3;

  Ship2 := TSpaceShipActor.Create(Engine);
  Ship2.ActorModel := ShipModel2;
  Ship2.Position := Vector3Create(10,10,10);
  Ship2.DoCollision:= TRUE;
  {
  Ship.EngineLeftPoint[0] := Vector3Create( Ship.ActorModel.meshes[1].vertices[0],
                                            Ship.ActorModel.meshes[1].vertices[1],
                                            Ship.ActorModel.meshes[1].vertices[2]);


  Ship.EngineRightPoint[0] := Vector3Create( Ship.ActorModel.meshes[1].vertices[9],
                                             Ship.ActorModel.meshes[1].vertices[10],
                                             Ship.ActorModel.meshes[1].vertices[11]);

   }

  Ship.EngineLeftPoint[0] := Vector3Create( Ship.ActorModel.meshes[2].vertices[0],
                                            Ship.ActorModel.meshes[2].vertices[1],
                                            Ship.ActorModel.meshes[2].vertices[2]);


  Ship.EngineRightPoint[0] := Vector3Create( Ship.ActorModel.meshes[2].vertices[9],
                                             Ship.ActorModel.meshes[2].vertices[10],
                                             Ship.ActorModel.meshes[2].vertices[11]);


  Ship.EngineLeftPoint[1] := Vector3Create( Ship.ActorModel.meshes[2].vertices[9],
                                            Ship.ActorModel.meshes[2].vertices[10],
                                            Ship.ActorModel.meshes[2].vertices[11]);


  Ship.EngineRightPoint[1] := Vector3Create( Ship.ActorModel.meshes[2].vertices[12],
                                             Ship.ActorModel.meshes[2].vertices[13],
                                             Ship.ActorModel.meshes[2].vertices[14]);

  Ship.EngineLeftPoint[2] := Vector3Create( Ship.ActorModel.meshes[2].vertices[12],
                                            Ship.ActorModel.meshes[2].vertices[13],
                                            Ship.ActorModel.meshes[2].vertices[14]);


  Ship.EngineRightPoint[2] := Vector3Create( Ship.ActorModel.meshes[2].vertices[15],
                                             Ship.ActorModel.meshes[2].vertices[16],
                                             Ship.ActorModel.meshes[2].vertices[17]);

  Ship.EngineLeftPoint[3] := Vector3Create( Ship.ActorModel.meshes[2].vertices[15],
                                            Ship.ActorModel.meshes[2].vertices[16],
                                            Ship.ActorModel.meshes[2].vertices[17]);


  Ship.EngineRightPoint[3] := Vector3Create( Ship.ActorModel.meshes[2].vertices[18],
                                             Ship.ActorModel.meshes[2].vertices[19],
                                             Ship.ActorModel.meshes[2].vertices[20]);


  Ship.EngineLeftPoint[4] := Vector3Create( Ship.ActorModel.meshes[2].vertices[18],
                                            Ship.ActorModel.meshes[2].vertices[19],
                                            Ship.ActorModel.meshes[2].vertices[20]);


  Ship.EngineRightPoint[4] := Vector3Create( Ship.ActorModel.meshes[2].vertices[21],
                                             Ship.ActorModel.meshes[2].vertices[22],
                                             Ship.ActorModel.meshes[2].vertices[23]);


  Ship.EngineLeftPoint[5] := Vector3Create( Ship.ActorModel.meshes[2].vertices[21],
                                            Ship.ActorModel.meshes[2].vertices[22],
                                            Ship.ActorModel.meshes[2].vertices[23]);


  Ship.EngineRightPoint[5] := Vector3Create( Ship.ActorModel.meshes[2].vertices[24],
                                             Ship.ActorModel.meshes[2].vertices[25],
                                             Ship.ActorModel.meshes[2].vertices[26]);

  Ship.EngineLeftPoint[6] := Vector3Create( Ship.ActorModel.meshes[2].vertices[24],
                                            Ship.ActorModel.meshes[2].vertices[25],
                                            Ship.ActorModel.meshes[2].vertices[26]);


  Ship.EngineRightPoint[6] := Vector3Create( Ship.ActorModel.meshes[2].vertices[3],
                                             Ship.ActorModel.meshes[2].vertices[4],
                                             Ship.ActorModel.meshes[2].vertices[5]);


  Ship.EngineLeftPoint[7] := Vector3Create( Ship.ActorModel.meshes[2].vertices[3],
                                            Ship.ActorModel.meshes[2].vertices[4],
                                            Ship.ActorModel.meshes[2].vertices[5]);


  Ship.EngineRightPoint[7] := Vector3Create( Ship.ActorModel.meshes[2].vertices[0],
                                             Ship.ActorModel.meshes[2].vertices[1],
                                             Ship.ActorModel.meshes[2].vertices[2]);



  {
  Ship.EngineLeftPoint[0]  := Vector3Create(Ship.ActorModel.meshes[1].vertices[6],
                                            Ship.ActorModel.meshes[1].vertices[7],
                                            Ship.ActorModel.meshes[1].vertices[8]);

  Ship.EngineRightPoint[0] := Vector3Create(Ship.ActorModel.meshes[1].vertices[3],
                                            Ship.ActorModel.meshes[1].vertices[4],
                                            Ship.ActorModel.meshes[1].vertices[5]);



   }
  //Vector3Create( 0.10819 , -0.04508, -0.21762);

 // Ship.EngineLeftPoint[1]  := Vector3Create( -0.10860 , -0.04508, -0.21762);
 // Ship.EngineRightPoint[1] := Vector3Create( -0.25327 , -0.04508, -0.21762);
 {
     for i := 0  to Fmodel.meshes[1].vertexCount -1 do
    begin
    vec := Vector3Create(FModel.meshes[1].vertices[i * 3],   }
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

