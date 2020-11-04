program UsageUnit;

uses
  Vcl.Forms,
  uUsageUnit in 'uUsageUnit.pas' {fUsageUnit};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfUsageUnit, fUsageUnit);
  Application.Run;
end.
