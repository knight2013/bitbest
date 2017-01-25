program upload;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, httpsend, ShellApi,windows


  { you can add units after this };

type

  { TUpload }

  TUpload = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ TUpload }




function HttpPostFileForm(const URL, FieldName, FileName: string;
  const Data: TStream; const FormFields:TStrings; const ResultData:
TStrings): Boolean;
var
  HTTP: THTTPSend;
  Bound, s: string;
  i:integer;

    Heads: TStringList;
    Cooks: TStringList;
    Redirect: string;

  link: string;

const
  CRLF      = #$0D + #$0A;
  FIELD_MASK = CRLF + '--%s' + CRLF +
              'Content-Disposition: form-data; name="%s"' + CRLF + CRLF
+
              '%s';
begin



  Bound := IntToHex(Random(MaxInt), 8) + '_Synapse_boundary';
  HTTP := THTTPSend.Create;
  HTTP.KeepAlive := True;
  try
    s := '--' + Bound + CRLF;
    s := s + 'content-disposition: form-data; name="' + FieldName +
'";';
    s := s + ' filename="' + FileName +'"' + CRLF;
    s := s + 'Content-Type: Application/octet-string' + CRLF + CRLF;
    HTTP.Document.Write(Pointer(s)^, Length(s));
    HTTP.Document.CopyFrom(Data, 0);
    // Include formfield
    for i:=0 to FormFields.Count-1 do
      begin
        S:= Format(FIELD_MASK,[Bound, FormFields.Names[I],
        FormFields.Values[FormFields.Names[I]]]);
        HTTP.Document.Write(Pointer(S)^, Length(S));
      end;
    s := CRLF + '--' + Bound + '--' + CRLF;
    HTTP.Document.Write(Pointer(s)^, Length(s));
    HTTP.MimeType := 'multipart/form-data, boundary=' + Bound;
    Result := HTTP.HTTPMethod('POST', URL);

    if (HTTP.ResultCode=301)or(HTTP.ResultCode=302) then
     begin
     //HTTP.Headers.SaveToFile('headers.txt');
     //HTTP.Cookies.SaveToFile('cookies.txt');

       HTTP.Headers.Clear;
       HTTP.Document.Clear;
       Result := HTTP.HTTPMethod('POST', 'http://bitbest.ru/my.html' );
     end;



    ResultData.LoadFromStream(HTTP.Document);

    //href="view.php?img=00X0D179Y4D438l8.png" target

    link := copy(ResultData.Text, pos('view.php?img=', ResultData.Text) + 13, 100 );

    link := copy(link, 1, pos('" target', link )-1 );

    writeln(link);
    ResultData.Add('view.php?img=' + link);


  finally
    HTTP.Free;
  end;
end;


procedure TUpload.DoRun;
var
  ErrorMsg: String;

  streamFile: TFileStream;
  stringsFormFields: TStrings;
  stringsResult: TStrings;

begin
  // quick check parameters
  ErrorMsg:=CheckOptions('u,f,t','upload, file, thumb_size');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('u','upload') then begin

begin
  WriteLn('Upload');

  streamFile := TFileStream.Create( GetOptionValue ('f'), fmOpenRead	or fmShareDenyWrite);
  stringsFormFields := TStringList.Create;
  stringsResult := TStringList.Create;

  stringsFormFields.Add('send=1');
  stringsFormFields.Add('thumb_size=' + GetOptionValue ('t') );
  stringsFormFields.Add('submit=Загрузить');

  HttpPostFileForm(
  'http://bitbest.ru/index.php', //'http://localhost/bitbest/'
  'file1',
  ExtractFileName( GetOptionValue ('f') ),
  streamFile,
  stringsFormFields,
  stringsResult
  );

  //stringsResult.SaveToFile('test.html');


  ShellExecute(
  0,
  'open',
  PChar('http://bitbest.ru/'+stringsResult[stringsResult.Count-1]),
  '',
  '',
  SW_SHOWNA
  );

  stringsFormFields.Free;
  stringsResult.Free;
  streamFile.Free;


    Terminate;
    Exit;
  end;

  { add your program here }

  // stop program loop
  Terminate;
  end;
end;

constructor TUpload.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TUpload.Destroy;
begin
  inherited Destroy;
end;

procedure TUpload.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ',ExeName,' -h');
end;

var
  Application: TUpload;

{$R *.res}

begin
  Application:=TUpload.Create(nil);
  Application.Run;
  Application.Free;
end.

