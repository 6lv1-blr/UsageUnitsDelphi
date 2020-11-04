unit uUsageUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.ImageList, Vcl.ImgList,
  Vcl.Buttons, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TfUsageUnit = class(TForm)
    MemoDoc: TMemo;
    btnCherche: TButton;
    eRepertoirePas: TLabeledEdit;
    eRepertoireDcu: TLabeledEdit;
    MemoListe: TMemo;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ImageList1: TImageList;
    FileOpenDialog1: TFileOpenDialog;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure btnChercheClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    SlFichier, SlUnitPas, SlUnitDcu: TStringList;

    Procedure ParcoursRepertoireRecursif(Repertoire, MasqueFichier: String);
  end;

type
  { Comme la structure TSearchrec n'est pas utilisable tel quel,
    on utilise une classe pour l'emballer }
  TSearchRecObj = class(TObject)
    SR: TSearchRec;
    Directory: String;
  end;

var
  fUsageUnit: TfUsageUnit;

implementation

{$R *.dfm}


procedure TfUsageUnit.ParcoursRepertoireRecursif(Repertoire, MasqueFichier: String);
var
  SR: TSearchRec;
  SrObj: TSearchRecObj;
begin
  if FindFirst(Repertoire + '\' + MasqueFichier, faAnyFile - faDirectory, SR) = 0 then
    begin
      repeat
        // Créer un wrapper de TSearchRec pour
        // chaque fichier trouvé
        SrObj := TSearchRecObj.Create;
        SrObj.SR := SR;
        SrObj.Directory := Repertoire;
        // Ajout à la liste
        // DateTimeToStr(FileDateToDateTime(Sr.Time))

        SlFichier.AddObject(SR.Name, SrObj);
      until FindNext(SR) <> 0;
      FindClose(SR);
    end;
  if FindFirst(Repertoire + '\*', faDirectory, SR) = 0 then
    begin
      repeat
        if (SR.Attr And faDirectory) <> 0 then
          begin
            // Dans le cas d'un sous-repertoire on appelle la même procédure
            if (SR.Name <> '.') and (SR.Name <> '..') then
              begin
                ParcoursRepertoireRecursif(Repertoire + SR.FindData.cFileName + '\', MasqueFichier)
                // Sinon on compte simplement le fichier
              end;
          end;
      until FindNext(SR) <> 0;
      FindClose(SR);
    end;

end;

procedure TfUsageUnit.BitBtn1Click(Sender: TObject);
begin
  if FileOpenDialog1.Execute then
    eRepertoirePas.Text := FileOpenDialog1.FileName
end;

procedure TfUsageUnit.BitBtn2Click(Sender: TObject);
begin
  if FileOpenDialog1.Execute then
    eRepertoirePas.Text := FileOpenDialog1.FileName

end;

procedure TfUsageUnit.btnChercheClick(Sender: TObject);
var
  i: Integer;
  IndexFichier: Integer;
begin
  inherited;
  SlFichier := TStringList.Create;
  SlUnitPas := TStringList.Create;
  SlUnitDcu := TStringList.Create;
  ParcoursRepertoireRecursif(eRepertoirePas.Text + '\', '*.pas');
  SlUnitPas.Assign(SlFichier);
  SlFichier.Clear;
  if eRepertoireDcu.Text = '' then
    eRepertoireDcu.Text := eRepertoirePas.Text;
  ParcoursRepertoireRecursif(eRepertoireDcu.Text + '\', '*.dcu');
  SlUnitDcu.Assign(SlFichier);
  SlUnitPas.SaveToFile(ExtractFilePath(Application.ExeName) + '\' + 'UnitpasList.txt');
  SlUnitDcu.SaveToFile(ExtractFilePath(Application.ExeName) + '\' + 'UnitdcuList.txt');
  // ShowMessage(SlUnitPas.CommaText);
  // ShowMessage(SlUnitDcu.CommaText);
  SlFichier.Clear;
  for i := 0 to SlUnitPas.Count - 1 do
    begin
      SlUnitDcu.CaseSensitive := false;
      // find ne marche pas sur liste non trié
      // on doit utilisé indexof
      // https://stackoverflow.com/questions/44400854/delphi-tstringlist-find-method-cannot-find-item
      if SlUnitDcu.IndexOf(changefileext(SlUnitPas[i], '.dcu')) = -1 then
        begin
          // unité non nécessaire
          SlFichier.Add(TSearchRecObj(SlUnitPas.Objects[i]).Directory + SlUnitPas[i]);
        end;
    end;
  SlFichier.Delimiter := #13;

  MemoListe.Text := 'Liste des ' + SlFichier.Count.ToString + ' unités non compilées' + #13 + SlFichier.DelimitedText.Replace(#13, #13 + #10);

  SlFichier.Free;
  SlUnitDcu.Free;
  SlUnitPas.Free;
end;

end.
