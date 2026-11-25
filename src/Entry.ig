GENERIC INTERFACE Entry(KeyInt,ValueInt);

CONST
  Brand = "Entry(" & KeyInt.Brand & "," & ValueInt.Brand & ")";
  
TYPE
  T = RECORD
    Key:KeyInt.T;
    Value:ValueInt.T;
  END;

END Entry.

