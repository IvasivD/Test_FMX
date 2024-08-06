unit UnitCustomerEdit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, UnProcedure, Data.DB, Data.Win.ADODB;

type
  TCustomerEditForm = class(TForm)
    Panel1: TPanel;
    Sb_Ok: TButton;
    Sb_Close: TButton;
    Panel2: TPanel;
    Edt_Id: TEdit;
    Edt_Name: TEdit;
    Edt_Address: TEdit;
    Edt_Phone: TEdit;
    Edt_IdentCode: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure Edt_IdKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure Edt_PhoneKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
  private
    function Fill_CustomerData: TCustomerData;
    procedure PrepareData(aData: TCustomerData);
  public
    { Public declarations }
  end;

function ExecuteÑustomerEdit(addRec: Boolean; var aData: TCustomerData): boolean;

implementation

{$R *.fmx}

function ExecuteÑustomerEdit(addRec: Boolean; var aData: TCustomerData): boolean;
begin
  with TCustomerEditForm.Create(Application) do
    try
      Caption := SetFormCaption(Caption, addRec);
      if aData.Id > -1 then PrepareData(aData);
      Result := ShowModal = mrOk;
      if Result then aData := Fill_CustomerData;
    finally
      Free;
    end;
end;

procedure TCustomerEditForm.Edt_IdKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  if not (KeyChar in [#8, '0'..'9']) then
    KeyChar := #0;
end;

procedure TCustomerEditForm.Edt_PhoneKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if not (KeyChar in [#8, '0'..'9', '+', #32]) then
    KeyChar := #0;
end;

function TCustomerEditForm.Fill_CustomerData: TCustomerData;
begin
  Result.Id     := SafeStrToInt(Edt_Id.Text, -1);
  Result.Name   := Edt_Name.Text;
  Result.Address:= Edt_Address.Text;
  Result.Phone  := Edt_Phone.Text;
  Result.IdentCode := Edt_IdentCode.Text;
end;

procedure TCustomerEditForm.PrepareData(aData: TCustomerData);
begin
  Edt_Id.Text     := IntToStr(aData.Id);
  Edt_Name.Text   := aData.Name;
  Edt_Address.Text:= aData.Address;
  Edt_Phone.Text  := aData.Phone;
  Edt_IdentCode.Text := aData.IdentCode;
end;

end.
