unit ScreenManager;

interface

uses
  Classes;

type
  TScreenIdent = Cardinal;
  TScreenManager = class;
  TGameScreen = class;
  TGameScreenClass = class of TGameScreen;
  TScreenState = (
    // The scene is in transition to active
    scTransitionOn,
    // The sence is active
    scActive,
    // The scene is in the transition to inactive
    scTransitionOff,
    // The scene is currently deactivated
    scHidden);

  TGameScreen = class
  private
    FManager: TScreenManager;
    FIdent: TScreenIdent;
    FState:  TScreenState;
    FName: String;
    FTransitionOffTime: Single;
    FTransitionOnTime: Single;
    FTransitionPosition: Single;
    FNextIdent: TScreenIdent;
    isExiting: Boolean;
    function GetActive: Boolean;
  protected
    // Initializes the game screen
    Procedure Init; virtual; abstract;
    // Shutdown the game screen
    procedure Shutdown; virtual; abstract;
    // Update the game screen
    procedure Update(MoveCount: Single); virtual; abstract;
    // Render the game screen
    Procedure Render; virtual;
    // Celled when the screen is showned
    Procedure Show; virtual;
    // Celled when the screen is hidden
    Procedure Hide; virtual;

  public
    constructor Create(Manager: TScreenManager; Ident: TScreenIdent; {%H-}Data: Pointer); virtual;
    // Exit the screen and return to the parent screen
    procedure ExitScreen; overload;
    // Exit the screen and show another screen after transition off
    procedure ExitScreen(const NextIdent: TScreenIdent); overload;
    // Show another screen, this doesnt close this screen
    procedure ShowScreen(const Ident: TScreenIdent);
    // The owning scene manager
    Property Manager: TScreenManager read FManager;
    // Name of the scene
    Property Name: String read FName write FName;
    // Unique identifyer of the screen
    Property Ident: TScreenIdent read FIdent;
    // The state of the scene
    property State: TScreenState read FState write FState;
    // Hw long the screen takes to transition on when it is activated.
    property TransitionOnTime: Single read FTransitionOnTime write FTransitionOnTime;
    // How long the screen takes to transition off when it is deactivated.
    property TransitionOffTime: Single read FTransitionOffTime write FTransitionOffTime;
    // The current position of the screen transition, ranging from 0.0(Hidden) to 1.0 (Visible)
    property TransitionPosition: Single read FTransitionPosition write FTransitionPosition;
    property IsActive: Boolean read GetActive;
  published
  end;

  // ------------------------------------------------------------------------------
  TScreenManager = class
  private
    // List of all known scenes in the
    FScreens: TList;
    // List of the current active scenes,
    // The top most scene recieves the update event, and all scenes the render
    FStack: TList;
    FUpdateCount: Integer;
    function GetActive: TGameScreen;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    // Add a new screen
    procedure Add(ScreenClass: TGameScreenClass; Ident: TScreenIdent); overload;
    // Add a new screen with a user data that will be passed to the screen constructor
    procedure Add(ScreenClass: TGameScreenClass; Ident: TScreenIdent; Data: Pointer); overload;
    procedure Add(Screen: TGameScreen; {%H-}Ident: TScreenIdent); overload;
    // Update the active screen
    procedure Update(const FrameTime: Single);
    // Render the visible screens
    Procedure Render;
    procedure ShowScreen(const Ident: TScreenIdent);
    // Detemines if a screen is visible (its render function is called each frame)
    function IsVisible(const Ident: TScreenIdent): Boolean;
    // Determines if a screen is active (its update function is called each frame)
    function IsActive(const Ident: TScreenIdent): Boolean;
    // Find a screen by the screen ident
    function Find(const Ident: TScreenIdent; out Screen: TGameScreen): Boolean;
    // Returns the active screen, or nil if no screen is active
    property Active: TGameScreen read GetActive;
  end;

implementation

constructor TGameScreen.Create(Manager: TScreenManager; Ident: TScreenIdent; Data: Pointer);
begin
  FManager := Manager;
  FIdent := Ident;
  FNextIdent := $0000;
  FTransitionOffTime := 1.0;
  FTransitionOnTime := 1.0;
  FTransitionPosition := 0.0;
end;

// ------------------------------------------------------------------------------
procedure TGameScreen.ExitScreen(const NextIdent: TScreenIdent);
begin
  if (TransitionOffTime <= 0.0) then
  begin
    Manager.FStack.Remove(Self);
    Hide;
    Manager.ShowScreen(NextIdent);
  end
  else
  begin
    FState := scTransitionOff;
    FNextIdent := NextIdent;
    isExiting := True;
  end;
end;

function TGameScreen.GetActive: Boolean;
begin
  Result := Manager.IsActive(Ident) and ((State = scTransitionOn) or (State = scActive));
end;

procedure TGameScreen.ExitScreen;
begin
  if (TransitionOffTime <= 0.0) then
  begin
    Manager.FStack.Remove(Self);
  end
  else
  begin
    FState := scTransitionOff;
    isExiting := True;
  end;
end;

