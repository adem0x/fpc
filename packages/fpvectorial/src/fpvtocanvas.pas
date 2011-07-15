unit fpvtocanvas;

{$mode objfpc}{$H+}

interface

{.$define USE_LCL_CANVAS}

uses
  Classes, SysUtils, Math,
  {$ifdef USE_LCL_CANVAS}
  Graphics, LCLIntf,
  {$endif}
  fpcanvas,
  fpimage,
  fpvectorial;

procedure DrawFPVectorialToCanvas(ASource: TvVectorialDocument;
  ADest: TFPCustomCanvas;
  ADestX: Integer = 0; ADestY: Integer = 0; AMulX: Double = 1.0; AMulY: Double = 1.0);
procedure DrawFPVPathToCanvas(ASource: TvVectorialDocument; CurPath: TPath;
  ADest: TFPCustomCanvas;
  ADestX: Integer = 0; ADestY: Integer = 0; AMulX: Double = 1.0; AMulY: Double = 1.0);
procedure DrawFPVEntityToCanvas(ASource: TvVectorialDocument; CurEntity: TvEntity;
  ADest: TFPCustomCanvas;
  ADestX: Integer = 0; ADestY: Integer = 0; AMulX: Double = 1.0; AMulY: Double = 1.0);
procedure DrawFPVTextToCanvas(ASource: TvVectorialDocument; CurText: TvText;
  ADest: TFPCustomCanvas;
  ADestX: Integer = 0; ADestY: Integer = 0; AMulX: Double = 1.0; AMulY: Double = 1.0);

implementation

{$ifndef Windows}
{.$define FPVECTORIAL_TOCANVAS_DEBUG}
{$endif}

function Rotate2DPoint(P,Fix :TPoint; alpha:double): TPoint;
var
  sinus, cosinus : Extended;
begin
  SinCos(alpha, sinus, cosinus);
  P.x := P.x - Fix.x;
  P.y := P.y - Fix.y;
  result.x := Round(p.x*cosinus + p.y*sinus)  +  fix.x ;
  result.y := Round(-p.x*sinus + p.y*cosinus) +  Fix.y;
end;

procedure DrawRotatedEllipse(
  ADest: TFPCustomCanvas;
  CurEllipse: TvEllipse;
  ADestX: Integer = 0; ADestY: Integer = 0; AMulX: Double = 1.0; AMulY: Double = 1.0);
var
  PointList: array[0..6] of TPoint;
  f: TPoint;
  dk, x1, x2, y1, y2: Integer;
  {$ifdef USE_LCL_CANVAS}
  ALCLDest: TCanvas absolute ADest;
  {$endif}
begin
  {$ifdef USE_LCL_CANVAS}
  CurEllipse.CalculateBoundingRectangle();
  x1 := CurEllipse.BoundingRect.Left;
  x2 := CurEllipse.BoundingRect.Right;
  y1 := CurEllipse.BoundingRect.Top;
  y2 := CurEllipse.BoundingRect.Bottom;

  dk := Round(0.654 * Abs(y2-y1));
  f.x := Round(CurEllipse.CenterX);
  f.y := Round(CurEllipse.CenterY - 1);
  PointList[0] := Rotate2DPoint(Point(x1, f.y), f, CurEllipse.Angle) ;  // Startpoint
  PointList[1] := Rotate2DPoint(Point(x1,  f.y - dk), f, CurEllipse.Angle);
  //Controlpoint of Startpoint first part
  PointList[2] := Rotate2DPoint(Point(x2- 1,  f.y - dk), f, CurEllipse.Angle);
  //Controlpoint of secondpoint first part
  PointList[3] := Rotate2DPoint(Point(x2 -1 , f.y), f, CurEllipse.Angle);
  // Firstpoint of secondpart
  PointList[4] := Rotate2DPoint(Point(x2-1 , f.y + dk), f, CurEllipse.Angle);
  // Controllpoint of secondpart firstpoint
  PointList[5] := Rotate2DPoint(Point(x1, f.y +  dk), f, CurEllipse.Angle);
  // Conrollpoint of secondpart endpoint
  PointList[6] := PointList[0];   // Endpoint of
   // Back to the startpoint
  ALCLDest.PolyBezier(Pointlist[0]);
  {$endif}
end;

