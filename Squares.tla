---- MODULE Squares ----
EXTENDS TLC, Integers

(*--algorithm Squares
variables 
    x \in 1..10;
begin
    assert x ^ 2 <= 100;
end algorithm; *)
\* BEGIN TRANSLATION (chksum(pcal) = "7087572b" /\ chksum(tla) = "6b7c10db")
VARIABLES pc, x

vars == << pc, x >>

Init == (* Global variables *)
        /\ x \in 1..10
        /\ pc = "Lbl_1"

Lbl_1 == /\ pc = "Lbl_1"
         /\ Assert(x ^ 2 <= 100, "Failure of assertion at line 8, column 5.")
         /\ pc' = "Done"
         /\ x' = x

(* Allow infinite stuttering to prevent deadlock on termination. *)
Terminating == pc = "Done" /\ UNCHANGED vars

Next == Lbl_1
           \/ Terminating

Spec == Init /\ [][Next]_vars

Termination == <>(pc = "Done")

\* END TRANSLATION 
====
