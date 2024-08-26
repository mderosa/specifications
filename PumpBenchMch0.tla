---- MODULE PumpBenchMch0 ----
EXTENDS TLC, PumpBenchCtx0

VARIABLES snsrs, actrs

InvFlow == 
    /\ snsrs.MotorSpeed = 0 => snsrs.FlowRate = 0
    /\ snsrs.ValveOpen = 0 => snsrs.FlowRate = 0
    /\ snsrs.FlowRate = 0 => snsrs.MotorSpeed = 0 \/ snsrs.ValveOpen = 0

InvMotor ==
    /\ actrs.MotorOn = FALSE <=> snsrs.MotorSpeed = 0 
    /\ actrs.MotorOn = FALSE <=> snsrs.MotorTorque = 0
    /\ snsrs.MotorSpeed > 0 <=> actrs.MotorOn = TRUE
    /\ snsrs.MotorTorque > 0 <=> actrs.MotorOn = TRUE

InvInlet == 
    /\ snsrs.InletPressure = 0 <=> snsrs.MotorOn = FALSE
    /\ snsrs.InletPressure > 0 <=> snsrs.MotorOn = TRUE

InvDischarge ==
    /\ snsrs.DischargePressure = 0 <=> snsrs.MotorOn = FALSE
    /\ snsrs.DischargePressure > 0 <=> snsrs.MotorOn = TRUE

Init == 
    /\ snsrs = [
        MotorSpeed |-> 0,
        MotorTorque |-> 0,
        InletPressure |-> 0,
        DischargePressure |-> 0,
        FlowRate |-> 0
        ]
    /\ actrs = [
        MotorOn |-> FALSE, 
        ValveOpen |-> 0
        ]

\* we set the flow rate and the controllers set the valve position 

Next == TRUE

Spec == Init /\ [][Next]_<< snsrs, actrs >>

====