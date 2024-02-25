// Free pascal like elite games

program true_space;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  CThreads,
  {$ENDIF}
  Classes, SysUtils, CustApp, RayLib,
  ScreenManager, ScreenSpace, ScreenLoading, SpaceEngine,
  Global, Ships, WarpGate;

type
  { TRayApplication }
  TRayApplication = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    FScreenManager: TScreenManager; // Менеджер экранов
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

  const AppTitle = 'raylib - basic window';


{ TRayApplication }

constructor TRayApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);

 InitWindow({GetScreenWidth, GetScreenHeight,} 800, 600, AppTitle); // for window settings, look at example - window flags
 SetWindowState(FLAG_MSAA_4X_HINT {or FLAG_FULLSCREEN_MODE} {or FLAG_VSYNC_HINT});
/// SetTargetFPS(60); // Set our game to run at 60 frames-per-second

 // Loading Textures model
// Global.LoadTextures;



  FScreenManager := TScreenManager.Create;
  FScreenManager.Add(TScreenLoading, SCREEN_LOADING);
  FScreenManager.Add(TScreenSpace, SCREEN_SPACE);
  FScreenManager.ShowScreen(SCREEN_LOADING); //Show Screen

end;

procedure TRayApplication.DoRun;
begin
  while (not WindowShouldClose) do // Detect window close button or ESC key
  begin
  // When data has finished loading, we set global variable

  // Update your variables here
  FScreenManager.Update(GetFrameTime); // Update screen manager
    // Draw
   // BeginDrawing();
    //  ClearBackground( ColorCreate(32, 32, 64, 255) );
  FScreenManager.Render; // Render screen manager
    //EndDrawing();

  end;

  // Stop program loop
  Terminate;
end;


destructor TRayApplication.Destroy;
begin
  FScreenManager.Free;
  UnloadTextures;
  // De-Initialization
  CloseWindow(); // Close window and OpenGL context

  // Show trace log messages (LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR...)
  TraceLog(LOG_INFO, 'your first window is close and destroy');

  inherited Destroy;
end;

var
  Application: TRayApplication;
begin
  Application:=TRayApplication.Create(nil);
  Application.Title:=AppTitle;
  Application.Run;
  Application.Free;
end.

