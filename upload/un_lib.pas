unit un_lib;

interface

uses   Windows, Messages, SysUtils, Classes, Dialogs,
  StrUtils, ComCtrls;

const
  CRLF      = #$0D + #$0A;
  APS       = #$27;

type
  TNumberInfo = record
    count: integer;
    arr: array of TPoint;
  end;

function DeQuotedStr (str: widestring):widestring;
function DeQuotedStr2(str: widestring):widestring;
function GetNumberInfo(n:byte; color: integer; prefix:string; img: TImage): TNumberInfo;
function GetNumberInfo2(n:byte; color: integer; x,y,w,h, ext:integer; prefix:string; img: TImage): TNumberInfo;
function OCRNumbers(ImgSource, ImgData: TImage; SymbolWidth, SymbolHeigth, CutRight, Frenquality: integer): string;
function GetWordFromTwoWord(AWord, ABeginWord, AEndWord: string): string;
function BadStrNumberToGood(AStr: string):string;
function FindDataAsInteger(ATreeView: TTreeView; AID: integer) : TTreeNode;

implementation

function FindDataAsInteger(ATreeView: TTreeView; AID: integer) : TTreeNode;
var
  Noddy: TTreeNode;
  Searching: boolean;
  I: Integer;
begin
   I := -1;
   Noddy := ATreeView.Items[0];
   ATreeView.Selected := Noddy;
   Searching := true;
   while (Searching) and (Noddy <> nil) do
   begin
      //if Noddy.Text = Target then
      if  Integer(Noddy.Item[i].Data) = AID then
      begin
         Searching := false;
         ATreeView.Selected := Noddy;
      end
      else Noddy := Noddy.GetNext;
      Inc(I);
  end;
  Result := ATreeView.Selected;
end;


function GetWordFromTwoWord(AWord, ABeginWord, AEndWord: string): string;
var
  iIndex, iIndex2, iLenBeginWord, iLenEndWord, iLenWord: integer;
  sTemp: string;
begin
  iLenWord := length(AWord);
  iLenBeginWord := length(ABeginWord);
  iLenEndWord := length(AEndWord);

  if (ABeginWord <> '') then
    iIndex  := pos(ABeginWord,AWord)
  else
    iIndex := 1;

  sTemp := copy(AWord, iIndex + iLenBeginWord, iLenWord - iLenBeginWord);

  if (AEndWord <> '') then
    iIndex2 := iIndex + pos(AEndWord,sTemp)
  else
    iIndex2 := iLenWord;

  result := copy(AWord, iIndex + iLenBeginWord, iIndex2-iIndex-1);
end;

function GetNumberInfo(n:byte; color: integer; prefix:string; img: TImage): TNumberInfo;
var
  i,j, wp: integer;
  tmpInfo: TNumberInfo;
begin
   img.Picture.LoadFromFile(prefix+'/'+IntToStr(n)+'.bmp');
   wp := 0;
   for i := 0 to img.Width do
    begin
      for j:= 0 to img.Height do
       begin
          if img.Canvas.Pixels[i, j] = color
            then wp := wp + 1;
       end;
    end;

    tmpInfo.Count := wp;
    Result := tmpInfo;

end;



function RGBtoHSV( r, g, b: real; var h, s, v: real): boolean;
var
 	min, max, delta: real;
begin

  min := r;
  if g < min then min := g;
  if b < min then min := b;

  max := r;
  if g > max then max := g;
  if b > max then max := b;

	v := max;				// v

	delta := max - min + 0.001;


	if ( max <> 0 ) then
		s := delta / max		// s
	else
    begin
		// r = g = b = 0		// s = 0, v is undefined
		s := 0;
		h := -1;
		Exit;
	end;

	if ( r = max ) then
		h := ( g - b ) / delta		// between yellow & magenta
	else if ( g = max ) then
		h := 2 + ( b - r ) / delta	// between cyan & yellow
	else
		h := 4 + ( r - g ) / delta;	// between magenta & cyan

	h := h * 60;				// degrees
	if( h < 0 ) then
		h := h + 360;

end;

//здесь собираем маску цифры (значимый цвет + координаты точе с этим цветом)
function GetNumberInfo2(n:byte; color: integer; x,y,w,h, ext:integer; prefix:string; img: TImage): TNumberInfo;
var
  i,j, wp: integer;
  tmpInfo: TNumberInfo;
  koor: TPoint;
  r, g, b,
  hc, sc, vc,
  hp, sp, vp: real;
  HexColor: string;
begin
   if  ext = 1 then img.Picture.LoadFromFile(prefix+'/'+IntToStr(n)+'.bmp');

   if ((w=0) or (h = 0)) then
     begin
       w:= img.Picture.Width;
       h:= img.Picture.Height;
    end;

   if h > img.Picture.Height then w := img.Picture.Height;

   wp := 0;
   for i := x to w do
    begin
      for j:= y to h do
       begin

          HexColor := Dec2Hex(color, 6);
          RGBtoHSV( Hex2Dec(Copy(HexColor,5,2)), Hex2Dec(Copy(HexColor,3,2)), Hex2Dec(Copy(HexColor,1,2)), hc, sc, vc);

          HexColor := Dec2Hex(img.Canvas.Pixels[i, h-j], 6);
          RGBtoHSV( Hex2Dec(Copy(HexColor,5,2)), Hex2Dec(Copy(HexColor,3,2)), Hex2Dec(Copy(HexColor,1,2)), hp, sp, vp);

          if ( abs(vc-vp) >5 )
            then
              begin
                wp := wp + 1;
                SetLength(tmpInfo.arr, wp);
                koor.X := i-x;
                koor.Y := j-y;
                tmpInfo.arr[wp-1] := koor;
              end;
       end;
    end;

    tmpInfo.Count := wp;
    Result := tmpInfo;

