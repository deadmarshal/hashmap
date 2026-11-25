GENERIC INTERFACE HashMap(KeyInt,ValueInt);

EXCEPTION NOT_FOUND;

CONST
  Brand = "HashMap(" & KeyInt.Brand & "," & ValueInt.Brand & ")";
  
TYPE
  T <: REFANY;
  KeyToTextProc = PROCEDURE(Key:KeyInt.T):TEXT;
  ValueToTextProc = PROCEDURE(Value:ValueInt.T):TEXT;
  
PROCEDURE Create(BucketCount:CARDINAL := 16;
                 LoadFactor:LONGREAL := 0.75D0):T;
PROCEDURE Exists(HashMap:T;
                 Key:KeyInt.T):BOOLEAN;
PROCEDURE Get(HashMap:T;
              Key:KeyInt.T):ValueInt.T RAISES{NOT_FOUND};
PROCEDURE Insert(HashMap:T;
                 Key:KeyInt.T;
                 Value:ValueInt.T);
PROCEDURE Delete(HashMap:T;
                 Key:KeyInt.T):BOOLEAN;
PROCEDURE Update(HashMap:T;
                 Key:KeyInt.T;
                 Value:ValueInt.T):BOOLEAN;
PROCEDURE Size(HashMap:T):CARDINAL;
PROCEDURE Keys(HashMap:T):REF ARRAY OF KeyInt.T;
PROCEDURE Values(HashMap:T):REF ARRAY OF ValueInt.T;
PROCEDURE ToText(HashMap:T;
                 KtoText:KeyToTextProc;
                 VtoText:ValueToTextProc):TEXT;

END HashMap.

