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
    lblPVL1: TLabel;
    lblCustomers1: TLabel;
    lblPVL2: TLabel;
    lblCustomers2: TLabel;
    lblCustomers3: TLabel;
    lblPVL3: TLabel;
    lblCustomers4: TLabel;
    lblPVL4: TLabel;
    lblCustomers6: TLabel;
    lblPVL6: TLabel;
    lblCustomers5: TLabel;
    lblPVL5: TLabel;
    lbxCustomers1: TListBox;
    lbxCustomers2: TListBox;
    lbxCustomers3: TListBox;
    lbxCustomers4: TListBox;
    ListBox5: TListBox;
    lbxCustomers5: TListBox;
    lblData: TLabel;
    edtWantedRoutes: TEdit;
    edDate: TEdit;
    edRoutes1: TEdit;
    edRoutes4: TEdit;
    edRoutes3: TEdit;
    edRoutes2: TEdit;
    edRoutes6: TEdit;
    edRoutes5: TEdit;
    edTruck1: TEdit;
    edDeliverer1: TEdit;
    edDeliverer3: TEdit;
    edTruck3: TEdit;
    edDeliverer5: TEdit;
    edTruck5: TEdit;
    edDeliverer2: TEdit;
    edTruck2: TEdit;
    edDeliverer4: TEdit;
    edTruck4: TEdit;
    edDeliverer6: TEdit;
    edTruck6: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    function getWantedRoutes(name: String = 'edtWantedRoutes'): TWantedRoutes;
    procedure FillListBoxes(dctRoutes: TDictionary<String, TRoute>);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);
var
  dctRoutes: TDictionary<String, TRoute>;
  lines, routeID, date : String;
  data : TReadFile;
  route : TRoute;
  customer : TCustomer;
  i, j: Integer;
  routeLoad: Single;
  wantedRoutes : TArray<String>;

begin
  data := TReadFile.Create(edFilename.Text);
  data.LoadFile;
  date := data.getDate;
  edDate.Text := date;
  Memo1.Hint := date;
  dctRoutes := data.getRoutes;
  wantedRoutes := TArray<String>(self.getWantedRoutes.arrRoutes);
  lines := '';
  for i := 0 to High(wantedRoutes) do
  begin
    routeID := wantedRoutes[i];
    if dctRoutes.ContainsKey(routeID) then
      begin
        route := dctRoutes[routeID];
        lines := lines + Format('Ruta %s\t%s\n', [route.id, route.name]);
        routeLoad := 0.0;
        for j := 0 to High(route.customers) do
        begin
          customer := route.customers[j];
          lines := lines + Format('%2d %-35s %-20s %8.3f\n', [
            j+1, customer.name, customer.town, customer.load
          ]);
          routeLoad := routeLoad + customer.load;
        end;
        lines := lines + Format('%68.3f\n\n', [routeLoad]);
      end;
  end;
  {tab: [^I, #9], lf: [^J, #10], cr: [^M, #13]}
  lines := lines.Replace('\t', #9).Replace('\n', #13#10);
  Memo1.Text := lines;
  data.Free;
  FillListBoxes(dctRoutes);
end;


function TForm2.getWantedRoutes(name: String = 'edtWantedRoutes'): TWantedRoutes;
var
  edtTarget : TEdit;
  arrRoutes : TArray<String>;
  strRoute, strRoutes : String;
  rcdRoutes : TWantedRoutes;
  i, j: Integer;
begin
  edtTarget := TEdit(FindComponent(name));
  if Length(edtTarget.Text) = 0 then
    begin
      rcdRoutes.strRoutes := '';
      rcdRoutes.arrRoutes := [];
    end
  else
    begin
      strRoutes := edtTarget.Text;
      strRoutes := strRoutes.Trim;
      arrRoutes := strRoutes.Split([' ']);
      strRoutes := '';
      setLength(rcdRoutes.arrRoutes, Length(arrRoutes));

      if Length(arrRoutes) > 1 then
        begin
          j := 0;
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
          rcdRoutes.arrRoutes[j] := arrRoutes[High(arrRoutes)];
       end
      else
        begin
          strRoutes := edtTarget.Text;
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
   if Length(rcdRoutes.arrRoutes) = 0 then
   begin
     edtWantedRoutes.Text := '678 679 680 682 686 688 696';
     Button2Click(Sender);
     Exit;
   end;
   ShowMessage('Rutes: '+ rcdRoutes.strRoutes);
end;

procedure TForm2.FillListBoxes(dctRoutes: TDictionary<String, TRoute>);
var
  i : Integer;
  strName : String;
  currentTEdit : TEdit;
  currentListBox : TListBox;
  currentLabel1, currentLabel2 : TLabel;
  arrWantedRoutes : TArray<String>;
  routeID : String;
  currentLoad : Single;
  customer : TCustomer;
  customers : Word;
begin
  for i := 1 to 6 do
  begin
    strName := Format('edRoutes%d', [i]);
    currentTEdit := TEdit(FindComponent(strName));
    if currentTEdit.Text <> '' then
    begin
      arrWantedRoutes := TArray<String>(self.getWantedRoutes(strName).arrRoutes);
      strName := Format('lbxCustomers%d', [i]);
      currentListBox := TLIstBox(FindComponent(strName));
      currentListBox.Clear;
      currentLoad := 0.0;
      customers := 0;
      for routeID in arrWantedRoutes do
        begin
          if dctRoutes.ContainsKey(routeID) then
          begin
            for customer in dctRoutes[routeID].customers do
            begin
              currentListBox.Items.Add(
                Format(
                  '%-35s %8.3f', [
                    customer.name,
                    customer.load
                  ]
                )
              );
              customers := customers + 1;
              currentLoad := currentLoad + customer.load;
            end;
          end;
        end;
      currentLabel1 := TLabel(FindComponent(Format('lblCustomers%d', [i])));
      currentLabel1.Caption := customers.ToString();
      currentLabel2 := TLabel(FindComponent(Format('lblPVL%d', [i])));
      currentLabel2.Caption := Format('%.3f', [currentLoad]);

    end;
  end;
end;

end.
