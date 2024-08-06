unit CustomerFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.StdCtrls, FMX.ListView, FMX.Controls.Presentation, UnProcedure, Data.DB,
  Data.Win.ADODB;

type
  TCustomerForm = class(TForm)
    Panel1: TPanel;
    LV_Ñustomer: TListView;
    Sb_Add: TButton;
    Sb_Close: TButton;
    Sb_Edit: TButton;
    Sb_Delete: TButton;
    procedure Sb_AddClick(Sender: TObject);
    procedure Sb_DeleteClick(Sender: TObject);
    procedure LV_ÑustomerDblClick(Sender: TObject);
  private
    function Fill_CustomerData: TCustomerData;
    procedure Fill_CustomerView;
    procedure Update_CustomerData(addRec: Boolean; aData: TCustomerData);
    procedure Edit_CustomerData(addRec: Boolean);
  public
    { Public declarations }
  end;

function ShowCustomerForm(aTypeSelect: Boolean = False): TCustomerData;

implementation

uses
  UnitCustomerEdit;

{$R *.fmx}

function ShowCustomerForm(aTypeSelect: Boolean = False): TCustomerData;
begin
  with TCustomerForm.Create(Application) do
    try
      if aTypeSelect then Sb_Close.Text := 'Âèáğàòè';

      Fill_CustomerView;
      if (ShowModal = mrOk) and aTypeSelect then
        Result := Fill_CustomerData;
    finally
      Free;
    end;
end;

procedure TCustomerForm.Edit_CustomerData(addRec: Boolean);
var aData: TCustomerData;
begin
  if addRec or (LV_Ñustomer.ItemCount = 0) then
    Fill_DefaultCustomerData(aData)
  else
    aData := Fill_CustomerData;

  if ExecuteÑustomerEdit(addRec, aData) then
  begin
    Update_CustomerData(addRec, aData);
    Fill_CustomerView;
  end;
end;

function TCustomerForm.Fill_CustomerData: TCustomerData;
var AItem: TListViewItem;
begin
  AItem := TListViewItem( LV_Ñustomer.Items.Item[ LV_Ñustomer.ItemIndex ] );
  result.Id := AItem.Data['Item_id'].AsInteger;
  result.Name := AItem.Data['Item_Name'].AsString;
  result.Address := AItem.Data['Item_Address'].AsString;
  result.Phone := AItem.Data['Item_Phone'].AsString;
  result.IdentCode := AItem.Data['Item_IdentCode'].AsString;
end;

procedure TCustomerForm.Fill_CustomerView;
var AItem: TListViewItem;
    aDB: TCustomADODataSet;
    ind: Integer;
begin
  ind := 0;
  if LV_Ñustomer.ItemIndex > 0 then ind := LV_Ñustomer.ItemIndex;

  LV_Ñustomer.Items.Clear;
//    AItem := TListViewItem( LV_Ñustomer.Items.Item[ LV_Ñustomer.ItemIndex ] );
  aDB := CreateDataSet(GetDataLinkPath, 'SELECT * FROM [Customers]');
  try
    while not aDB.Eof do
    begin
      AItem := LV_Ñustomer.Items.Add;
      AItem.Data['Item_id'] := aDB.FieldByName('ID').AsInteger;
      AItem.Data['Item_Name'] := aDB.FieldByName('Name').AsString;
      AItem.Data['Item_Address'] := aDB.FieldByName('Address').AsString;
      AItem.Data['Item_Phone'] := aDB.FieldByName('Phone').AsString;
      AItem.Data['Item_IdentCode'] := aDB.FieldByName('IdentCode').AsString;
      aDB.Next;
    end;
  finally
    DestroyDS(aDB);
    if LV_Ñustomer.ItemCount > 0 then LV_Ñustomer.ItemIndex := Ind;
  end;
end;

procedure TCustomerForm.LV_ÑustomerDblClick(Sender: TObject);
begin
  Edit_CustomerData(LV_Ñustomer.ItemCount = 0);
end;

procedure TCustomerForm.Sb_AddClick(Sender: TObject);
var
    addRec: Boolean;
begin
  addRec := TButton(Sender).Tag = 1;
  Edit_CustomerData(addRec);
end;

procedure TCustomerForm.Sb_DeleteClick(Sender: TObject);
begin
  if LV_Ñustomer.ItemCount = 0 then
  begin
    ErrorDlg('Ñïèñîê ïóñòèé!');
    Exit;
  end;

  if WarningDlgYN('Âèäàëèòè çàïèñ?') then
  begin
    Delete_Customer(Fill_CustomerData.Id);
    Fill_CustomerView;
  end;
end;

procedure TCustomerForm.Update_CustomerData(addRec: Boolean; aData: TCustomerData);
var aSQL: string;
begin
  if addRec then
    aSQL := Format('insert into Customers (Name, Address, Phone, IdentCode) '+
      'Values (''%s'', ''%s'', ''%s'', ''%s'')', [aData.Name, aData.Address, aData.Phone, aData.IdentCode])
  else
    aSQL := Format('update Customers set Name = ''%s'', Address = ''%s'', Phone = ''%s'', ' +
      'IdentCode = ''%s'' where id = %d', [aData.Name, aData.Address, aData.Phone, aData.IdentCode, aData.Id]);
  UpdateSql(GetDataLinkPath, aSQL);
end;

end.
