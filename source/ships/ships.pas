unit Ships;

{$mode ObjFPC}{$H+}

interface
uses
  RayLib, RayMath, SpaceEngine, Global, Classes, SysUtils;

type // Enumerate ship type
  TSpaceShipType = (stNone, stChallenger, stForwarder, stStriker);

  { TSpaceShip }

  TSpaceShip = class(TSpaceShipActor)
  private
    FEnergy: Integer;
    FShipType: TSpaceShipType;
    procedure SetEnergy(AValue: Integer);
    procedure SetShipType(AValue: TSpaceShipType);
  public
    constructor Create(const AParent: TSpaceEngine); override;
    procedure OnCollision(const {%H-}Actor: TSpaceActor); override;
    procedure Update(const DeltaTime: Single); override;
    procedure Render(ShowDebugAxes: Boolean; ShowDebugRay: Boolean); override;
    procedure SetShipTexture(AMaterialNumber: Integer; ATexture: TTexture);
    property ShipType: TSpaceShipType read FShipType write SetShipType;
    property Energy: Integer read FEnergy write SetEnergy;
  end;


implementation

{ TSpaceShip }
procedure TSpaceShip.SetShipTexture(AMaterialNumber: Integer; ATexture: TTexture);
begin
  if AMaterialNumber <= ActorModel.materialCount - 1 then
  ActorModel.materials[1].maps[MATERIAL_MAP_DIFFUSE].texture := ATexture else
  TraceLog(LOG_ERROR,'SetShipTexture: materials value not exits');
end;

procedure TSpaceShip.SetEnergy(AValue: Integer);
begin
  if FEnergy=AValue then Exit;
  FEnergy:=AValue;
end;

procedure TSpaceShip.SetShipType(AValue: TSpaceShipType);
begin
  if FShipType=AValue then Exit;
  FShipType:=AValue;
  case AValue of
    stChallenger:
    begin
      SetTrailPointVector3(0,1,Vector3Create(3,4,5), Vector3Create(21,22,23));
      SetTrailPointVector3(1,1,Vector3Create(6,7,8), Vector3Create(15,16,17));
      SetTrailPointVector3(2,1,Vector3Create(27,28,29), Vector3Create(45,46,47));
      SetTrailPointVector3(3,1,Vector3Create(30,31,32), Vector3Create(39,40,41));
      SetTrailPointVector3(4,1,Vector3Create(54,55,56), Vector3Create(63,64,65));
      SetTrailPointVector3(5,1,Vector3Create(57,58,59), Vector3Create(69,70,71));
      SetTrailPointVector3(6,1,Vector3Create(78,79,80), Vector3Create(87,88,89));
      SetTrailPointVector3(7,1,Vector3Create(81,82,83), Vector3Create(93,94,95));
      Energy := 100;
    end;
    stForwarder:
    begin
      SetTrailPointVector3(0,1,Vector3Create(3,4,5), Vector3Create(18,19,20));
      SetTrailPointVector3(1,1,Vector3Create(9,10,11), Vector3Create(12,13,14));
      SetTrailPointVector3(2,1,Vector3Create(36,37,38), Vector3Create(45,46,47));
      SetTrailPointVector3(3,1,Vector3Create(39,40,41), Vector3Create(42,43,44));
      SetTrailPointVector3(4,1,Vector3Create(48,49,50), Vector3Create(69,70,71));
      SetTrailPointVector3(5,1,Vector3Create(54,55,56), Vector3Create(63,64,65));
      SetTrailPointVector3(6,1,Vector3Create(84,85,86), Vector3Create(90,91,92));
      SetTrailPointVector3(7,1,Vector3Create(87,88,89), Vector3Create(93,94,95));
      Energy := 100;
    end;
    stStriker:
    begin
      SetTrailPointVector3(0,1,Vector3Create(21,22,23), Vector3Create(15,16,17));
      SetTrailPointVector3(1,1,Vector3Create(18,19,20), Vector3Create(12,13,14));
      SetTrailPointVector3(2,1,Vector3Create(42,43,44), Vector3Create(36,37,38));
      SetTrailPointVector3(3,1,Vector3Create(45,46,47), Vector3Create(39,40,41));
      SetTrailPointVector3(4,1,Vector3Create(66,67,68), Vector3Create(51,52,53));
      SetTrailPointVector3(5,1,Vector3Create(57,58,59), Vector3Create(63,64,65));
      Energy := 100;
    end;


  end;
end;

constructor TSpaceShip.Create(const AParent: TSpaceEngine);
begin
  inherited Create(AParent);
  FShipType := stNone;
end;

procedure TSpaceShip.OnCollision(const Actor: TSpaceActor);
begin
  inherited OnCollision(Actor);
end;

procedure TSpaceShip.Update(const DeltaTime: Single);
begin
  inherited Update(DeltaTime);
end;

procedure TSpaceShip.Render(ShowDebugAxes: Boolean; ShowDebugRay: Boolean);
begin
  inherited Render(ShowDebugAxes, ShowDebugRay);
end;

end.

