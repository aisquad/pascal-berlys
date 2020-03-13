unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.RegularExpressions,
  System.Variants, System.Generics.Collections, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Files, Records, Mail,
  Vcl.ComCtrls, DateUtils;

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
    lbxCustomers6: TListBox;
    edtEmailAdress: TEdit;
    edtEmailpassword: TEdit;
    btnMail: TButton;
    cbxMailServer: TComboBoxEx;
    edtFolder: TEdit;
    edtDateAfter: TEdit;
    edtDateBefore: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    function getWantedRoutes(name: String = 'edtWantedRoutes'): TWantedRoutes;
    procedure FillListBoxes(dctRoutes: TDictionary<String, TRoute>);
    procedure lbxCustomersDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lbxCustomersDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure recalculateItems(lbxTarget: TListBox);
    procedure btnMailClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtSenderDblClick(Sender: TObject);
    procedure edtSenderExit(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.btnMailClick(Sender: TObject);
var
  strUser, strPassword, strServer, strFolder : String;
  mail : GetMail;
begin
  strUser := edtEmailAdress.Text;
  strPassword := edtEmailpassword.Text;
  strServer := cbxMailServer.Items[cbxMailServer.ItemIndex];
  strFolder := edtFolder.Text;
  mail := GetMail.Create;
  if (strUser <> '') and (strPassword <> '') and (strServer <> '') then
    begin
        mail.RetrieveMail(strServer, strUser, strPassword, strFolder);
    end;
end;

procedure TForm2.Button1Click(Sender: TObject);
var
  dctRoutes: TDictionary<String, TRoute>;
  lines, routeID, date : String;
  data : TReadFile;
  route : TRoute;
  customer : TCustomer;
  i, j: Integer;
  routeLoad, absoluteLoad: Single;
  customers : word;
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
  absoluteLoad := 0.0;
  customers := 0;
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
          customers := customers + 1
        end;
        absoluteLoad := absoluteLoad + routeLoad;
        lines := lines + Format('%68.3f\n\n', [routeLoad]);
      end;
  end;
  {tab: [^I, #9], lf: [^J, #10], cr: [^M, #13]}
  lines := lines + Format('%41s %3d %11s %10.3f', ['clients:', customers, 'Total PVL:', absoluteLoad]);
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


procedure TForm2.lbxCustomersDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
    Accept := True;
end;

procedure TForm2.lbxCustomersDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  lbxSource, lbxTarget : TListBox;
begin
  if Source is TListBox then
  begin
    lbxSource := TListBox(Source);
    lbxTarget := TListBox(Sender);
    if(lbxSource.ItemIndex <> -1) then
    begin
     lbxTarget.Items.Add(lbxSource.Items[lbxSource.ItemIndex]);
     lbxSource.Items.Delete(lbxSource.ItemIndex);
     recalculateItems(lbxTarget);
     recalculateItems(lbxSource);
    end;
  end;

end;

procedure TForm2.RecalculateItems(lbxTarget : TListBox);
var
  item: String;
  pvl : Single;
  regexp : TRegEx;
  index : shortint;
  lblObject : TLabel;

begin
  index := ShortInt(
    String(lbxTarget.Name).SubString(Length(lbxTarget.Name)-1, 1).ToInteger()
  );
  regexp := TRegEx.Create('\s+([\d,]+)');
  pvl := 0.0;
  for item in lbxTarget.Items do
  begin
    pvl := pvl + regexp.Match(item).Groups[1].Value.ToSingle;
  end;
  lblObject := TLabel(FindComponent(Format('lblPVL%d', [index])));
  lblObject.Caption := Format('%.3f', [pvl]);
  lblObject := TLabel(FindComponent(Format('lblCustomers%d', [index])));
  lblObject.Caption := lbxTarget.Items.Count.ToString;
end;


procedure TForm2.Button2Click(Sender: TObject);
var
  rcdRoutes : TWantedRoutes;
begin
   rcdRoutes := self.getWantedRoutes();
   if Length(rcdRoutes.arrRoutes) = 0 then
   begin
     edtWantedRoutes.Text := '678 679 680 681 682 686 688 696';
     Button2Click(Sender);
     Exit;
   end;
   ShowMessage('Rutes: '+ rcdRoutes.strRoutes);
end;


procedure TForm2.edtSenderDblClick(Sender: TObject);
var
  edtSender : TEdit;
begin
  edtSender := TEdit(Sender);
  if edtSender.ReadOnly = true then
    begin
      edtSender.ReadOnly := false;
      edtSender.Color := clWindow;
      end
    else
      begin
        edtSender.ReadOnly := true;
        edtSender.Color := clBtnFace;
      end;
end;


procedure TForm2.edtSenderExit(Sender: TObject);
var
  edtSender : TEdit;
begin
  edtSender := TEdit(Sender);
  edtSender.ReadOnly := true;
  edtSender.Color := clBtnFace;
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
    currentListBox := TLIstBox(FindComponent(Format('lbxCustomers%d', [i])));
    currentLabel1 := TLabel(FindComponent(Format('lblCustomers%d', [i])));
    currentLabel2 := TLabel(FindComponent(Format('lblPVL%d', [i])));
    if currentTEdit.Text <> '' then
      begin
        arrWantedRoutes := TArray<String>(self.getWantedRoutes(strName).arrRoutes);
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
      end
    else
      begin
        currentListBox.Clear;
        currentLabel1.Caption := '';
        currentLabel2.Caption := '';
      end;

  end;
end;


procedure TForm2.FormCreate(Sender: TObject);
var
  strDateSince, strDateBefore : String;
begin
  cbxMailServer.ItemIndex := 0;
  edtDateAfter.Text := DateTimeToStr(IncDay(Now, -10));
  edtDateBefore.Text := DateTimeToStr(Now);
end;

end.
