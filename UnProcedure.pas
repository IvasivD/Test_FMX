unit UnProcedure;

interface

uses ADODB,DB,Classes,variants, SysUtils, Vcl.Dialogs, Winapi.Windows, Vcl.Forms;

type
  TOptMessageDlgButs = ( but_OK, but_YES_NO, but_OK_CANCEL, but_YES_NO_CANCEL, but_RETRY_CANCEL, but_ABORT_RETRY_IGNORE);
  TOptMessageDlgButRes = (res_OK, res_CANCEL, res_ABORT, res_RETRY, res_IGNORE, res_YES, res_NO, res_CLOSE, res_HELP);
  TCustomerData = record
    Id: Integer;
    Name: string;
    Address: string;
    Phone: string;
    IdentCode: string;
  end;
  TOrderData = record
    Id: Integer;
    Id_Customers: Integer;
    CustomerName: string;
    OrderNo: string;
    DateCreate: string;
    ReasonAppeal: Integer;
    ReasonAppealStr: string;
    Power: Double;
    Comment: string;
  end;
  POrderData = ^TOrderData;

  function CreateConnectionString(ConnectToDB: String): String;
  function CreateAdoConnection(ConnectToDB: String): TAdoConnection;
  function CreateDataSet( ADOCon: TAdoConnection; CommandText: String=''; CmdType: TCommandType=cmdText; Active: Boolean=True ):TADODataset;   overload;
  function CreateDataSet( ConnectionString: String; CommandText: String=''; CmdType: TCommandType=cmdText; Active: Boolean=True ):TADODataset; overload;
  function UpdateSql( ADOCon: TADOConnection; CommandText: String='' ): Integer; overload;
  function UpdateSql(  ConnectToDB:String; CommandText:String='' ): Integer; overload;

  function GetDataLinkPath: string;
  function SafeStrToInt(const Value: string; Excpt: Longint = 0): Longint;

  procedure DestroyADOCon( ADOCon: TADOConnection );
  procedure DestroyDS( DS: TCustomADODataSet );

  procedure Fill_DefaultCustomerData(var aData: TCustomerData);
  procedure Fill_DefaultOrderData(var aData: TOrderData);
  function Fill_OrderData(ADB: TCustomADODataSet): Pointer;
  function SetFormCaption(aCaption: string; addRec: Boolean): string;

  function ErrorDlg(const Msg: string): Boolean;
  function WarningDlgYN(const Msg: string): Boolean;
  function MyShowMessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TOptMessageDlgButs ):TOptMessageDlgButRes;

  procedure Delete_Order(Id: Integer);
  procedure Delete_Customer(Id: Integer);

implementation

procedure Fill_DefaultCustomerData(var aData: TCustomerData);
begin
  aData.Id := -1;
  aData.Name := '';
  aData.Address := '';
  aData.Phone := '';
  aData.IdentCode := '';
end;

procedure Fill_DefaultOrderData(var aData: TOrderData);
begin
  aData.Id := -1;
  aData.Id_Customers := -1;
  aData.CustomerName := '';
  aData.OrderNo := '';
  aData.DateCreate := FormatDateTime('yyyy-mm-dd HH:MM', Now);
  aData.ReasonAppeal := -1;
  aData.Power := 0;
  aData.Comment := '';
end;

function CreateConnectionString(ConnectToDB: String): String;
begin
  Result := Format('FILE NAME=%s', [ConnectToDB]);
end;

function CreateAdoConnection(ConnectToDB: String): TAdoConnection;
begin
  Result := TAdoConnection.Create(nil);
  Result.LoginPrompt := False;
  Result.ConnectionString := CreateConnectionString(ConnectToDB);
end;

function CreateDataSet( ADOCon:TAdoConnection; CommandText:String='';CmdType:TCommandType=cmdText; Active:Boolean=True ):TADODataset;
begin
  try
    ADOCon.Connected:=True;
    result := TADODataset.create(nil);
    result.Connection := ADOCon;
    result.CommandType := CmdType;
    result.CommandText := CommandText;
    if (Active)and(CommandText<>'') then result.Open;
  except
    result := nil;
  end;
