---- MODULE BinSearch ----
EXTENDS Integers, Sequences, Apalache

VARIABLES 
    \* @type: Int;
    low,
    \* @type: Int;
    high,
    \* @type: Bool;
    isTerminated,
    \* @type: Int;
    returnValue

CONSTANTS
    \* @type: Seq(Int);
    INPUT_SEQ,
    \* @type: Int;
    INPUT_KEY,
    \* @type: Int;
    INT_WIDTH

\* @type: Seq(Int);
EMT_SEQ == << >>
SEARCH_VAL == 10
EIGHT_BITS == 8

MAX_UINT == 2^INT_WIDTH
MAX_INT == 2^(INT_WIDTH - 1) - 1
MIN_INT == -2^(INT_WIDTH - 1)

Init == 
    /\ low = 0
    /\ high = Len(INPUT_SEQ) - 1
    /\ isTerminated = FALSE
    /\ returnValue = 0

Next == 
    IF ~isTerminated THEN 
        IF low <= high THEN 
            UNCHANGED << low, high, isTerminated, returnValue >>
        ELSE 
            /\ isTerminated' = TRUE
            /\ returnValue' = -(low + 1)
            /\ UNCHANGED << low, high >>
    ELSE 
        UNCHANGED << low, high, isTerminated, returnValue >>

====