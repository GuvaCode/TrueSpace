unit DigestMath;

{$mode ObjFPC}{$H+}

interface

uses
  Raylib, Raymath;

type
  PTriangle3D = ^Triangle3D;
  Triangle3D = record
    AVec: array[0..2] of TVector3;
  end;

  AxisAngle = record
    axis: TVector3;
    angle: single;
  end;

  EntityCollisionMesh = record
    triangleCount: integer;
    triangles: Triangle3D;
    normals: tVector3;
  end;


function SmoothDamp(from, to_: Single   ; speed, dt: Single): Single;
function SmoothDamp(from, to_: TVector3 ; speed, dt: Single): TVector3;
function SmoothDamp(from, to_: TQuaternion; speed, dt: Single): TQuaternion;

function GetPrettyBadRandomFloat(min, max: Single): Single;
function Projection(pos: TVector3; matView, matPerps: TMatrix): TVector4;


function SigNum(n: Single): Single;
function Atan2(y, x: Single): Single;
function Sgn(const x: Single): Single;
function Clamp(const x, min, max: Single): Single;

function AxisAngleIdentity(): AxisAngle;

function CheckTriangleCollision3D(const triangleA, triangleB: Triangle3D; normalA, normalB: TVector3): boolean;
procedure CopyTriangle3D({%H-}a: Triangle3D; const b: Triangle3D);
procedure createCollisionMesh(mesh: TMesh);


function QuaternionFromToRotation(const src, dest: TVector3): TQuaternion;
function QuaternionRotation(const Rotation:TVector3): TQuaternion;
function QuaternionConjugate(const Q: TQuaternion): TQuaternion;
function QuaternionNorm(const Q: TQuaternion): Single;
function QuaternionNormalize1(const Q: TQuaternion): TQuaternion;
function QuaternionInverse(const Q: TQuaternion): TQuaternion;
function QuaternionFromAxisAngle(const Axis:TVector3; const Angle:Single): TQuaternion;

function QuaternionLookRotation(lookAt, up: TVector3):TQuaternion;
Function QuaternionMatrix4x4(Const Quaternion: TQuaternion): TMatrix;
procedure QuaternionToBallPoints(Q:TQuaternion; var arcFrom, arcTo: TVector3);

function Matrix4x4_LookAt(Eye, LookAt, Roll: TVector3): TMatrix;



implementation
uses Math;
function SmoothDamp(from, to_: Single; speed, dt: Single): Single;
begin
  result:= Lerp(from, to_, 1 - exp(-speed * dt));
end;

function SmoothDamp(from, to_: TVector3; speed, dt: Single): TVector3;
begin
  result:= Vector3Create(Lerp(from.x, to_.x, 1 - exp(-speed * dt)),
                         Lerp(from.y, to_.y, 1 - exp(-speed * dt)),
		         Lerp(from.z, to_.z, 1 - exp(-speed * dt)));
end;

function SmoothDamp(from, to_: TQuaternion; speed, dt: Single): TQuaternion;
begin
  result:= QuaternionSlerp( from, to_, 1 - exp(-speed * dt));
end;

function GetPrettyBadRandomFloat(min, max: Single): Single;
var value: Single;
begin
  value := GetRandomValue(Round(min) * 1000, Round(max) * 1000);
  value /= 1000;
  result:= value;
end;

function Projection(pos: TVector3; matView, matPerps: TMatrix): TVector4;
var temp, result_: TVector4;
begin
  temp.x := matView.m0*pos.x + matView.m4*pos.y + matView.m8*pos.z + matView.m12;
  temp.y := matView.m1*pos.x + matView.m5*pos.y + matView.m9*pos.z + matView.m13;
  temp.z := matView.m2*pos.x + matView.m6*pos.y + matView.m10*pos.z + matView.m14;
  temp.w := matView.m3*pos.x + matView.m7*pos.y + matView.m11*pos.z + matView.m15;

  result_.x := matPerps.m0 * temp.x + matPerps.m4 * temp.y + matPerps.m8 * temp.z + matPerps.m12 * temp.w;
  result_.y := matPerps.m1 * temp.x + matPerps.m5 * temp.y + matPerps.m9 * temp.z + matPerps.m13 * temp.w;
  result_.z := matPerps.m2 * temp.x + matPerps.m6 * temp.y + matPerps.m10 * temp.z + matPerps.m14 * temp.w;
  result_.w := -temp.z;

  if result_.w <> 0.0 then
  begin
    result_.w := (1.0/result_.w)/0.75;
    // Perspective division
    result_.x *= result_.w;
    result_.y *= result_.w;
    result_.z *= result_.w;
    result := result_;
  end
  else
    result := result_;
