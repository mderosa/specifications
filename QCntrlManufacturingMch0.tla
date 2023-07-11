---- MODULE QCntrlManufacturingMch0 ----
EXTENDS TLC, Sequences, FiniteSets, QCntrlManufacturingCtx0

VARIABLES idx, steps, woCreated

\* Helper functions
updateStepsAt(i, step) == [steps EXCEPT ![i] = step]

nextState(step) ==
    CASE step.state = "Waiting" -> "Started"
    [] step.state = "Started" /\ step.completers /= {} -> "Completed"
    [] step.state = "Started" /\ step.completers = {} -> "Approved"
    [] step.state = "Completed" /\ step.approvers /= {} -> "Approved"
    [] step.state = "Completed" /\ step.approvers = {} -> ""
    [] OTHER -> ""

\* Invariants
InvOrderedProcessing == 
    /\ \A i \in 1..2 : i < idx => nextState(steps[i]) = ""
    /\ \A i \in 1..2 : i > idx => steps[i].state = "Waiting"
    /\ (woCreated /\ idx /= 3) => steps[idx].state \in {"Started", "Completed", "Approved"}

InvUnreachable == 
    /\ \A i \in 1..2 : LET s == steps[i]
                       IN /\ s.completers = {} => ~ (s.state = "Completed")
                          /\ s.approvers = {} => ~ (s.state = "Approved")
                          
\* Transition Functions

onWoCreate ==
    /\ idx = 1 
    /\ woCreated = FALSE
    /\ LET step == steps[idx]
           nxtState == nextState(step)
       IN /\ steps' = updateStepsAt(idx, [step EXCEPT !.state = nxtState])
          /\ woCreated' = TRUE
          /\ UNCHANGED << idx >>

onLeaveStarted ==
    /\ idx \in {1, 2}
    /\ woCreated = TRUE
    /\ steps[idx].state = "Started"
    /\ LET step == steps[idx]
            nxtState == nextState(step)
       IN /\ steps' = updateStepsAt(idx, [step EXCEPT !.state = nxtState])
          /\ UNCHANGED << idx, woCreated >>

onLeaveCompleted ==
    /\ idx \in {1, 2}
    /\ woCreated = TRUE
    /\ steps[idx].state = "Completed"
    /\ LET step == steps[idx]
           nxtState == nextState(step)
       IN CASE nxtState = "" /\ idx < 2 -> 
            /\ steps' = [steps EXCEPT ![idx + 1] = [steps[idx + 1] EXCEPT !.state = "Started"]]
            /\ idx' = idx + 1
            /\ UNCHANGED << woCreated >>
          [] nxtState = "" /\ idx = 2 ->
            /\ idx' = idx + 1
            /\ UNCHANGED << steps, woCreated >>
          [] OTHER ->
            /\ steps' = updateStepsAt(idx, [step EXCEPT !.state = nxtState])
            /\ UNCHANGED << idx, woCreated >>
            
onLeaveApproved ==
    /\ idx \in {1, 2}
    /\ woCreated = TRUE
    /\ steps[idx].state = "Approved"
    /\ IF idx = 2
           THEN /\ idx' = idx + 1
                /\ UNCHANGED << steps, woCreated >>
           ELSE /\ steps' = [steps EXCEPT ![idx + 1] = [steps[idx + 1] EXCEPT !.state = "Started"]]
                /\ idx' = idx + 1
                /\ UNCHANGED << woCreated >>

allDone ==
    /\ idx > 2
    /\ woCreated = TRUE
    /\ UNCHANGED << idx, steps, woCreated >>

Init == 
    /\ idx = 1
    /\ woCreated = FALSE
    /\ steps \in {s \in (InitialStep \X InitialStep) : \A i \in 1..2 : 
            /\ s[i].docTemplate = 1 => s[i].completers /= {}  \* someone has to fill in the form if it exists
            /\ s[i].docTemplate = NoForm => s[i].approvers /= {}  \* or there is nothing to do in this step
            }

Next == 
    \/ onWoCreate
    \/ onLeaveStarted
    \/ onLeaveCompleted
    \/ onLeaveApproved
    \/ allDone

Spec == Init /\ [][Next]_<< idx, steps, woCreated >>

Termination == <>(idx > 2)

====