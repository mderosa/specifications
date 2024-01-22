--------------------------- MODULE ManufBoardMch0 ---------------------------
EXTENDS ManufBoardCtx0, TLC, Integers

CONSTANTS timeout, pcDepth
VARIABLES timeoutCntr, externalData, stateData, pendingData, pc

\* Invariants
InvInSync == timeoutCntr = None => pendingData = None
InvPendingData == pendingData /= None => timeoutCntr /= None

InvData ==
    /\ externalData >= 0 
    /\ (pendingData = None \/ pendingData > stateData)
    /\ (stateData = None \/ (stateData >= 0 /\ stateData <= externalData))

\* Transition functions 
onLocalRowEdit == 
    /\ pc < pcDepth
    /\ timeoutCntr /= 0
    /\ timeoutCntr' = timeout
    /\ externalData' = externalData + 1
    /\ pc' = pc + 1
    /\ UNCHANGED << stateData, pendingData >>

onChangeLayout ==
    /\ pc < pcDepth
    /\ pc' = pc + 1
    /\ IF pendingData = None
        THEN UNCHANGED << timeoutCntr, stateData, pendingData, externalData >>
        ELSE /\ timeoutCntr' = None
             /\ stateData' = pendingData
             /\ pendingData' = None
             /\ UNCHANGED << externalData >>

onRemoteRowEdit == 
    /\ pc < pcDepth
    /\ timeoutCntr /= 0
    /\ externalData' = externalData + 1
    /\ pc' = pc + 1
    /\ IF timeoutCntr = None
        THEN UNCHANGED << timeoutCntr, stateData, pendingData >>
        ELSE /\ timeoutCntr' = timeoutCntr - 1
             /\ UNCHANGED << stateData, pendingData >>

onApplyPendingData == 
    /\ pc < pcDepth /\ pendingData /= None
    /\ timeoutCntr /= 0
    /\ timeoutCntr' = None
    /\ stateData' = pendingData
    /\ pendingData' = None
    /\ pc' = pc + 1
    /\ UNCHANGED << externalData >>

onDataReceived == 
    /\ stateData /= externalData
    /\ pendingData /= externalData
    /\ timeoutCntr /= 0
    /\ pc' = pc + 1
    /\ IF timeoutCntr = None
        THEN /\ stateData' = externalData
             /\ UNCHANGED << timeoutCntr, externalData, pendingData >>
        ELSE /\ timeoutCntr' = timeoutCntr - 1
             /\ pendingData' = externalData
             /\ UNCHANGED << externalData, stateData >>
             
onRunOutSyncTime ==
    /\ pc >= pcDepth
    /\ (timeoutCntr /= None /\ timeoutCntr > 0)
    /\ timeoutCntr' = timeoutCntr - 1
    /\ UNCHANGED << externalData, stateData, pendingData, pc >>

onTimeoutCntrExpire == 
    /\ timeoutCntr = 0
    /\ timeoutCntr' = None
    /\ IF pendingData /= None
        THEN /\ stateData' = pendingData
             /\ pendingData' = None
             /\ UNCHANGED << externalData, pc>>
        ELSE /\ UNCHANGED << stateData, pendingData, externalData, pc >>
        
onAllDone ==
    /\ pc >= pcDepth
    /\ externalData = stateData
    /\ pendingData = None
    /\ timeoutCntr = None
    /\ UNCHANGED << timeoutCntr, externalData, stateData, pendingData, pc >>

Init == 
    /\ timeoutCntr = None
    /\ externalData = 0
    /\ stateData = 0
    /\ pendingData = None
    /\ pc = 0

Next == 
    \/ onLocalRowEdit
    \/ onRemoteRowEdit
    \/ onApplyPendingData
    \/ onDataReceived
    \/ onTimeoutCntrExpire
    \/ onRunOutSyncTime
    \/ onAllDone
    \/ onChangeLayout

Spec == 
    /\ Init 
    /\ [][Next]_<< timeoutCntr, externalData, stateData, pendingData, pc >>
    /\ <> (stateData = externalData)

=============================================================================
\* Modification History
\* Last modified Mon Jan 22 13:27:54 EST 2024 by H291954
\* Created Thu Dec 21 11:21:59 EST 2023 by H291954