end;

function SigNum(n: Single): Single;
begin
  if (n > 0.0) then result := 1.0
  else if (n < 0.0) then result := -1.0
  else result := 0.0;
end;

function Atan2(y, x: Single): Single;
begin
  if x > 0 then Result := arctan (y/x)
  else
  if x < 0 then Result := arctan (y/x) + pi
  else
  Result := pi/2 * sgn (y);
end;

function Sgn(const x: Single): Single;
begin
  if (X<0) then Result := -1
  else
  If (X>0) Then Result := 1
  else
  Result := 0
end;

function Clamp(const x, min, max: Single): Single;
begin
  if x < min then
    Result := min
  else
  if x > max then
    Result := max
  else
    Result := x;
end;

// Warning. Mostly chatgpt written.
procedure projectTriangleOntoAxis(const triangle: Triangle3D; const axis: TVector3; min,max: PSingle);
var dot1,dot2,dot3: single;
begin
  dot1 := Vector3DotProduct(triangle.AVec[0], axis);
  dot2 := Vector3DotProduct(triangle.AVec[1], axis);
  dot3 := Vector3DotProduct(triangle.AVec[2], axis);

  min^ := math.Min( math.Min(dot1, dot2), dot3);
  max^ := math.Max( math.Max(dot1, dot2), dot3);
end;

function trianglesIntersectOnAxis(const triangleA: Triangle3D; const triangleB: Triangle3D; axis: TVector3): boolean;
var
  minA, maxA: single;
  minB, maxB: single;
begin
  projectTriangleOntoAxis(triangleA, axis, @minA, @maxA);
  projectTriangleOntoAxis(triangleB, axis, @minB, @maxB);
  result := (minA <= maxB) and (maxA >= minB);
end;

function AxisAngleIdentity(): AxisAngle;
begin
  result.axis := Vector3Zero;
  result.angle:= 0.0;
end;

function checkTriangleCollision3D(const triangleA, triangleB: Triangle3D; normalA, normalB: TVector3): boolean;
var edgesA: array[0..2] of TVector3;
    edgesB: array[0..2] of TVector3;
    axis: TVector3; i: integer;
begin
  // Test triangle normals
  if (not trianglesIntersectOnAxis(triangleA, triangleB, normalA)) then result := false;
  if (not trianglesIntersectOnAxis(triangleA, triangleB, normalB)) then result := false;

  // Test cross products of triangle edges
  edgesA[0] := Vector3Subtract(triangleA.AVec[1], triangleA.AVec[0]);
  edgesA[1] := Vector3Subtract(triangleA.AVec[2], triangleA.AVec[1]);
  edgesA[2] := Vector3Subtract(triangleA.AVec[0], triangleA.AVec[2]);

  edgesB[0] := Vector3Subtract(triangleB.AVec[1], triangleB.AVec[0]);
  edgesB[1] := Vector3Subtract(triangleB.AVec[2], triangleB.AVec[1]);
  edgesB[2] := Vector3Subtract(triangleB.AVec[0], triangleB.AVec[2]);

  for i := 0 to 2 do
  begin
     axis := Vector3CrossProduct(normalA, edgesA[i]);
     if ( not trianglesIntersectOnAxis(triangleA, triangleB, axis)) then
     result := false;

     axis := Vector3CrossProduct(normalB, edgesB[i]);
     if (not trianglesIntersectOnAxis(triangleA, triangleB, axis)) then
     result := false;
  end;
  result := true;
end;

procedure copyTriangle3D(a: Triangle3D; const b: Triangle3D);
begin
  a.AVec[0] := b.AVec[0];
  a.AVec[1] := b.AVec[1];
  a.AVec[2] := b.AVec[2];
end;

procedure createCollisionMesh(mesh: TMesh);
begin

end;

function QuaternionFromToRotation(const src, dest: TVector3): TQuaternion;
var
  D,S,Invs:Single;
  axis, v0,v1,c:TVector3;