{@@
  This function draws a FPVectorial vectorial image to a TFPCustomCanvas
  descendent, such as TCanvas from the LCL.

  Be careful that by default this routine does not execute coordinate transformations,
  and that FPVectorial works with a start point in the bottom-left corner, with
  the X growing to the right and the Y growing to the top. This will result in
  an image in TFPCustomCanvas mirrored in the Y axis in relation with the document
  as seen in a PDF viewer, for example. This can be easily changed with the
  provided parameters. To have the standard view of an image viewer one could
  use this function like this:

  DrawFPVectorialToCanvas(ASource, ADest, 0, ASource.Height, 1.0, -1.0);
}
{.$define FPVECTORIAL_TOCANVAS_DEBUG}
procedure DrawFPVectorialToCanvas(ASource: TvVectorialDocument;
  ADest: TFPCustomCanvas;
  ADestX: Integer = 0; ADestY: Integer = 0; AMulX: Double = 1.0; AMulY: Double = 1.0);
var
  i: Integer;
  CurEntity: TvEntity;
begin
  {$ifdef FPVECTORIAL_TOCANVAS_DEBUG}
  WriteLn(':>DrawFPVectorialToCanvas');
  {$endif}

  for i := 0 to ASource.GetEntitiesCount - 1 do
  begin
    {$ifdef FPVECTORIAL_TOCANVAS_DEBUG}
    Write(Format('[Path] ID=%d', [i]));
    {$endif}

    CurEntity := ASource.GetEntity(i);

    if CurEntity is TPath then DrawFPVPathToCanvas(ASource, TPath(CurEntity), ADest, ADestX, ADestY, AMulX, AMulY)
    else if CurEntity is TvText then DrawFPVTextToCanvas(ASource, TvText(CurEntity), ADest, ADestX, ADestY, AMulX, AMulY)
    else DrawFPVEntityToCanvas(ASource, CurEntity, ADest, ADestX, ADestY, AMulX, AMulY);
  end;

  {$ifdef FPVECTORIAL_TOCANVAS_DEBUG}
  WriteLn(':<DrawFPVectorialToCanvas');
  {$endif}
end;

procedure DrawFPVPathToCanvas(ASource: TvVectorialDocument; CurPath: TPath;
  ADest: TFPCustomCanvas;
  ADestX: Integer = 0; ADestY: Integer = 0; AMulX: Double = 1.0; AMulY: Double = 1.0);

  function CoordToCanvasX(ACoord: Double): Integer;
  begin
    Result := Round(ADestX + AmulX * ACoord);
  end;

  function CoordToCanvasY(ACoord: Double): Integer;
  begin
    Result := Round(ADestY + AmulY * ACoord);
  end;

var
  j, k: Integer;
  PosX, PosY: Double; // Not modified by ADestX, etc
  CoordX, CoordY: Integer;
  CurSegment: TPathSegment;
  Cur2DSegment: T2DSegment absolute CurSegment;
  Cur2DBSegment: T2DBezierSegment absolute CurSegment;
  // For bezier
  CurX, CurY: Integer; // Not modified by ADestX, etc
  CurveLength: Integer;
  t: Double;
  // For polygons
  Points: array of TPoint;
