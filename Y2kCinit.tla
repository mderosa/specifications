---- MODULE Y2kCinit ----
EXTENDS Y2k

BIRTH_YEAR_T == 98
LICENSE_AGE_T == 1

ConstInit ==
    /\ BIRTH_YEAR \in 0..99
    /\ LICENSE_AGE \in 1..99

====