end;


function DeQuotedStr(str: widestring):widestring;

var tempStr: widestring;
begin
  tempStr := Trim(str);
  if (( copy(tempStr, 1, 1) = '"')or (copy(tempStr, 1, 1) = '''') )
    then tempStr := copy(tempStr, 2, length(tempStr)-2);
  Result := tempStr;
end;

function DeQuotedStr2(str: widestring):widestring;
var tempStr: widestring;
begin
  tempStr := ReplaceStr(str, '"', '`');
  tempStr := ReplaceStr(tempStr, APS, '`');
  tempStr := ReplaceStr(tempStr, '&nbsp;', ' ');
  tempStr := ReplaceStr(tempStr, '&NBSP;', ' ');
  tempStr := ReplaceStr(tempStr, '<br>', ' ');
  tempStr := ReplaceStr(tempStr, '<BR>', ' ');
  tempStr := ReplaceStr(tempStr, #$0A, '');
  tempStr := ReplaceStr(tempStr, #$0D, '');
  Result := tempStr;
end;

function OCRNumbers(ImgSource, ImgData: TImage; SymbolWidth, SymbolHeigth, CutRight, Frenquality: integer): string;
var
  i1, j1, i, j, wp, wpmax, lastnum : integer;
  HexColor: string;
  hc, sc, vc,
  hp, sp, vp: real;
  sX1, sX2: integer;
  tempStr : string;
  Image2, Image3: TImage;
begin

  Image2 := TImage.Create(nil);
  
  Image2.Visible := False;
  Image3 := TImage.Create(nil);
  Image3.Visible := False;

  Image2.Width := SymbolWidth;
  Image2.Height := SymbolHeigth;

 tempStr := '';
 i1 := 0;
 while i1 <= ImgSource.Picture.Width-1-CutRight do

 begin

   //Прочтем символ
  for i:=0 to Image2.Width-1 do
     for j:=0 to Image2.Height-1 do
       Image2.Canvas.Pixels[i,j] := ImgSource.Canvas.Pixels[i+i1,j];

  wpmax := 0;
  lastnum :=0;

  for j1 := 0 to 9 do

 begin

  //загрузим эталон из ImgData
  //Image3.Picture.LoadFromFile('E:\My Documents\soft_of_AVI\Programms\Delphi\ocr\ocr2\test\jpg\' + inttostr(j1) + '.bmp');

  //переведем их в маски по порогу яркости
  for i:=0 to Image2.Width-1 do
     for j:=0 to Image2.Height-1 do
      begin

          HexColor := Dec2Hex(Image2.Canvas.Pixels[i, j], 6);
          RGBtoHSV( Hex2Dec(Copy(HexColor,5,2)), Hex2Dec(Copy(HexColor,3,2)), Hex2Dec(Copy(HexColor,1,2)), hp, sp, vp);


          if (
          (vp > Frenquality)
          ) then Image2.Canvas.Pixels[i,j] := 0;


          HexColor := Dec2Hex(ImgData.Canvas.Pixels[i+(j1*SymbolWidth), j], 6);
          RGBtoHSV( Hex2Dec(Copy(HexColor,5,2)), Hex2Dec(Copy(HexColor,3,2)), Hex2Dec(Copy(HexColor,1,2)), hp, sp, vp);

          if    (
          (vp > Frenquality)

          )
          then ImgData.Canvas.Pixels[i+(j1*SymbolWidth),j] := 0;

      end;

    sX1 := 0;  
   if ImgSource.Picture.Height <> ImgData.Picture.Height then
    sX1 := ImgData.Picture.Height-ImgSource.Picture.Height;

  //сравним символ с этанолом
  wp :=0;
  for i:=0 to Image2.Width-1 do
     for j:=0 to Image2.Height-1 do
     begin
      if (
      (
        (Image2.Canvas.Pixels[i,j] = ImgData.Canvas.Pixels[i+(j1*SymbolWidth),j+sX1])
      )
      and (Image2.Canvas.Pixels[i,j] = 0)
       )then
         begin
          wp := wp+1;
          //Image2.Canvas.Pixels[i,j] := clRed;
         end;
     end;

     if wpmax<wp then
      begin
        wpmax := wp;
        lastnum := j1;
      end;

   //Form1.Memo1.Lines.Add('Точность совпадения ' + IntToStr(j1) +  ' = ' + FormatFloat( '##0.00',  100 * wp / (Image2.Width * Image2.Height)) + ' / ' + IntToStr(wp));
  end;

   tempStr := tempStr + IntToStr(lastnum);

   i1:= i1+ SymbolWidth;
 end;

   Result := tempStr;

end;


function BadStrNumberToGood(AStr: string):string;
var i: integer;
    tempStr: string;
begin

 tempStr := '';
  for i := 1 to length(AStr) do
   if AStr[i] in ['0','1','2','3','4','5','6','7','8','9','.',',']
    then tempStr := tempStr + AStr[i];

  tempStr := AnsiReplaceStr(tempStr, '.', DecimalSeparator);

  try
    StrToFloat(tempStr);
    except
    tempStr := '';
  end;

 Result := tempStr;

end;

begin
end.
