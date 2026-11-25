GENERIC MODULE HashMap(KeyInt,ValueInt,Entry,BucketSeq,BucketSeqSeq);

IMPORT Fmt;

REVEAL T = BRANDED Brand REF RECORD
  LoadFactor:LONGREAL;
  Size,MinBuckets:CARDINAL;
  Buckets:BucketSeqSeq.T;
END;

PROCEDURE Create(BucketCount:CARDINAL := 16;
                 LoadFactor:LONGREAL := 0.75D0):T =
  VAR Ret:T;
  BEGIN
    IF BucketCount < 1 THEN BucketCount := 1 END;

    Ret := NEW(T,MinBuckets := BucketCount,
               LoadFactor := LoadFactor);

    Ret.Buckets := NEW(BucketSeqSeq.T).init(BucketCount);
    
    FOR I := 0 TO BucketCount-1 DO
      Ret.Buckets.addhi(NEW(BucketSeq.T).init());
    END;
    
    RETURN Ret
  END Create;

PROCEDURE Exists(HashMap:T;
                 Key:KeyInt.T):BOOLEAN =
  VAR
    B := BucketFor(HashMap,Key);
    E:Entry.T;
  BEGIN
    FOR I := 0 TO B.size()-1 DO
      E := B.get(I);
      IF KeyInt.Compare(E.Key,Key) = 0 THEN RETURN TRUE END
    END;
    RETURN FALSE
  END Exists;
  
PROCEDURE Get(HashMap:T;
              Key:KeyInt.T):ValueInt.T RAISES{NOT_FOUND} =
  VAR
    B := BucketFor(HashMap,Key);
    E:Entry.T;
  BEGIN
    FOR I := 0 TO B.size()-1 DO
      E := B.get(I);
      IF KeyInt.Compare(E.Key,Key) = 0 THEN RETURN E.Value END
    END;
    RAISE NOT_FOUND
  END Get;

PROCEDURE Insert(HashMap:T;
                 Key:KeyInt.T;
                 Value:ValueInt.T) =
  VAR
    B := BucketFor(HashMap,Key);
    E:Entry.T;
  BEGIN
    FOR I := 0 TO B.size()-1 DO
      E := B.get(I);
      IF KeyInt.Compare(E.Key,Key) = 0 THEN
        E.Value := Value;
        B.put(I,E);
        RETURN
      END
    END;
    B.addhi(Entry.T{Key,Value});
    INC(HashMap.Size);

    (* Grow the table when it gets too full: *)
    IF FLOAT(HashMap.Size,LONGREAL) / FLOAT(HashMap.Buckets.size(),LONGREAL)
      > HashMap.LoadFactor THEN
      Resize(HashMap,HashMap.Buckets.size() * 2)
    END
  END Insert;

PROCEDURE Delete(HashMap:T;
                 Key:KeyInt.T):BOOLEAN =
  VAR
    B := BucketFor(HashMap,Key);
    E:Entry.T;
  BEGIN
    FOR I := 0 TO B.size()-1 DO
      E := B.get(I);
      IF KeyInt.Compare(E.Key,Key) = 0 THEN
        B.put(I,B.get(B.size()-1));
        EVAL B.remhi();
        DEC(HashMap.Size);
        MaybeShrink(HashMap);
        RETURN TRUE;
      END;
    END;
    RETURN FALSE
  END Delete;

PROCEDURE Update(HashMap:T;
                 Key:KeyInt.T;
                 Value:ValueInt.T):BOOLEAN =
  VAR
    B := BucketFor(HashMap,Key);
    E:Entry.T;
  BEGIN
    FOR I := 0 TO B.size()-1 DO
      E := B.get(I);
      IF KeyInt.Compare(E.Key,Key) = 0 THEN
        E.Value := Value;
        B.put(I,E);
        RETURN TRUE
      END
    END;
    RETURN FALSE
  END Update;