begin
  PosX := 0;
  PosY := 0;
  ADest.Brush.Style := bsClear;

  ADest.MoveTo(ADestX, ADestY);

  CurPath.PrepareForSequentialReading;

  // Set the path Pen and Brush options
  ADest.Pen.Style := CurPath.Pen.Style;
  ADest.Pen.Width := CurPath.Pen.Width;
  ADest.Pen.FPColor := CurPath.Pen.Color;
  ADest.Brush.FPColor := CurPath.Brush.Color;

  //
  // For solid paths, draw a polygon instead
  //
  if CurPath.Brush.Style = bsSolid then
  begin
    ADest.Brush.Style := CurPath.Brush.Style;

    SetLength(Points, CurPath.Len);

    for j := 0 to CurPath.Len - 1 do
    begin
      //WriteLn('j = ', j);
      CurSegment := TPathSegment(CurPath.Next());

      CoordX := CoordToCanvasX(Cur2DSegment.X);
      CoordY := CoordToCanvasY(Cur2DSegment.Y);

      Points[j].X := CoordX;
      Points[j].Y := CoordY;
    end;

    ADest.Polygon(Points);

    Exit;
  end;

  //
  // For other paths, draw more carefully
  //
  for j := 0 to CurPath.Len - 1 do
  begin
    //WriteLn('j = ', j);
    CurSegment := TPathSegment(CurPath.Next());

    case CurSegment.SegmentType of
    stMoveTo:
    begin
      CoordX := CoordToCanvasX(Cur2DSegment.X);
      CoordY := CoordToCanvasY(Cur2DSegment.Y);
      ADest.MoveTo(CoordX, CoordY);
      PosX := Cur2DSegment.X;
      PosY := Cur2DSegment.Y;
      {$ifdef FPVECTORIAL_TOCANVAS_DEBUG}
      Write(Format(' M%d,%d', [CoordY, CoordY]));
      {$endif}
    end;
    // This element can override temporarely the Pen
    st2DLineWithPen:
    begin
      ADest.Pen.FPColor := T2DSegmentWithPen(Cur2DSegment).Pen.Color;

      CoordX := CoordToCanvasX(Cur2DSegment.X);
      CoordY := CoordToCanvasY(Cur2DSegment.Y);
      ADest.LineTo(CoordX, CoordY);
      PosX := Cur2DSegment.X;
      PosY := Cur2DSegment.Y;

      ADest.Pen.FPColor := CurPath.Pen.Color;

      {$ifdef FPVECTORIAL_TOCANVAS_DEBUG}
      Write(Format(' L%d,%d', [CoordToCanvasX(Cur2DSegment.X), CoordToCanvasY(Cur2DSegment.Y)]));
      {$endif}
    end;
    st2DLine, st3DLine:
    begin
      CoordX := CoordToCanvasX(Cur2DSegment.X);
      CoordY := CoordToCanvasY(Cur2DSegment.Y);
      ADest.LineTo(CoordX, CoordY);
      PosX := Cur2DSegment.X;
      PosY := Cur2DSegment.Y;
      {$ifdef FPVECTORIAL_TOCANVAS_DEBUG}
      Write(Format(' L%d,%d', [CoordX, CoordY]));
      {$endif}
    end;
    { To draw a bezier we need to divide the interval in parts and make
      lines between this parts }
    st2DBezier, st3DBezier:
    begin
      CurveLength :=
        Round(sqrt(sqr(Cur2DBSegment.X2 - PosX) + sqr(Cur2DBSegment.Y2 - PosY))) +
        Round(sqrt(sqr(Cur2DBSegment.X3 - Cur2DBSegment.X2) + sqr(Cur2DBSegment.Y3 - Cur2DBSegment.Y2))) +
        Round(sqrt(sqr(Cur2DBSegment.X - Cur2DBSegment.X3) + sqr(Cur2DBSegment.Y - Cur2DBSegment.Y3)));

      for k := 1 to CurveLength do
      begin
        t := k / CurveLength;
        CurX := Round(sqr(1 - t) * (1 - t) * PosX + 3 * t * sqr(1 - t) * Cur2DBSegment.X2 + 3 * t * t * (1 - t) * Cur2DBSegment.X3 + t * t * t * Cur2DBSegment.X);
        CurY := Round(sqr(1 - t) * (1 - t) * PosY + 3 * t * sqr(1 - t) * Cur2DBSegment.Y2 + 3 * t * t * (1 - t) * Cur2DBSegment.Y3 + t * t * t * Cur2DBSegment.Y);
        CoordX := CoordToCanvasX(CurX);
        CoordY := CoordToCanvasY(CurY);
        ADest.LineTo(CoordX, CoordY);
//        {$ifdef FPVECTORIAL_TOCANVAS_DEBUG}
//        Write(Format(' CL%d,%d', [CoordX, CoordY]));
//        {$endif}
      end;
      PosX := Cur2DSegment.X;
      PosY := Cur2DSegment.Y;

      {$ifdef FPVECTORIAL_TOCANVAS_DEBUG}
      Write(Format(' ***C%d,%d %d,%d %d,%d %d,%d',
        [CoordToCanvasX(PosX), CoordToCanvasY(PosY),
         CoordToCanvasX(Cur2DBSegment.X2), CoordToCanvasY(Cur2DBSegment.Y2),
         CoordToCanvasX(Cur2DBSegment.X3), CoordToCanvasY(Cur2DBSegment.Y3),
         CoordToCanvasX(Cur2DBSegment.X), CoordToCanvasY(Cur2DBSegment.Y)]));
      {$endif}
    end;
    end;
  end;
  {$ifdef FPVECTORIAL_TOCANVAS_DEBUG}
  WriteLn('');
  {$endif}
