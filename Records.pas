unit Records;

interface

 type
   TCustomer = record
     id : string[20];
     name : string[35];
     town  : string[20];
     ticket : word;
     load : single
   end;

 type
  TRoute = record
    id : string[10];
    name : string[30];
    date : string[10];
    customerNum : Byte;
    customers : TArray<TCustomer>;
    load : Single;
  end;

  type
    TWantedRoutes = record
      strRoutes: string;
      arrRoutes: Array of String;
  end;
implementation

end.