end;

function UpdateSql( ADOCon:TADOConnection; CommandText:String='' ):Integer;
var DBQuery:TADOQuery;
begin
  try
    try
      ADOCon.Connected:=True;
      DBQuery := TADOQuery.create(nil);
      DBQuery.Connection := ADOCon;
      DBQuery.SQL.Text := CommandText;
      result := DBQuery.ExecSQL;
    finally
      DBQuery.Free;
    end;
  except
    if DBQuery<> nil then DBQuery.Free;
    result := -1;
  end;
end;

procedure DestroyADOCon( ADOCon:TADOConnection );
begin
  if ADOCon <> nil then
  begin
    if ADOCon.Connected then ADOCon.Connected := False;
    FreeAndNil(ADOCon);
  end;
end;

function CreateDataSet( ConnectionString:String; CommandText:String='';CmdType:TCommandType=cmdText; Active:Boolean=True ):TADODataset; overload;
var ADOCon:TAdoConnection;
begin
  ADOCon := CreateAdoConnection(ConnectionString);

  try
    ADOCon.Connected:=True;
    result :=TADODataset.create(nil);
    result.Connection := ADOCon;
    result.CommandType := CmdType;
    result.CommandText := CommandText;
    if (Active)and(CommandText<>'') then result.Open;

  except
    result := nil;
  end;
end;

procedure DestroyDS( DS: TCustomADODataSet );
var ADOCon:TAdoConnection;
begin
  if DS <> nil then
  begin
    if DS.Active then DS.Close;
    if (DS.Connection.Owner=nil)and(DS.Connection.Name='') then
    begin
      ADOCon := DS.Connection;
      FreeAndNil(ADOCon);
    end;
    FreeAndNil(DS);
  end;
end;

function UpdateSql(  ConnectToDB:String; CommandText:String='' ): Integer;
var ADOCon:TAdoConnection;
begin
  ADOCon := CreateAdoConnection(ConnectToDB);
//  ADOCon:=TAdoConnection.Create(nil);
  try
//    ADOCon.LoginPrompt:= False;
//    ADOCon.ConnectionString := CreateConnectionString( ConnectToDB);
    Result := UpdateSql( ADOCon, CommandText );
  finally
    if ADOCon <> nil then
      FreeAndNil(ADOCon);
  end;
end;

function GetDataLinkPath: string;
begin
  Result := ExpandFileName(ExtractFilePath(ParamStr(0) )+ '\..\..\') + 'DB\TestDB.udl';
end;

  function IsStrANumber(const S: string;JusInt:Boolean=false): Boolean;
  var
    P: PChar;
    DecimalSep:string[1];
  begin
    P      := PChar(S);
    Result := False;

    if LowerCase(S)='e' then exit;
    if LowerCase(S)='-' then exit;

    if JusInt then DecimalSep:=''
       else DecimalSep:=FormatSettings.DecimalSeparator;

    while P^ <> #0 do
    begin
      //************************
      if not (P^ in ['0'..'9','-',DecimalSep[1]]) then
         begin
           Result := False;
           Exit;
         end;
      //************************
      Inc(P);
      Result := True;
    end;
  end;

function SafeStrToInt(const Value: string; Excpt: Longint = 0): Longint;
begin
  if IsStrANumber(Value, True) then
    Result := StrToInt(Value)
  else
    Result := Excpt;
end;

function Fill_OrderData(ADB: TCustomADODataSet): Pointer;
const aReason: array[0..1] of string = ('Нове підключення', 'Збільшення існуючої потужності абонента');
var pData: POrderData;

begin
  New(pData);
  pData^.Id := aDB.FieldByName('ID').AsInteger;
  pData^.Id_Customers := aDB.FieldByName('ID_Customers').AsInteger;
  pData^.CustomerName := aDB.FieldByName('CustomerName').AsString;
  pData^.OrderNo := aDB.FieldByName('OrderNo').AsString;
  pData^.DateCreate := FormatDateTime('yyyy-mm-dd HH:MM', aDB.FieldByName('DateCreate').AsDateTime);
  pData^.ReasonAppeal := aDB.FieldByName('ReasonAppeal').AsInteger;
  pData^.ReasonAppealStr := aReason[aDB.FieldByName('ReasonAppeal').AsInteger];
  pData^.Power := aDB.FieldByName('ConnectionPower').AsFloat;
  pData^.Comment := aDB.FieldByName('aComment').AsString;
  Result := pData;
end;

function ErrorDlg(const Msg: string): Boolean;
begin
  Result := MyShowMessageDlg(Msg, mtError, but_OK) = res_OK;
end;

function WarningDlgYN(const Msg: string): Boolean;
begin
  Result := MyShowMessageDlg(Msg, mtWarning, but_YES_NO) = res_YES;
end;

function MyShowMessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TOptMessageDlgButs ):TOptMessageDlgButRes;
var WinDlgType:Cardinal;
    ButtDlg:Cardinal;
    TitleDlg:string;
    ResMessBox:Cardinal;
    MesHandle:THandle;
