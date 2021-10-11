unit Unit1;

interface

uses
   Windows, StdCtrls, Controls, ExtCtrls, Graphics, Classes, Forms, SysUtils,
  jpeg;


type
  TForm1 = class(TForm)
    Btn_Scanner: TButton;
    Image1: TImage;
    Btn_Trier: TButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure Btn_ScannerClick(Sender: TObject);
    procedure Btn_TrierClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}    

var
    CoulList: TList; // La liste de toutes les couleurs présentes dans le Bitmap.
    NbreList: TList; // La liste du nombre de pixels de chaque couleur. Les 2 listes
                     // étant synchronisées, bien sûr.

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////  PROCEDURES   //////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

procedure Scanner(Src : TBitmap);
  {Pour scanner le Bitmap.}
  type
    pRGBTripleArray = ^TRGBTripleArray;
    TRGBTripleArray = ARRAY[0..32767] OF TRGBTriple;//TRGBTriple est codé dans Windows.pas.
  var
      x,y,NbrePix,Index : Integer;
      Row:  pRGBTripleArray;
      Couleur : TColor;
  begin                         
  if (not assigned(src)) then exit;
  if (not assigned(CoulList)) then CoulList := TList.Create;
  if (not assigned(NbreList)) then NbreList := TList.Create;
  Src.PixelFormat := pf24bit;
  for Y := 0 to Src.Height-1 do begin
      Row := Src.ScanLine[y];
      for X := 0 to Src.Width-1 do begin
        Couleur := RGB(Row[x].rgbtRed,Row[x].rgbtGreen,Row[x].rgbtBlue);//La couleur de chaque pixel.
        if CoulList.IndexOf(Pointer(Couleur))= -1 then begin//Si la couleur n'est pas encore référencée dans la liste..
          CoulList.Add(Pointer(Couleur));//on l'ajoute et ..
          NbreList.Add(Pointer(1)); end  //on ajoute un élément dans la liste des nombres de pixels.
        else begin                       //Sinon, on incrémente simplement le nombre de pixels de cette couleur.
          Index           := CoulList.IndexOf(Pointer(Couleur));
          NbrePix         := Integer(NbreList[Index]) + 1;
          NbreList[Index] := Pointer(NbrePix);
        end;
      end;
  end;
end;

procedure SortList(CLst,NLst:TList);
  {Pour trier les listes par ordre décroissant.
   La méthode 'Sort' de la classe TList est inadaptée ici.}
var
 i, n : integer;
begin
  if CLst.Count<2 then Exit;
  for i:=1 to NLst.Count-1 do
    for n := 0 to i-1 do
      if Integer(NLst[i])>Integer(NLst[n]) then
        begin
          NLst.Move(i,n);
          CLst.Move(i,n);
          Break;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////  CODE   /////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Btn_ScannerClick(Sender: TObject);
  var
      i : Integer;
      UnPanel : TPanel;
  begin
  Scanner(Image1.Picture.Bitmap);
  for i := 0 to CoulList.Count-1 do begin
    UnPanel := TPanel.Create(self);
    UnPanel.Parent := Form1;
    UnPanel.Height := 40;
    UnPanel.Width := 40;
    UnPanel.Top := 210;
    UnPanel.Left := 258+i*40;
    UnPanel.Color := Integer(CoulList[i]);
    UnPanel.BevelOuter := bvNone;
    UnPanel.Caption := IntToStr(Integer(NbreList[i]));
  end;
  Btn_Scanner.Enabled := false;
  Btn_Trier.Enabled := true;
end;

procedure TForm1.Btn_TrierClick(Sender: TObject);
var
  i : Integer;
  UnPanel : TPanel;
begin
 SortList(CoulList,NbreList);
 for i := 0 to CoulList.Count-1 do
  begin
    UnPanel := TPanel.Create(self);
    UnPanel.Parent := Form1;
    UnPanel.Height := 40;
    UnPanel.Width := 40;
    UnPanel.Top := 260;
    UnPanel.Left := 258+i*40;
    UnPanel.Color := Integer(CoulList[i]);
    UnPanel.BevelOuter := bvNone;
    UnPanel.Caption := IntToStr(Integer(NbreList[i]));
  end;
 Btn_Trier.Enabled := false;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  NbreList.Free;
  CoulList.Free;
end;

end.
