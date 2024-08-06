program TestProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  Mainfrm in 'Mainfrm.pas' {MainForm},
  CustomerFrm in 'CustomerFrm.pas' {CustomerForm},
  UnitCustomerEdit in 'UnitCustomerEdit.pas' {CustomerEditForm},
  UnProcedure in 'UnProcedure.pas',
  UnitOrderEdit in 'UnitOrderEdit.pas' {OrderEditForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
