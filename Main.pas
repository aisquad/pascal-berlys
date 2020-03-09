unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.RegularExpressions,
  System.Variants, System.Generics.Collections, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Files, Records;

type
  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Memo1: TMemo;
    edFilename: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    ListBox3: TListBox;
    ListBox4: TListBox;
    ListBox5: TListBox;
    ListBox6: TListBox;
    lblData: TLabel;
    edRoutes: TEdit;
    edDate: TEdit;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    function getWantedRoutes(): TWantedRoutes;
    procedure edRoutesKeyPress(Sender: TObject; Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.edRoutesKeyPress(Sender: TObject; Key: Char);
begin
  if not (Key in [#8, '0'..'9']) then
    begin
      ShowMessage('Invalid key: ' + Key);
      Key := #0;
    end;
end;

procedure TForm2.Button1Click(Sender: TObject);
var
  dctRoutes: TDictionary<String, TRoute>;
  readFile: TReadFile;

begin
  readFile := TReadFile.Create(edFilename.Text);
  try
    readFile.LoadFile;
    Memo1.Text := readFile.getText;
    edDate.Text := readFile.getDate;
    dctRoutes := readFile.getRoutes;
  finally
    readFile.Free;
  end;
end;


function TForm2.getWantedRoutes(): TWantedRoutes;
var
  arrRoutes : TArray<String>;
  strRoute, strRoutes : String;
  rcdRoutes : TWantedRoutes;
  i, j: Integer;
begin
      if Length(edRoutes.Text) = 0 then
        begin
          rcdRoutes.strRoutes := '';
          rcdRoutes.arrRoutes := [];
        end
      else
        begin
          strRoutes := edRoutes.Text;
          strRoutes := strRoutes.Trim;
          arrRoutes := strRoutes.Split([' ']);
          strRoutes := '';
          setLength(rcdRoutes.arrRoutes, Length(arrRoutes));
          j := 0;
          if Length(arrRoutes) > 1 then
            begin
              for i := 0 to High(arrRoutes) - 1 do
                begin
                   strRoute := arrRoutes[i].Trim;
                   if strRoute = '' then continue;
                   strRoutes.Insert(strRoutes.Length, strRoute + ', ');
                   rcdRoutes.arrRoutes[j] := strRoute;
                   j := j + 1;
                end;
              strRoutes := strRoutes.TrimRight([',', ' ']);
              strRoutes.Insert(strRoutes.Length, ' i ' + arrRoutes[High(arrRoutes)]);
              rcdRoutes.strRoutes := strRoutes;
           end
          else
            begin
              strRoutes := edRoutes.Text;
              strRoutes := strRoutes.Trim;
              rcdRoutes.strRoutes := strRoutes;
              rcdRoutes.arrRoutes := [strRoutes];
            end;
        end;
        Result := rcdRoutes
end;

procedure TForm2.Button2Click(Sender: TObject);
var
  rcdRoutes : TWantedRoutes;

begin
   rcdRoutes := self.getWantedRoutes();
   ShowMessage('Rutes: '+ rcdRoutes.strRoutes);
end;

end.