begin
   case  DlgType of
      mtWarning:begin WinDlgType := MB_ICONWARNING; TitleDlg:='Увага';   end;
      mtError  :begin WinDlgType := MB_ICONERROR;   TitleDlg:='Помилка'; end;
      mtInformation :begin WinDlgType := MB_ICONINFORMATION; TitleDlg:='Інформація'; end;
      mtConfirmation :begin WinDlgType := MB_ICONQUESTION;  TitleDlg:='Підтвердіть'; end;
      mtCustom  : begin WinDlgType     := MB_USERICON;      TitleDlg:='Повідомлення';end;
   end;
   //*********************************
   case Buttons of
     but_OK: ButtDlg := MB_OK;
     but_OK_CANCEL: ButtDlg:= MB_OKCANCEL;
     but_YES_NO: ButtDlg:= MB_YESNO;
     but_YES_NO_CANCEL: ButtDlg:= MB_YESNOCANCEL;
     but_RETRY_CANCEL: ButtDlg:= MB_RETRYCANCEL;
     but_ABORT_RETRY_IGNORE: ButtDlg:= MB_ABORTRETRYIGNORE;
   end;
  //**********************************
  if Screen.ActiveForm <> nil then MesHandle := Screen.ActiveForm.Handle
  else MesHandle := Application.Handle;

  ResMessBox := MessageBox( MesHandle , PChar( Msg ) , PChar( TitleDlg ), ButtDlg + WinDlgType );
  //**********************************
  case ResMessBox of
   IDOK     : result:= res_OK;
   ID_CANCEL: result:= res_CANCEL;
   ID_ABORT : result:= res_ABORT;
   ID_RETRY : result:= res_RETRY;
   ID_IGNORE: result:= res_IGNORE;
   ID_YES   : result:= res_YES;
   ID_NO    : result:= res_NO;
   ID_CLOSE : result:= res_CLOSE;
   ID_HELP : result:= res_HELP;
  end;
end;

procedure Delete_Order(Id: Integer);
const
  sSQLOrderDelete = 'delete from Orders where Id = %d';
begin
  UpdateSql(GetDataLinkPath, Format(sSQLOrderDelete, [Id]));
end;

procedure Delete_Customer(Id: Integer);
const
  sSQLOrderDelete = 'delete from Customers where Id = %d';
begin
  UpdateSql(GetDataLinkPath, Format(sSQLOrderDelete, [Id]));
end;

function SetFormCaption(aCaption: string; addRec: Boolean): string;
begin
  if addRec then Result := aCaption + ' - додати' else Result := aCaption + ' - редагувати';
end;

end.