end;

procedure DrawFPVEntityToCanvas(ASource: TvVectorialDocument; CurEntity: TvEntity;
  ADest: TFPCustomCanvas;
  ADestX: Integer = 0; ADestY: Integer = 0; AMulX: Double = 1.0; AMulY: Double = 1.0);

  function CoordToCanvasX(ACoord: Double): Integer;
  begin
    Result := Round(ADestX + AmulX * ACoord);
  end;

  function CoordToCanvasY(ACoord: Double): Integer;
  begin
    Result := Round(ADestY + AmulY * ACoord);
  end;

var
  i: Integer;
  {$ifdef USE_LCL_CANVAS}
  ALCLDest: TCanvas;
  {$endif}
  // For entities
  CurCircle: TvCircle;
  CurEllipse: TvEllipse;
  //
  CurArc: TvCircularArc;
  FinalStartAngle, FinalEndAngle: double;
  BoundsLeft, BoundsTop, BoundsRight, BoundsBottom,
   IntStartAngle, IntAngleLength, IntTmp: Integer;
  //
  CurDim: TvAlignedDimension;
  Points: array of TPoint;
  UpperDim, LowerDim: T3DPoint;
begin
  {$ifdef USE_LCL_CANVAS}
  ALCLDest := TCanvas(ADest);
  {$endif}

  ADest.Brush.Style := CurEntity.Brush.Style;
  ADest.Pen.Style := CurEntity.Pen.Style;
  ADest.Pen.FPColor := CurEntity.Pen.Color;
  ADest.Brush.FPColor := CurEntity.Brush.Color;

  if CurEntity is TvCircle then
  begin
    CurCircle := CurEntity as TvCircle;
    ADest.Ellipse(
      CoordToCanvasX(CurCircle.CenterX - CurCircle.Radius),
      CoordToCanvasY(CurCircle.CenterY - CurCircle.Radius),
      CoordToCanvasX(CurCircle.CenterX + CurCircle.Radius),
      CoordToCanvasY(CurCircle.CenterY + CurCircle.Radius)
      );
  end
  else if CurEntity is TvEllipse then
  begin
    CurEllipse := CurEntity as TvEllipse;
    DrawRotatedEllipse(ADest, CurEllipse);
  end
  else if CurEntity is TvCircularArc then
  begin
    CurArc := CurEntity as TvCircularArc;
    {$ifdef USE_LCL_CANVAS}
    // ToDo: Consider a X axis inversion
    // If the Y axis is inverted, then we need to mirror our angles as well
    BoundsLeft := CoordToCanvasX(CurArc.CenterX - CurArc.Radius);
    BoundsTop := CoordToCanvasY(CurArc.CenterY - CurArc.Radius);
    BoundsRight := CoordToCanvasX(CurArc.CenterX + CurArc.Radius);
    BoundsBottom := CoordToCanvasY(CurArc.CenterY + CurArc.Radius);
    {if AMulY > 0 then
    begin}
      FinalStartAngle := CurArc.StartAngle;
      FinalEndAngle := CurArc.EndAngle;
    {end
    else // AMulY is negative
    begin
      // Inverting the angles generates the correct result for Y axis inversion
      if CurArc.EndAngle = 0 then FinalStartAngle := 0
      else FinalStartAngle := 360 - 1* CurArc.EndAngle;
      if CurArc.StartAngle = 0 then FinalEndAngle := 0
      else FinalEndAngle := 360 - 1* CurArc.StartAngle;
    end;}
    IntStartAngle := Round(16*FinalStartAngle);
    IntAngleLength := Round(16*(FinalEndAngle - FinalStartAngle));
    // On Gtk2 and Carbon, the Left really needs to be to the Left of the Right position
    // The same for the Top and Bottom
    // On Windows it works fine either way
    // On Gtk2 if the positions are inverted then the arcs are screwed up
    // In Carbon if the positions are inverted, then the arc is inverted
    if BoundsLeft > BoundsRight then
    begin
      IntTmp := BoundsLeft;
      BoundsLeft := BoundsRight;
      BoundsRight := IntTmp;
    end;
    if BoundsTop > BoundsBottom then
    begin
      IntTmp := BoundsTop;
      BoundsTop := BoundsBottom;
      BoundsBottom := IntTmp;
    end;
    // Arc(ALeft, ATop, ARight, ABottom, Angle16Deg, Angle16DegLength: Integer);
    {$ifdef FPVECTORIALDEBUG}
    WriteLn(Format('Drawing Arc Center=%f,%f Radius=%f StartAngle=%f AngleLength=%f',
      [CurArc.CenterX, CurArc.CenterY, CurArc.Radius, IntStartAngle/16, IntAngleLength/16]));
    {$endif}
    ADest.Pen.FPColor := CurArc.Pen.Color;
    ALCLDest.Arc(
      BoundsLeft, BoundsTop, BoundsRight, BoundsBottom,
      IntStartAngle, IntAngleLength
      );
    ADest.Pen.FPColor := colBlack;
    // Debug info