procedure TGameScreen.Show;
begin

end;

procedure TGameScreen.Hide;
begin

end;

procedure TGameScreen.Render;
begin

end;

procedure TGameScreen.ShowScreen(const Ident: TScreenIdent);
begin
  Manager.ShowScreen(Ident);
end;

// TScreenManager
constructor TScreenManager.Create;
begin
  FScreens := TList.Create;
  FStack := TList.Create;
end;

destructor TScreenManager.Destroy;
begin
  Clear;
  FScreens.Free;
  FStack.Free;
  inherited;
end;

procedure TScreenManager.Clear;
var
  Index: Integer;
var
  Screen: TGameScreen;
begin
  for Index := 0 to FScreens.Count - 1 do
  begin
    Screen := TGameScreen(FScreens.List^[Index]);
    Screen.Shutdown;
    Screen.Free;
  end;
  FStack.Clear;
  FScreens.Clear;
end;

procedure TScreenManager.Add(ScreenClass: TGameScreenClass; Ident: TScreenIdent);
begin
  Add(ScreenClass, Ident, nil);
end;

procedure TScreenManager.Add(ScreenClass: TGameScreenClass; Ident: TScreenIdent; Data: Pointer);
var
  Screen: TGameScreen;
begin
  Screen := ScreenClass.Create(Self, Ident, Data);
  Screen.Init;
  FScreens.Add(Screen);
end;

procedure TScreenManager.Add(Screen: TGameScreen; Ident: TScreenIdent);
begin
  Screen.Init;
  FScreens.Add(Screen)
end;

procedure TScreenManager.Update(const FrameTime: Single);
var
  Screen: TGameScreen;
begin
  // No active screen, do nothing
  if (FStack.Count <= 0) { or (FUpdateCount < 10) } then Exit;
  Screen := TGameScreen(FStack.List^[FStack.Count - 1]);
  case Screen.State of
    scTransitionOn:
      begin
        Screen.TransitionPosition := Screen.TransitionPosition + FrameTime / Screen.TransitionOnTime;
        if Screen.TransitionPosition >= 1 then
        begin
          Screen.TransitionPosition := 1.0;
          Screen.State := scActive;
        end;
      end;
    scActive:
      begin
        Screen.TransitionPosition := 1.0;
      end;
    scTransitionOff:
      begin
        Screen.TransitionPosition := Screen.TransitionPosition - FrameTime / Screen.TransitionOnTime;
        if Screen.TransitionPosition <= 0 then
        begin
          FStack.Remove(Screen);
          Screen.Hide;
          Screen.TransitionPosition := 0.0;
          Screen.State := scHidden;
          if Screen.FNextIdent <> $0000 then
          begin
            ShowScreen(Screen.FNextIdent);
            Screen.FNextIdent := $0000;
          end;
        end;
      end;
    scHidden:
      begin ;
        Screen.TransitionPosition := 0.0;
      end;
  end;
  Screen.Update(FrameTime);
end;

procedure TScreenManager.Render;
var
  Index: Integer;
var
  Screen: TGameScreen;
begin
  for Index := 0 to FStack.Count - 1 do
  begin
    Screen := TGameScreen(FStack.List^[Index]);
    if (Screen.State = scHidden) then
      Continue;
    Screen.Render;
  end;
end;

function TScreenManager.Find(const Ident: TScreenIdent; out Screen: TGameScreen): Boolean;
var
  Index: Integer;
begin
  for Index := 0 to FScreens.Count - 1 do
  begin
    Screen := TGameScreen(FScreens.List^[Index]);
    if Screen.Ident = Ident then
    begin
      Result := True;
      Exit;
    end;
  end;
  Screen := nil;
  Result := False;
end;

procedure TScreenManager.ShowScreen(const Ident: TScreenIdent);
var
  Screen: TGameScreen;
begin
  if Find(Ident, Screen) then
  begin
    Screen.State := scTransitionOn;
    Screen.Show;
    FStack.Add(Screen);
  end
  else
  begin
    writeln('Unknown screen');
    // raise Exception.CreateFmt('Unknown screen ident: %d', [Ident]);
  end;
  FUpdateCount := 0;
end;

function TScreenManager.IsVisible(const Ident: TScreenIdent): Boolean;
var
  Index: Integer;
var
  Screen: TGameScreen;
begin
  for Index := 0 to FStack.Count - 1 do
  begin
    Screen := TGameScreen(FStack.List^[Index]);
    if Screen.Ident = Ident then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

function TScreenManager.IsActive(const Ident: TScreenIdent): Boolean;
var
  Screen: TGameScreen;
begin
  if FStack.Count > 0 then
  begin
    Screen := TGameScreen(FStack.List^[FStack.Count - 1]);
    Result := Screen.Ident = Ident;
  end
  else
  begin
    Result := False;
  end;
end;

function TScreenManager.GetActive: TGameScreen;
begin
  if FStack.Count > 0 then
  begin
    Result := TGameScreen(FStack.List^[FStack.Count - 1]);
  end
  else
  begin
    Result := nil;
  end;
end;

end.
