MODULE Main;

IMPORT SIO,Fmt;
FROM StableError IMPORT Halt;
IMPORT TextIntHashMap AS TIHM;

VAR
  H := TIHM.Create();
  A := ARRAY[0..4] OF TEXT{"John","Jack","Jill","Fox","Marry"};
  B:BOOLEAN;
  Val:INTEGER;
  KeysArr:REF ARRAY OF TEXT;
  ValuesArr:REF ARRAY OF INTEGER;

  (* Identity procedure: *)
PROCEDURE StringToText(S:TEXT):TEXT =
  BEGIN
    RETURN S
  END StringToText;

PROCEDURE IntToText(I:INTEGER):TEXT =
  BEGIN
    RETURN Fmt.Int(I)
  END IntToText;

PROCEDURE PrintHashMap(H:TIHM.T) =
  BEGIN
    SIO.PutText(TIHM.ToText(H,StringToText,IntToText) & "\n");
  END PrintHashMap;
  
BEGIN
  SIO.PutText("At first the hashmap is empty:\n");
  PrintHashMap(H);
  
  SIO.PutText("\nInserting a bunch of names into the hashmap:\n");
  FOR I := FIRST(A) TO LAST(A) DO
    TIHM.Insert(H,A[I],I)
  END;

  PrintHashMap(H);
  
  SIO.PutText("\nDeleting the key \"Jill\" from the hashmap:\n");
  
  B := TIHM.Delete(H,"Jill");
  IF NOT B THEN
    Halt("Couldn't delete Jill" & "\n")
  END;

  PrintHashMap(H);
  
  SIO.PutText("\nDoes \"John\" exists in the hashmap?\n");
  IF TIHM.Exists(H,"John") THEN
    SIO.PutText("YES\n");
  ELSE
    SIO.PutText("NO\n");
  END;

  SIO.PutText("\nUpdating the \"Fox\" key's value to 10: \n");
  B := TIHM.Update(H,"Fox",10);
  IF B THEN
    SIO.PutText("\nUpdating was successful!\n");
  ELSE
    Halt("Updating FAILED!");
  END;
  
  PrintHashMap(H);

  SIO.PutText("\nGetting the value of the key \"Jack\":\n");
  TRY
    Val := TIHM.Get(H,"Jack");
    SIO.PutText(Fmt.F("Value is: %s\n",Fmt.Int(Val)));
  EXCEPT
    TIHM.NOT_FOUND => Halt("Key was not found!")
  END;

  SIO.PutText("\nHashmap's size: \n");
  SIO.PutInt(TIHM.Size(H));
  SIO.Nl();
  
  SIO.PutText("\nGetting and printing all the hashmap's keys:\n");
  KeysArr := TIHM.Keys(H);
  
  FOR I := FIRST(KeysArr^) TO LAST(KeysArr^) DO
    SIO.PutText(KeysArr[I] & " ");
  END;
  SIO.Nl();
  
  SIO.PutText("\nGetting and printing all the hashmap's values:\n");
  ValuesArr := TIHM.Values(H);
  
  FOR I := FIRST(ValuesArr^) TO LAST(ValuesArr^) DO
    SIO.PutInt(ValuesArr[I]);
    SIO.PutChar(' ')
  END;
  SIO.Nl();  
END Main.

