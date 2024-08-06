unit UnitOrderEdit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListBox,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, UnProcedure, FMX.ScrollBox,
  FMX.Memo, CustomerFrm;

type
  TOrderEditForm = class(TForm)
    Edt_OrderNo: TEdit;
    Edt_Power: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Cbx_Reason: TComboBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Mem_Comment: TMemo;
    Panel1: TPanel;
    Sb_Ok: TButton;
    Sb_Close: TButton;
    Edt_Customer: TEdit;
    Sb_Customer: TButton;
    procedure Edt_PowerKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure Sb_CustomerClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FCustomerData: TCustomerData;
    FOrderData: TOrderData;
    procedure PrepareData(aData: TOrderData);
    function Fill_OrderData: TOrderData;
    function CheckDataInput: Boolean;
  public
    { Public declarations }
  end;

function ExecuteOrderEdit(addRec: Boolean; var aData: TOrderData): boolean;

implementation

{$R *.fmx}

function ExecuteOrderEdit(addRec: Boolean; var aData: TOrderData): boolean;
begin
  with TOrderEditForm.Create(Application) do
    try
      Caption := SetFormCaption(Caption, addRec);
      PrepareData(aData);
      Result := ShowModal = mrOk;
      if Result then aData := Fill_OrderData;
    finally
      Free;
    end;
end;

{ TForm4 }

procedure TOrderEditForm.Sb_CustomerClick(Sender: TObject);
begin
  FCustomerData := ShowCustomerForm(True);
  Edt_Customer.Text := FCustomerData.Name;
end;

function TOrderEditForm.CheckDataInput: Boolean;
begin
  Result := False;
  if Edt_Customer.Text = '' then
  begin
    ErrorDlg('Не вибрано замовника!');
    Exit;
  end;
  Result := True;
end;

procedure TOrderEditForm.Edt_PowerKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if not (KeyChar in [#8, '0'..'9', FormatSettings.DecimalSeparator]) then
    KeyChar := #0;
end;

function TOrderEditForm.Fill_OrderData: TOrderData;
begin
  Result := FOrderData;
  Result.Id_Customers := FCustomerData.Id;
  Result.OrderNo := Edt_OrderNo.Text;
  Result.ReasonAppeal := Cbx_Reason.ItemIndex;
  Result.Power := StrToFloat(Edt_Power.Text);
  Result.Comment := Mem_Comment.Text;
end;

procedure TOrderEditForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if CanClose and (ModalResult = mrOk) then CanClose := CheckDataInput;
end;

procedure TOrderEditForm.PrepareData(aData: TOrderData);
begin
  FOrderData := aData;
  if aData.Id > -1 then FCustomerData.Id := aData.Id_Customers;
  Edt_Customer.Text := aData.CustomerName;
  Edt_OrderNo.Text := aData.OrderNo;
  Cbx_Reason.ItemIndex := aData.ReasonAppeal;
  Edt_Power.Text := FloatToStr(aData.Power);
  Mem_Comment.Text := aData.Comment;
end;

end.
