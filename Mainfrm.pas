unit Mainfrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.ListView, Data.DB,
  Data.Win.ADODB, UnProcedure, FMX.DateTimeCtrls, System.DateUtils, FMX.Edit,
  System.Math.Vectors, FMX.Controls3D, FMX.Objects3D;

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    Sb_Customer: TButton;
    Panel2: TPanel;
    Sb_Edit: TButton;
    Sb_Add: TButton;
    LV_Orders: TListView;
    Sb_Delete: TButton;
    Dtp_From: TDateEdit;
    Dtp_Till: TDateEdit;
    Label1: TLabel;
    Label2: TLabel;
    Panel3: TPanel;
    Edt_OrderNo: TEdit;
    Sb_Search: TButton;
    Grid3D1: TGrid3D;
    Grid3D2: TGrid3D;
    Grid3D3: TGrid3D;
    procedure Sb_AddClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Sb_CustomerClick(Sender: TObject);
    procedure Sb_DeleteClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Dtp_FromChange(Sender: TObject);
    procedure LV_OrdersDblClick(Sender: TObject);
    procedure Sb_SearchClick(Sender: TObject);
  private
    procedure Fill_OrdersView;
    function Get_OrderData(ind: Integer): TOrderData;
    procedure Edit_OrderData(addRec: Boolean);
    procedure Update_OrderData(addRec: Boolean; aData: TOrderData);
    procedure Search_OrderNo;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  CustomerFrm, UnitOrderEdit;

{$R *.fmx}

procedure TMainForm.Sb_CustomerClick(Sender: TObject);
begin
  ShowCustomerForm;
  Fill_OrdersView;
end;

procedure TMainForm.Sb_AddClick(Sender: TObject);
var
    addRec: Boolean;
begin
  addRec := TButton(Sender).Tag = 1;
  Edit_OrderData(addRec);
end;

procedure TMainForm.Dtp_FromChange(Sender: TObject);
begin
  Fill_OrdersView;
end;

procedure TMainForm.Edit_OrderData(addRec: Boolean);
var aData: TOrderData;
begin
  Fill_DefaultOrderData(aData);
  if not addRec then
    aData := Get_OrderData(LV_Orders.ItemIndex);

  if ExecuteOrderEdit(addRec, aData) then
  begin
    Update_OrderData(addRec, aData);
    Fill_OrdersView;
  end;
end;

procedure TMainForm.Fill_OrdersView;
var AItem: TListViewItem;
    aDB: TCustomADODataSet;
    ind: Integer;
    pData: POrderData;
const
  sSQLSelectOrders =
    'select O.*, C.Name CustomerName from Orders O ' +
    '  left join Customers C on O.ID_Customers = C.Id ' +
    '  where O.DateCreate between ''%s'' and ''%s'' ';
begin
  ind := 0;
  if LV_Orders.ItemIndex > 0 then ind := LV_Orders.ItemIndex;

  LV_Orders.Items.Clear;
  aDB := CreateDataSet(GetDataLinkPath,
    Format(sSQLSelectOrders, [FormatDateTime('yyyy-mm-dd', Dtp_From.Date), FormatDateTime('yyyy-mm-dd', Dtp_Till.Date)]));
  try
    while not aDB.Eof do
    begin
      AItem := LV_Orders.Items.Add;
      pData := Fill_OrderData(aDB);
      AItem.Data['Item_OrderNo'] := pData.OrderNo;
      AItem.Data['Item_Date'] := pData.DateCreate;
      AItem.Data['Item_ReasonAppeal'] := pData.ReasonAppealStr;
      AItem.Data['Item_Power'] := pData.Power;
      AItem.Data['Item_Customer'] := pData.CustomerName;
      AItem.Data['Item_Data'] := Integer(pData);
      aDB.Next;
    end;
  finally
    DestroyDS(aDB);
    if LV_Orders.ItemCount > 0 then LV_Orders.ItemIndex := Ind;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
//  LV_Orders.ApplyStyleLookup;
  Dtp_From.Date := StartOfTheMonth(Date);
  Dtp_Till.Date := EndOfTheMonth(Date);
  Dtp_From.OnChange := Dtp_FromChange;
  Dtp_Till.OnChange := Dtp_FromChange;
  Fill_OrdersView;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
var I: Integer;
    AItem: TListViewItem;
begin
  for I := 0 to LV_Orders.ItemCount - 1 do
  begin
    AItem := TListViewItem( LV_Orders.Items.Item[ I ] );
    if AItem.Data['Item_Data'].AsInteger > 0 then
    begin
      Dispose(POrderData( AItem.Data['Item_Data'].AsInteger ));
      AItem.Data['Item_Data'] := 0;
    end;
  end;
end;

function TMainForm.Get_OrderData(ind: Integer): TOrderData;
var AItem: TListViewItem;
begin
  AItem := TListViewItem( LV_Orders.Items.Item[ Ind ] );
  Result := POrderData( AItem.Data['Item_Data'].AsInteger )^;
end;

procedure TMainForm.LV_OrdersDblClick(Sender: TObject);
begin
  Edit_OrderData( LV_Orders.ItemCount = 0 );
end;

procedure TMainForm.Update_OrderData(addRec: Boolean; aData: TOrderData);
var aSQL: string;
begin
  if addRec then
    aSQL := Format('insert into Orders (ID_Customers, OrderNo, DateCreate, ReasonAppeal, ConnectionPower, AComment) '+
      'Values (%d, ''%s'', ''%s'', %d, ''%s'', ''%s'')',
      [aData.Id_Customers, aData.OrderNo, aData.DateCreate, aData.ReasonAppeal, FloatToStr( aData.Power ), aData.Comment])
  else
    aSQL := Format('update Orders set ID_Customers = %d, OrderNo = ''%s'', DateCreate = ''%s'', ReasonAppeal = %d, ' +
      'ConnectionPower = ''%s'', AComment = ''%s'' where id = %d',
      [aData.Id_Customers, aData.OrderNo, aData.DateCreate, aData.ReasonAppeal, FloatToStr( aData.Power ), aData.Comment, aData.Id]);
  UpdateSql(GetDataLinkPath, aSQL);
end;

procedure TMainForm.Sb_DeleteClick(Sender: TObject);
begin
  if LV_Orders.ItemCount = 0 then
  begin
    ErrorDlg('Список пустий!');
    Exit;
  end;

  if WarningDlgYN('Видалити запис?') then
  begin
    Delete_Order(Get_OrderData(LV_Orders.ItemIndex).Id);
    Fill_OrdersView;
  end;
end;

procedure TMainForm.Sb_SearchClick(Sender: TObject);
begin
  Search_OrderNo;
end;

procedure TMainForm.Search_OrderNo;
var I: Integer;
begin
  for I := 0 to LV_Orders.ItemCount - 1 do
  if Get_OrderData(I).OrderNo = Trim(Edt_OrderNo.Text) then
  begin
    LV_Orders.ItemIndex := I;
    Break;
  end;
end;

end.