PROCEDURE Size(HashMap:T):CARDINAL =
  BEGIN
    RETURN HashMap.Size
  END Size;

PROCEDURE Keys(HashMap:T):REF ARRAY OF KeyInt.T =
VAR
  Ret := NEW(REF ARRAY OF KeyInt.T,HashMap.Size);
  Next := 0;
  B:BucketSeq.T;
BEGIN
  FOR I := 0 TO HashMap.Buckets.size()-1 DO
    B := HashMap.Buckets.get(I);
    FOR J := 0 TO B.size()-1 DO
      Ret[Next] := B.get(J).Key;
      INC(Next)
    END
  END;
  RETURN Ret
END Keys;
  
PROCEDURE Values(HashMap:T):REF ARRAY OF ValueInt.T =
VAR
  Ret := NEW(REF ARRAY OF ValueInt.T,HashMap.Size);
  Next := 0;
  B:BucketSeq.T;
BEGIN
  FOR I := 0 TO HashMap.Buckets.size()-1 DO
    B := HashMap.Buckets.get(I);
    FOR J := 0 TO B.size()-1 DO
      Ret[Next] := B.get(J).Value;
      INC(Next)
    END
  END;
  RETURN Ret
END Values;

PROCEDURE ToText(HashMap:T;
                 KtoText:KeyToTextProc;
                 VtoText:ValueToTextProc):TEXT =
  VAR
    Ret:TEXT := "{";
    First := TRUE;
    B:BucketSeq.T;
    E:Entry.T;
  BEGIN
    FOR I := 0 TO HashMap.Buckets.size()-1 DO
      B := HashMap.Buckets.get(I);
      FOR J := 0 TO B.size()-1 DO
        E := B.get(J);
        IF NOT First THEN Ret := Ret & ", " END;
        First := FALSE;
        Ret := Ret & Fmt.F("%s => %s",
                           KtoText(E.Key),
                           VtoText(E.Value));
      END
    END;
    Ret := Ret & "}";
    RETURN Ret
  END ToText;

  (* Private: *)
PROCEDURE BucketFor(HashMap:T;
                    Key:KeyInt.T):BucketSeq.T =
  BEGIN
    RETURN HashMap.Buckets.get(KeyInt.Hash(Key) MOD
    HashMap.Buckets.size())
  END BucketFor;

PROCEDURE Resize(HashMap:T;
                 NewBucketCount:CARDINAL) =
  VAR
    NewBuckets:BucketSeqSeq.T;
    B:BucketSeq.T;
    E:Entry.T;
    Index:CARDINAL;
  BEGIN
    (* 1. Build the new, empty bucket array: *)
    NewBuckets := NEW(BucketSeqSeq.T).init(NewBucketCount);

    FOR I := 0 TO NewBucketCount-1 DO
      B := NEW(BucketSeq.T).init();
      NewBuckets.addhi(B)
    END;

    (* 2. Move every entry to its new bucket: *)
    FOR I := 0 TO HashMap.Buckets.size()-1 DO
      B := HashMap.Buckets.get(I);
      FOR J := 0 TO B.size()-1 DO
        E := B.get(J);
        Index := KeyInt.Hash(E.Key) MOD NewBucketCount;
        NewBuckets.get(Index).addhi(E);
      END
    END;
    HashMap.Buckets := NewBuckets
  END Resize;

PROCEDURE MaybeShrink(HashMap:T) =
  VAR
    N := HashMap.Buckets.size();
    Half := N DIV 2;
    ShrinkBelow:LONGREAL;
  BEGIN
    IF Half < HashMap.MinBuckets THEN RETURN END;
    ShrinkBelow := HashMap.LoadFactor / 4.0D0;
    IF FLOAT(HashMap.Size,LONGREAL) / FLOAT(N,LONGREAL) < ShrinkBelow THEN
      Resize(HashMap,Half)
    END
  END MaybeShrink;

BEGIN  
END HashMap.

