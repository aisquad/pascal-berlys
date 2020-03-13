unit Files;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, Vcl.Dialogs,
  System.RegularExpressions, System.Variants, System.Classes, System.Generics.Collections, Records;

  type
    TReadFile = class(TObject)
    var
      stFilename: String;
      stText: String;
    private
    public
      constructor Create(const Filename: String = '');
      procedure LoadFile();
      function getDate(): String;
      function getText(): String;
      function getRoutes(): TDictionary<String, TRoute>;
      function fetchCustomers(const customers : String): TArray<TCustomer>;
      function getFisrtFile(): TSearchRec;
    end;

implementation

constructor TReadFile.Create(const Filename: String = '');
begin
    self.stFilename := Filename;
    self.stText := '';
end;

procedure TReadFile.LoadFile();
var
  LStrings: TStringList;

begin
    LStrings := TStringList.Create;
    try
      LStrings.Loadfromfile(self.stFileName, TEncoding.UTF8);
      self.stText := LStrings.Text;
    finally
      FreeAndNil(LStrings);
    end;
end;

function TReadFile.getDate() : String;
var
  strDate : String;
  RegExp  : TRegEx;
  Match   : TMatch;
begin
  RegExp.Create('Día de entrega :    (?<date>\d{2}\.\d{2}\.\d{4})');
  if Regexp.IsMatch(self.stText) then
    begin
      Match := Regexp.Match(stText);
      strDate := Match.Groups['date'].Value;
      Result := strDate.Replace('.', '/');
    end;
end;

function TReadFile.fetchCustomers(const customers: String) : TArray<TCustomer>;
var
  RegExp : TRegEx;
  Match : TMatch;
  Matches : TMatchCollection;
  rcdCustomer : TCustomer;
  tmpCustomer : TCustomer;
  arrCustomers : TArray<TCustomer>;
  dctCustomers : TDictionary<String, TCustomer>;
  customerID : String;
  i: Integer;
begin
  Regexp := TRegEx.Create(
    '(?<customerID>\d{10}) (?<customerName>.{35}) (?<town>.{20}) ' +
    '(?<ordNum>.{10}) (?<vol>.{11})(?: (?<UM>.{2,3}))?'
  );
  Match := RegExp.Match(customers);
  dctCustomers := TDictionary<String, TCustomer>.Create;
  if Match.Success then
  begin
    Matches := Regexp.Matches(customers);
    for i := 0 to Matches.Count - 1 do
    begin
      customerID := Matches[i].Groups['customerID'].Value.Trim;
      rcdCustomer.id := customerID;
      rcdCustomer.name := Matches[i].Groups['customerName'].Value.Trim;
      rcdCustomer.town := Matches[i].Groups['town'].Value.Trim;
      rcdCustomer.ticket := Matches[i].Groups['ordNum'].Value.ToInteger;
      rcdCustomer.load := Matches[i].Groups['vol'].Value.Replace('.', '').ToSingle;
      if dctCustomers.ContainsKey(customerID) then
        begin
          tmpCustomer := dctCustomers[customerID];
          tmpCustomer.load := tmpCustomer.load + rcdCustomer.load;
          dctCustomers.AddOrSetValue(customerID, tmpCustomer);
        end
      else
        begin
          dctCustomers.Add(customerID, rcdCustomer);
        end;
    end;
  end;
  setLength(arrCustomers, dctCustomers.Keys.Count);
  i := 0;
  for customerID in dctCustomers.Keys do
    begin
      arrCustomers[i] := dctCustomers[customerID];
      i := i + 1;
    end;
  Result := arrCustomers;
end;

function TReadFile.getRoutes;
var
  strCustomers : String;
  RegExp  : TRegEx;
  Matches : TMatchCollection;
  dctRoutes : TDictionary<String, TRoute>;
  arrCustomers : TArray<TCustomer>;
  routeID : String;
  rcdRoute : TRoute;
  strVolume : String;
  I: Integer;
begin
  RegExp := TRegEx.Create(
    '25\s+BERLYS ALIMENTACION S\.A\.U\s+[\d:]+\s+[\d.]+\s+Volumen de pedidos de la ruta :\s+' +
    '(?<routeID>\d+)\s+25\s+(?<routeName>[^\n]+)\s+Día de entrega :\s+(?<unloadDate>[^ ]{10})(?<customers>.+?)' +
    'NUMERO DE CLIENTES\s+:\s+(?<custNum>\d+).+?' +
    'SUMA VOLUMEN POR RUTA\s+:\s+(?<volAmt>[\d,.]+) (?<um1>(?:PVL|KG)).+?' +
    'SUMA KG POR RUTA\s+:\s+(?<weightAmt>[\d,.]+) (?<um2>(?:PVL|KG)).+?' +
    '(?:CAPACIDAD TOTAL CAMIÓN\s+:\s+(?<truckCap>[\d,.]+) (?<um3>(?:PVL|KG)))?',
    [TRegExOption.roSingleLine]
  );
  if RegExp.IsMatch(self.stText) then
    begin
      Matches := RegExp.Matches(self.stText);
      dctRoutes := TDictionary<String, TRoute>.Create;
      for i := 0 to Matches.Count - 1 do
        begin
          routeID := Matches[i].Groups['routeID'].Value;
          rcdRoute.id := routeID;
          rcdRoute.name := Matches[i].Groups['routeName'].Value;
          rcdRoute.customerNum := Matches[i].Groups['custNum'].Value.ToInteger;
          strVolume := Matches[i].Groups['volAmt'].Value.Replace('.', '');
          rcdRoute.load := strVolume.ToSingle;
          strCustomers := Matches[i].Groups['customers'].Value;
          arrCustomers := fetchCustomers(strCustomers);
          rcdRoute.customers := arrCustomers;
          dctRoutes.Add(routeID, rcdRoute);
        end;
       Result := dctRoutes;
    end;
end;

function TreadFile.getText(): String;
begin
  Result := self.stText;
end;

function TreadFile.getFisrtFile(): TSearchRec;
var
  searchResult : TSearchRec;
begin
  // Try to find regular files matching Unit1.d* in the current dir
  if FindFirst('.\attachments\*.txt', faAnyFile, searchResult) = 0 then
  begin
    repeat
    until FindNext(searchResult) <> 0 ;
  end;
    searchResult.Name := Format('.\attachments\%s', [searchResult.Name]);
    Result := searchResult;
    // Must free up resources used by these successful finds
    FindClose(searchResult);
end;
end.
