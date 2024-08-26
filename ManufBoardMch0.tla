--------------------------- MODULE ManufBoardMch0 ---------------------------
EXTENDS ManufBoardCtx0, TLC, Integers

CONSTANTS timeout, pcDepth
VARIABLES timeoutCntr, externalData, assemblyItems, pendingData, dataLoadStatus, pc

\* Invariants
InvInSync == timeoutCntr = None => pendingData = None
InvPendingData == pendingData /= None => timeoutCntr /= None

InvData ==
    /\ externalData >= 0 
    /\ (pendingData = None \/ pendingData > assemblyItems)
    /\ (assemblyItems = None \/ (assemblyItems >= 0 /\ assemblyItems <= externalData))
    
InvLoadStatus ==
    /\ dataLoadStatus = "Loaded" <=> assemblyItems /= None
    /\ dataLoadStatus = "NotLoaded" <=> assemblyItems = None
    /\ dataLoadStatus = "NotLoaded" => pendingData = None
    
\* Propositions
PendingDataSyncEnabled == timeoutCntr = 0

\* Transition functions 
onLocalRowEdit == 
    /\ pc < pcDepth
    /\ ~ PendingDataSyncEnabled
    /\ dataLoadStatus = "Loaded"
    /\ timeoutCntr' = timeout
    /\ externalData' = externalData + 1
    /\ pc' = pc + 1
    /\ UNCHANGED << assemblyItems, pendingData, dataLoadStatus >>

onChangeLayout ==
    /\ pc < pcDepth
    /\ ~ PendingDataSyncEnabled
    /\ dataLoadStatus = "Loaded"
    /\ pc' = pc + 1
    /\ IF pendingData = None
        THEN UNCHANGED << timeoutCntr, assemblyItems, pendingData, externalData, dataLoadStatus >>
        ELSE /\ timeoutCntr' = None
             /\ assemblyItems' = pendingData
             /\ pendingData' = None
             /\ UNCHANGED << externalData, dataLoadStatus >>

onRemoteRowEdit == 
    /\ pc < pcDepth
    /\ ~ PendingDataSyncEnabled
    /\ externalData' = externalData + 1
    /\ pc' = pc + 1
    /\ IF timeoutCntr = None
        THEN UNCHANGED << timeoutCntr, assemblyItems, pendingData, dataLoadStatus >>
        ELSE /\ timeoutCntr' = timeoutCntr - 1
             /\ UNCHANGED << assemblyItems, pendingData, dataLoadStatus >>

onApplyPendingData == 
    /\ pc < pcDepth /\ pendingData /= None
    /\ ~ PendingDataSyncEnabled
    /\ dataLoadStatus = "Loaded"
    /\ timeoutCntr' = None
    /\ assemblyItems' = pendingData
    /\ pendingData' = None
    /\ pc' = pc + 1
    /\ UNCHANGED << externalData, dataLoadStatus >>

onDataReceived == 
    /\ assemblyItems /= externalData
    /\ pendingData /= externalData
    /\ ~ PendingDataSyncEnabled
    /\ pc' = pc + 1
    /\ IF timeoutCntr = None
        THEN /\ assemblyItems' = externalData
             /\ dataLoadStatus' = "Loaded"
             /\ UNCHANGED << timeoutCntr, externalData, pendingData >>
        ELSE /\ timeoutCntr' = timeoutCntr - 1
             /\ pendingData' = externalData
             /\ Assert(dataLoadStatus /= "NotLoaded", "onDataRecieved assert violation")
             /\ UNCHANGED << externalData, assemblyItems, dataLoadStatus >>
             
onRunOutSyncTime ==
    /\ pc >= pcDepth
    /\ (timeoutCntr /= None /\ timeoutCntr > 0)
    /\ timeoutCntr' = timeoutCntr - 1
    /\ UNCHANGED << externalData, assemblyItems, pendingData, pc, dataLoadStatus >>

onTimeoutCntrExpire == 
    /\ PendingDataSyncEnabled
    /\ timeoutCntr' = None
    /\ IF pendingData /= None
        THEN /\ assemblyItems' = pendingData
             /\ pendingData' = None
             /\ UNCHANGED << externalData, pc, dataLoadStatus>>
        ELSE /\ UNCHANGED << assemblyItems, pendingData, externalData, pc, dataLoadStatus >>
        
onLocationChanged ==
    /\ pc < pcDepth
    /\ ~ PendingDataSyncEnabled
    /\ timeoutCntr' = None
    /\ assemblyItems' = None
    /\ dataLoadStatus' = "NotLoaded"
    /\ pendingData' = None
    /\ pc' = pc + 1
    /\ UNCHANGED << externalData >>
        
onAllDone ==
    /\ pc >= pcDepth
    /\ externalData = assemblyItems
    /\ pendingData = None
    /\ timeoutCntr = None
    /\ UNCHANGED << timeoutCntr, externalData, assemblyItems, pendingData, pc, dataLoadStatus >>

Init == 
    /\ timeoutCntr = None
    /\ externalData = 0
    /\ assemblyItems = 0
    /\ dataLoadStatus = "Loaded"
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
    \/ onLocationChanged

Spec == 
    /\ Init 
    /\ [][Next]_<< timeoutCntr, externalData, assemblyItems, pendingData, pc, dataLoadStatus >>
    /\ <> (assemblyItems = externalData)

=============================================================================
\* Modification History
\* Last modified Mon Jan 22 14:26:14 EST 2024 by H291954
\* Created Thu Dec 21 11:21:59 EST 2023 by H291954