//      {$define FPVECTORIALDEBUG}
//      {$ifdef FPVECTORIALDEBUG}
//      WriteLn(Format('Drawing Arc x1y1=%d,%d x2y2=%d,%d start=%d end=%d',
//        [BoundsLeft, BoundsTop, BoundsRight, BoundsBottom, IntStartAngle, IntAngleLength]));
//      {$endif}
{      ADest.TextOut(CoordToCanvasX(CurArc.CenterX), CoordToCanvasY(CurArc.CenterY),
      Format('R=%d S=%d L=%d', [Round(CurArc.Radius*AMulX), Round(FinalStartAngle),
      Abs(Round((FinalEndAngle - FinalStartAngle)))]));
    ADest.Pen.Color := TColor($DDDDDD);
    ADest.Rectangle(
      BoundsLeft, BoundsTop, BoundsRight, BoundsBottom);
    ADest.Pen.Color := clBlack;}
    {$endif}
  end
  else if CurEntity is TvAlignedDimension then
  begin
    CurDim := CurEntity as TvAlignedDimension;
    //
    // Draws this shape:
    // vertical     horizontal
    // ___
    // | |     or   ---| X cm
    //   |           --|
    // Which marks the dimension
    ADest.MoveTo(CoordToCanvasX(CurDim.BaseRight.X), CoordToCanvasY(CurDim.BaseRight.Y));
    ADest.LineTo(CoordToCanvasX(CurDim.DimensionRight.X), CoordToCanvasY(CurDim.DimensionRight.Y));
    ADest.LineTo(CoordToCanvasX(CurDim.DimensionLeft.X), CoordToCanvasY(CurDim.DimensionLeft.Y));
    ADest.LineTo(CoordToCanvasX(CurDim.BaseLeft.X), CoordToCanvasY(CurDim.BaseLeft.Y));
    // Now the arrows
    // horizontal
    SetLength(Points, 3);
    if CurDim.DimensionRight.Y = CurDim.DimensionLeft.Y then
    begin
      ADest.Brush.FPColor := colBlack;
      ADest.Brush.Style := bsSolid;
      // Left arrow
      Points[0] := Point(CoordToCanvasX(CurDim.DimensionLeft.X), CoordToCanvasY(CurDim.DimensionLeft.Y));
      Points[1] := Point(Points[0].X + 7, Points[0].Y - 3);
      Points[2] := Point(Points[0].X + 7, Points[0].Y + 3);
      ADest.Polygon(Points);
      // Right arrow
      Points[0] := Point(CoordToCanvasX(CurDim.DimensionRight.X), CoordToCanvasY(CurDim.DimensionRight.Y));
      Points[1] := Point(Points[0].X - 7, Points[0].Y - 3);
      Points[2] := Point(Points[0].X - 7, Points[0].Y + 3);
      ADest.Polygon(Points);
      ADest.Brush.Style := bsClear;
      // Dimension text
      Points[0].X := CoordToCanvasX((CurDim.DimensionLeft.X+CurDim.DimensionRight.X)/2);
      Points[0].Y := CoordToCanvasY(CurDim.DimensionLeft.Y);
      LowerDim.X := CurDim.DimensionRight.X-CurDim.DimensionLeft.X;
      ADest.Font.Size := 10;
      ADest.TextOut(Points[0].X, Points[0].Y, Format('%.1f', [LowerDim.X]));
    end
    else
    begin
      ADest.Brush.FPColor := colBlack;
      ADest.Brush.Style := bsSolid;
      // There is no upper/lower preference for DimensionLeft/Right, so we need to check
      if CurDim.DimensionLeft.Y > CurDim.DimensionRight.Y then
      begin
        UpperDim := CurDim.DimensionLeft;
        LowerDim := CurDim.DimensionRight;
      end
      else
      begin
        UpperDim := CurDim.DimensionRight;
        LowerDim := CurDim.DimensionLeft;
      end;
      // Upper arrow
      Points[0] := Point(CoordToCanvasX(UpperDim.X), CoordToCanvasY(UpperDim.Y));
      Points[1] := Point(Points[0].X + Round(AMulX), Points[0].Y - Round(AMulY*3));
      Points[2] := Point(Points[0].X - Round(AMulX), Points[0].Y - Round(AMulY*3));
      ADest.Polygon(Points);
      // Lower arrow
      Points[0] := Point(CoordToCanvasX(LowerDim.X), CoordToCanvasY(LowerDim.Y));
      Points[1] := Point(Points[0].X + Round(AMulX), Points[0].Y + Round(AMulY*3));
      Points[2] := Point(Points[0].X - Round(AMulX), Points[0].Y + Round(AMulY*3));
      ADest.Polygon(Points);
      ADest.Brush.Style := bsClear;
      // Dimension text
      Points[0].X := CoordToCanvasX(CurDim.DimensionLeft.X);
      Points[0].Y := CoordToCanvasY((CurDim.DimensionLeft.Y+CurDim.DimensionRight.Y)/2);
      LowerDim.Y := CurDim.DimensionRight.Y-CurDim.DimensionLeft.Y;
      if LowerDim.Y < 0 then LowerDim.Y := -1 * LowerDim.Y;
      ADest.Font.Size := 10;
      ADest.TextOut(Points[0].X, Points[0].Y, Format('%.1f', [LowerDim.Y]));
    end;
    SetLength(Points, 0);
{      // Debug info
    ADest.TextOut(CoordToCanvasX(CurDim.BaseRight.X), CoordToCanvasY(CurDim.BaseRight.Y), 'BR');
    ADest.TextOut(CoordToCanvasX(CurDim.DimensionRight.X), CoordToCanvasY(CurDim.DimensionRight.Y), 'DR');
    ADest.TextOut(CoordToCanvasX(CurDim.DimensionLeft.X), CoordToCanvasY(CurDim.DimensionLeft.Y), 'DL');
    ADest.TextOut(CoordToCanvasX(CurDim.BaseLeft.X), CoordToCanvasY(CurDim.BaseLeft.Y), 'BL');}
  end;
