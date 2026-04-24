---- MODULE Y2k ----
EXTENDS Integers

CONSTANTS 
    \* @type: Int;
    BIRTH_YEAR,
    \* @type: Int;
    LICENSE_AGE

ASSUME (BIRTH_YEAR \in 0..99)
ASSUME (LICENSE_AGE \in 0..99)

VARIABLES 
    \* @type: Int;
    year,
    \* @type: Bool;
    hasLicense

Age == year - BIRTH_YEAR

Init ==
    /\ year = BIRTH_YEAR
    /\ hasLicense = FALSE

NewYear == 
    /\ year' = (year + 1) % 100
    /\ UNCHANGED << hasLicense >>

IssueLicense == 
    /\ Age >= LICENSE_AGE
    /\ hasLicense' = TRUE
    /\ UNCHANGED << year >>

Next ==
    \/ NewYear
    \/ IssueLicense

InvSafety == hasLicense => (Age >= LICENSE_AGE)

====
