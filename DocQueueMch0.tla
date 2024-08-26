---------------------------- MODULE DocQueueMch0 ----------------------------
EXTENDS DocQueueCtx0, TLC, Integers, FiniteSets
VARIABLES revs, queue, queueErrors, pc

InvRevErrors ==
    Cardinality({r \in revs : r.translateStatus = "failure"}) = Cardinality(queueErrors)
    
InvRevSubmit ==
    Cardinality({r \in revs : r.translateStatus = "submitted"}) = Cardinality(queue)

Init == 
    /\ pc = 0
    /\ queue = {}
    /\ queueErrors = {}
    /\ revs = {}

createRevision == 
    /\ pc < 5
    /\ queue' = queue \union {[revId |-> pc, submitCnt |-> 1, scheduledTm |-> pc, createTm |-> pc]}
    /\ revs' = revs \union {[id |-> pc, translateStatus |-> "submitted", translateStatusDt |-> pc]}
    /\ pc' = pc + 1
    /\ UNCHANGED << queueErrors >>
    
_recordSuccess(item, rev) ==
    /\ queue' = queue \ {item}
    /\ revs' = (revs \ {rev}) \union {[rev EXCEPT !.translateStatus = "success"]}
    /\ pc' = pc + 1
    /\ UNCHANGED << queueErrors >>
    
_incProcessCnt ==
    /\ pc' = pc + 1
    /\ UNCHANGED << queue, queueErrors, revs >>

translateOk ==
    /\ queue /= {}
    /\ LET readys == {q \in queue : q.scheduledTm <= pc}
       IN IF readys = {}
          THEN _incProcessCnt
          ELSE LET item == CHOOSE r \in readys : TRUE
                    rev == CHOOSE r \in revs : item.revId = r.id
               IN _recordSuccess(item, rev) 

_requeueItem(item, rev) ==
    /\ queue' = (queue \ {item}) \union {[item EXCEPT !.submitCnt = item.submitCnt + 1,
                                                       !.scheduledTm = item.scheduledTm + 2]}
    /\ pc' = pc + 1
    /\ UNCHANGED << revs, queueErrors >>

_recordFailure(item, rev) ==
    /\ queue' = queue \ {item}
    /\ queueErrors' = queueErrors \union {item}
    /\ revs' = (revs \ {rev}) \union {[rev EXCEPT !.translateStatus = "failure"]}
    /\ pc' = pc + 1

translateNok == 
    /\ queue /= {}
    /\ LET readys == {q \in queue : q.scheduledTm <= pc}
       IN IF readys = {}
          THEN _incProcessCnt
          ELSE LET item == CHOOSE r \in readys : TRUE
                    rev == CHOOSE r \in revs : item.revId = r.id
               IN CASE item.submitCnt = 3 -> _recordFailure(item, rev) 
                  [] OTHER -> _requeueItem(item, rev)

emptyQueue ==
    /\ queue = {}
    /\ UNCHANGED << revs, queue, queueErrors, pc >>

Next == 
    \/ createRevision
    \/ translateOk
    \/ translateNok
    \/ emptyQueue

Spec == Init /\ [][Next]_<< revs, queue, queueErrors, pc >>

=============================================================================
\* Modification History
\* Last modified Tue Apr 02 08:31:20 EDT 2024 by H291954
\* Created Mon Apr 01 13:03:51 EDT 2024 by H291954