begin
  v0 := Src;
  v1 := dest;
  v0 := Vector3Normalize(v0);
  v1 := Vector3Normalize(v1);

  d := Vector3DotProduct(v0, v1);
  if (d >= 1.0) then
  begin
    Result.x := 0;
    Result.y := 0;
    Result.z := 0;
    Result.w := 0;
    Exit;
  end;

  if (d < (1e-6 - 1.0)) then
  begin
    // Generate an axis
    axis := Vector3CrossProduct(Vector3Create(1,0,0), Src);
    If (Vector3Length(axis) <=0) then // pick another if colinear
      axis := Vector3CrossProduct(Vector3Create(0,1,0), Src);
    Result := QuaternionFromAxisAngle(Vector3Normalize(Axis), PI);
  end else
  begin
    s := Sqrt( (1+d)*2 );
    invs := 1 / s;
    c := Vector3CrossProduct(v0, v1);
    Result.x := c.x * invs;
    Result.y := c.y * invs;
    Result.z := c.z * invs;
    Result.w := s * 0.5;
    Result := QuaternionNormalize(Result);
  end;
end;

function QuaternionRotation(const Rotation: TVector3): TQuaternion;
var
  cos_z_2, cos_y_2, cos_x_2:Single;
  sin_z_2, sin_y_2, sin_x_2:Single;
begin
   cos_z_2 := Cos(0.5 * Rotation.Z);
   cos_y_2 := Cos(0.5 * Rotation.y);
   cos_x_2 := Cos(0.5 * Rotation.x);

   sin_z_2 := Sin(0.5 * Rotation.z);
   sin_y_2 := Sin(0.5 * Rotation.y);
   sin_x_2 := Sin(0.5 * Rotation.x);

   // and now compute Quaternion
   Result.W := cos_z_2*cos_y_2*cos_x_2 + sin_z_2*sin_y_2*sin_x_2;
   Result.X := cos_z_2*cos_y_2*sin_x_2 - sin_z_2*sin_y_2*cos_x_2;
   Result.Y := cos_z_2*sin_y_2*cos_x_2 + sin_z_2*cos_y_2*sin_x_2;
   Result.Z := sin_z_2*cos_y_2*cos_x_2 - cos_z_2*sin_y_2*sin_x_2;

   Result:= QuaternionNormalize(Result);
end;

function QuaternionConjugate(const Q: TQuaternion): TQuaternion;
begin
  Result.X := -Q.X;
  Result.Y := -Q.Y;
  Result.Z := -Q.Z;
  Result.W :=  Q.W;
end;

function QuaternionNorm(const Q: TQuaternion): Single;
begin
  Result := Sqr(Q.W)+Sqr(Q.Z)+Sqr(Q.Y)+Sqr(Q.X);
end;

function QuaternionNormalize1(const Q: TQuaternion): TQuaternion;
var
  N:Single;
Begin
  N := QuaternionNorm(Q);
  If (N<>0) Then
  begin
    Result.X := Q.X/N;
    Result.Y := Q.Y/N;
    Result.Z := Q.Z/N;
    Result.W := Q.W/N;
  end;
end;

function QuaternionInverse(const Q: TQuaternion): TQuaternion;
var
  C:TQuaternion;
  N:Single;
begin
  C := QuaternionConjugate(Q);
  N := Sqr(QuaternionNorm(Q));
  if N<>0 Then
  begin
    Result.X := C.X/N;
    Result.Y := C.Y/N;
    Result.Z := C.Z/N;
    Result.W := C.W/N;
  end;
end;

function QuaternionFromAxisAngle(const Axis: TVector3; const Angle: Single): TQuaternion;
var
  S:Single;
begin
  S := Sin(Angle/2);
  Result.X := Axis.X * S;
  Result.Y := Axis.Y * S;
  Result.Z := Axis.Z * S;
  Result.W := Cos(angle/2);
end;



function QuaternionLookRotation(lookAt, up: TVector3): TQuaternion;
var
  m00,m01, m02, m10, m11, m12, m20, m21, m22:Single;
  right:TVector3;
  w4_recip:Single;
begin
  Vector3OrthoNormalize(@lookAt, @up);
  lookAt := Vector3Normalize(lookAt);
  right := Vector3CrossProduct(up, lookAt);

  m00 := right.x;
  m01 := up.x;
  m02 := lookAt.x;
  m10 := right.y;
  m11 := up.y;
  m12 := lookAt.y;
  m20 := right.z;
  m21 := up.z;
  m22 := lookAt.z;

  Result.w := Sqrt(1.0 + m00 + m11 + m22) * 0.5;
  w4_recip := 1.0 / (4.0 * Result.w);
  Result.x := (m21 - m12) * w4_recip;
  Result.y := (m02 - m20) * w4_recip;
  Result.z := (m10 - m01) * w4_recip;
