unit ScreenLoading;

{$mode ObjFPC}{$H+}

interface

uses
  cmem, RayLib, RayMath, RayGui, Classes, SysUtils, ScreenManager, Global;

type

 { TScreenLoading }

 TScreenLoading = class(TGameScreen)
 private

 public
   procedure Init; override; // Init game screen
   procedure Shutdown; override; // Shutdown the game screen
   procedure Update(MoveCount: Single); override; // Update the game screen
   procedure Render; override;  // Render the game screen
   procedure Show; override;  // Celled when the screen is showned
   procedure Hide; override; // Celled when the screen is hidden
end;

 var
     DataProgress: Integer = 0;

     AtlasCounter: Integer = 0;
     EmissionCounter: Integer = 0;

     Position: TVector2;
     FrameRec: TRectangle;
     currentFrame, framesCounter, framesSpeed: Integer;


implementation
{ TScreenLoading }

procedure TScreenLoading.Init;
begin
 FLoadingTexture := LoadTexture(GetAppDir('data/textures/loading.png'));
 FrameRec := RectangleCreate(0.0,0.0, FLoadingTexture.width/3 , FLoadingTexture.height);
 framesSpeed := 8;
 position :=  Vector2Create(GetscreenWidth / 2.0 - (FLoadingTexture.width / 3) / 2,
                            GetScreenHeight / 2.0 - FLoadingTexture.height / 2.0);

end;

procedure TScreenLoading.Shutdown;
begin

end;

procedure TScreenLoading.Update(MoveCount: Single);
begin
  Inc(framesCounter);
  if (framesCounter >= ( GetFps / framesSpeed)) then
  begin
    framesCounter := 0;
    Inc(currentFrame);

    if (currentFrame > 2) then currentFrame := 0;
    frameRec.x := currentFrame*FLoadingTexture.width/3;
  end;

    if AtlasCounter <= 23 then // loading atlas texture
    begin
      DataProgress := AtlasCounter + EmissionCounter;
      FModelAtlas[AtlasCounter] := LoadTexture(GetAppDir('data/textures/atlas/'+IntTostr(AtlasCounter)+'.png'));
      if IsTextureReady(FModelAtlas[AtlasCounter]) then Inc(AtlasCounter);
    end;

    if EmissionCounter <= 4 then // loading emmision texture
    begin
      DataProgress := AtlasCounter + EmissionCounter;
      FModelEmission[EmissionCounter] := LoadTexture(GetAppDir('data/textures/atlas/emmision/'+IntTostr(EmissionCounter)+'.png'));
      if IsTextureReady(FModelAtlas[EmissionCounter]) then Inc(EmissionCounter);
    end;

    if (AtlasCounter > 23) and (EmissionCounter > 4) then
    begin
      self.Hide;
    end;


end;


procedure TScreenLoading.Render;
var ProgressRec: TRectangle; Progress: Single;
begin
  BeginDrawing();
    ClearBackground(BLACK);
    SetTextureFilter(FLogoTexture,TEXTURE_FILTER_BILINEAR);
    DrawTextureRec(FLoadingTexture, frameRec, position, WHITE);  // Draw part of the texture

    ProgressRec := RectangleCreate(Position.x, Position.y + 125, 176 ,6);
    Progress := DataProgress;
    GuiProgressBar(ProgressRec,nil,nil, @Progress, 0, 23+6);
    ProgressRec := RectangleCreate(Position.x, Position.y + 125 + 20 , 176 ,6);

    GuiSetStyle(LABELS, TEXT_ALIGNMENT, TEXT_ALIGN_CENTER);
    GuiLabel(ProgressRec, 'Loading ...');

    ///DrawText(PChar('LoadTexture: ' + IntTostr(LoadCounter) + ' of 24'),     {GetScreenWidth -}10  ,10  ,10  ,RAYWHITE);
  EndDrawing();
end;

procedure TScreenLoading.Show;
begin
  inherited Show;
end;

procedure TScreenLoading.Hide;
begin
  inherited Hide;
   self.ExitScreen(SCREEN_LOADING);
   self.ShowScreen(SCREEN_SPACE);
   self.State:=scHidden;
end;

end.

