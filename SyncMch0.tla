---- MODULE SyncMch0 ----
EXTENDS TLC, SyncCtx0, FiniteSets

VARIABLES clntA, svr, clntB, tm

InvClientNone ==
    /\ clntA.Value = -1 => {r \in svr: r.ClientNm = "A"} = {}
    /\ clntB.Value = -1 => {r \in svr: r.ClientNm = "B"} = {}

InvRecA ==
    LET rs == {r \in svr: r.ClientNm = "A"}
    IN /\ rs /= {} => 
          (LET recA == CHOOSE r \in rs: TRUE
          IN /\ recA.Value <= clntA.Value
             /\ recA.Value = clntA.Value => clntA.SyncTime < recA.UpdateTime
             /\ recA.Value < clntA.Value => clntA.SyncTime >= recA.UpdateTime)

InvRecB == 
    LET rs == {r \in svr: r.ClientNm = "B"}
    IN /\ rs /= {} => 
          (LET recB == CHOOSE r \in rs: TRUE
          IN /\ recB.Value <= clntB.Value
             /\ recB.Value = clntB.Value => clntB.SyncTime < recB.UpdateTime
             /\ recB.Value < clntB.Value => clntB.SyncTime >= recB.UpdateTime)
             
InvType ==
    /\ \A r \in svr: r \in SData
    /\ clntA \in CData
    /\ clntB \in CData

Init == 
    /\ clntA = [Value |-> -1, ClientNm |-> "A", SyncTime |-> -1, LastSyncTime |-> -1]
    /\ svr = {}
    /\ clntB = [Value |-> -1, ClientNm |-> "B", SyncTime |-> -1, LastSyncTime |-> -1]
    /\ tm = 0

done == 
    /\ clntA.Value = 2
    /\ clntB.Value = 2
    /\ Cardinality(svr) = 2
    /\ \A d \in svr: d.Value = 2
    /\ UNCHANGED << clntA, clntB, svr, tm >>


\* sync time is used as update time
clntMkRec(nm) == 
    IF nm = "A" /\ clntA.Value = -1
    THEN /\ clntA' = [Value |-> 1, ClientNm |-> nm, SyncTime |-> tm, LastSyncTime |-> 0]
         /\ tm' = tm + 1
         /\ UNCHANGED << svr, clntB >>
    ELSE IF nm = "B" /\ clntB.Value = -1
    THEN /\ clntB' = [Value |-> 1, ClientNm |-> nm, SyncTime |-> tm, LastSyncTime |-> 0]
         /\ tm' = tm + 1
         /\ UNCHANGED << clntA, svr >>
    ELSE UNCHANGED << clntA, svr, clntB, tm >>

clntUpdateRec(nm) == 
    IF nm = "A" /\ clntA.Value /= -1 /\ clntA.Value = 1
    THEN /\ clntA' = [clntA EXCEPT !.Value = 2, !.SyncTime = tm]
         /\ tm' = tm + 1
         /\ UNCHANGED << svr, clntB >>
    ELSE IF nm = "B" /\ clntB.Value /= -1 /\ clntB.Value = 1
    THEN /\ clntB' = [clntB EXCEPT !.Value = 2, !.SyncTime = tm]
         /\ tm' = tm + 1
         /\ UNCHANGED << clntA, svr >>
    ELSE UNCHANGED << clntA, svr, clntB, tm >>

clntSend(clnt) == 
    /\ clnt.Value /= -1
    /\ clnt.SyncTime > clnt.LastSyncTime
    /\ LET matchingRecs == {r \in svr: r.ClientNm = clnt.ClientNm}
       IN IF matchingRecs = {} 
       THEN
            /\ svr' = svr \cup {[
                Value |-> clnt.Value,
                ClientNm |-> clnt.ClientNm,
                CreateTime |-> tm,
                UpdateTime |-> tm
                ]}
            /\ tm' = tm + 1
            /\ UNCHANGED << clntA, clntB >>
        ELSE
            LET matchingRec == CHOOSE r \in matchingRecs: TRUE
            IN CASE matchingRec.Value = clnt.Value ->
                    /\ UNCHANGED << clntA, clntB, svr, tm >>
               [] OTHER ->
                    /\ svr' = {r \in svr : r.ClientNm /= clnt.ClientNm} \cup {[
                        Value |-> clnt.Value,
                        ClientNm |-> clnt.ClientNm,
                        CreateTime |-> matchingRec.CreateTime,
                        UpdateTime |-> tm
                        ]}
                    /\ tm' = tm + 1
                    /\ UNCHANGED << clntA, clntB >>

clntRecvOk(clnt) == 
    /\ {r \in svr: r.ClientNm = clnt.ClientNm} /= {}
    /\ clnt.SyncTime > clnt.LastSyncTime
    /\ (CHOOSE r \in svr: r.ClientNm = clnt.ClientNm).Value = clnt.Value
    /\ LET otherClnt == CHOOSE c \in {clntA, clntB}: c.ClientNm /= clnt.ClientNm
           matchingRec == CHOOSE r \in svr: r.ClientNm = clnt.ClientNm
       IN /\ clnt' = [clnt EXCEPT !.SyncTime = matchingRec.UpdateTime, !.LastSyncTime = matchingRec.UpdateTime]
          /\ tm' = tm + 1
          /\ UNCHANGED << svr, otherClnt >>

Next ==
    \/ \E nm \in {"A", "B"}: clntMkRec(nm)
    \/ \E nm \in {"A", "B"}: clntUpdateRec(nm)
    \/ \E clnt \in {clntA, clntB}: clntSend(clnt)
    \/ \E clnt \in {clntA, clntB}: clntRecvOk(clnt)
    \/ done

Spec == Init /\ [][Next]_<< clntA, svr, clntB, tm >>
====