end;

procedure DrawFPVTextToCanvas(ASource: TvVectorialDocument; CurText: TvText;
  ADest: TFPCustomCanvas;
  ADestX: Integer = 0; ADestY: Integer = 0; AMulX: Double = 1.0; AMulY: Double = 1.0);

  function CoordToCanvasX(ACoord: Double): Integer;
  begin
    Result := Round(ADestX + AmulX * ACoord);
  end;

  function CoordToCanvasY(ACoord: Double): Integer;
  begin
    Result := Round(ADestY + AmulY * ACoord);
  end;

var
  i: Integer;
  {$ifdef USE_LCL_CANVAS}
  ALCLDest: TCanvas;
  {$endif}
  //
  LowerDim: T3DPoint;
begin
  {$ifdef USE_LCL_CANVAS}
  ALCLDest := TCanvas(ADest);
  {$endif}

  ADest.Font.Size := Round(AmulX * CurText.Font.Size);
  ADest.Pen.Style := psSolid;
  ADest.Pen.FPColor := colBlack;
  ADest.Brush.Style := bsClear;
  {$ifdef USE_LCL_CANVAS}
  ALCLDest.Font.Orientation := Round(CurText.Font.Orientation * 16);
  {$endif}

  LowerDim.Y := CurText.Y + CurText.Font.Size;
  ADest.TextOut(CoordToCanvasX(CurText.X), CoordToCanvasY(LowerDim.Y), CurText.Value);
end;

end.