end;

function QuaternionMatrix4x4(const Quaternion: TQuaternion): TMatrix;
Var
  Q:TQuaternion;
Begin
  Q := Quaternion;
  Q :=QuaternionNormalize(Q);

  Result.m0:= 1.0 - 2.0*Q.Y*Q.Y -2.0 *Q.Z*Q.Z;
  Result.m1:= 2.0 * Q.X*Q.Y + 2.0 * Q.W*Q.Z;
  Result.m2:= 2.0 * Q.X*Q.Z - 2.0 * Q.W*Q.Y;
  Result.m3 := 0;

  Result.m4:= 2.0 * Q.X*Q.Y - 2.0 * Q.W*Q.Z;
  Result.m5:= 1.0 - 2.0 * Q.X*Q.X - 2.0 * Q.Z*Q.Z;
  Result.m6:= 2.0 * Q.Y*Q.Z + 2.0 * Q.W*Q.X;
  Result.m7 := 0;

  Result.m8 := 2.0 * Q.X*Q.Z + 2.0 * Q.W*Q.Y;
  Result.m9 := 2.0 * Q.Y*Q.Z - 2.0 * Q.W*Q.X;
  Result.m10 := 1.0 - 2.0 * Q.X*Q.X - 2.0 * Q.Y*Q.Y;
  Result.m11 := 0;

  Result.m12 := 0.0;
  Result.m13 := 0.0;
  Result.m14 := 0.0;
  Result.m15 := 1.0;

end;

procedure QuaternionToBallPoints(Q: TQuaternion; var arcFrom, arcTo: TVector3);
var
  S:Single;
begin
  S := Sqrt(Sqr(Q.X) + Sqr(Q.Y));
  if s=0 then
    arcFrom := Vector3Create(0.0, 1.0, 0.0)
  else
    arcFrom := Vector3Create(-Q.Y/S, Q.X/S, 0.0);

  arcTo.X := (Q.W * arcFrom.X) - (Q.Z * arcFrom.Y);
  arcTo.Y := (Q.W * arcFrom.Y) + (Q.Z * arcFrom.X);
  arcTo.Z := (Q.X * arcFrom.Y) - (Q.Y * arcFrom.X);

  if Q.W < 0.0 then
    arcFrom := Vector3Create(-arcFrom.X, -arcFrom.Y, 0.0);
end;

function Matrix4x4_LookAt(Eye, LookAt, Roll: TVector3): TMatrix;
var
  xaxis, yaxis, zaxis: TVector3;
begin
  zaxis := Vector3Subtract(Eye, lookAt);
  zaxis := Vector3Normalize(zaxis);
  xaxis := Vector3CrossProduct(Roll, zaxis);
  xaxis := Vector3Normalize(xaxis);
  if (Vector3LengthSqr(xaxis)<=0) then
    Begin
      Roll := Vector3Create(-Roll.Z, -Roll.X, -Roll.Y);
      xaxis := Vector3CrossProduct(Roll, zaxis);
      xaxis:=Vector3Normalize(xaxis);
    End;

    yaxis := Vector3CrossProduct(zaxis, xaxis);

    Result.m0 := xaxis.x;
    Result.m1 := yaxis.x;
    Result.m2 := zaxis.x;
    Result.m3 := 0.0;
    Result.m4 := xaxis.y;
    Result.m5 := yaxis.y;
    Result.m6 := zaxis.y;
    Result.m7 := 0.0;
    Result.m8 := xaxis.z;
    Result.m9 := yaxis.z;
    Result.m10 := zaxis.z;
    Result.m11 := 0.0;
    Vector3Set(@xaxis,-xaxis.x,-xaxis.y,-xaxis.z);
    Result.m12 := Vector3DotProduct(xaxis,eye);
    Vector3Set(@yaxis,-yaxis.x,-yaxis.y,-yaxis.z);
    Result.m13 := Vector3DotProduct(yaxis,eye);
    Vector3Set(@yaxis,-zaxis.x,-zaxis.y,-zaxis.z);
    Result.m14 := Vector3DotProduct(zaxis,eye);
    Result.m15 := 1.0;
end;

end.

