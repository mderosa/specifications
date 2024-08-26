---- MODULE PumpBenchCtx0 ----
EXTENDS TLC, Integers

Sensors == [
    MotorSpeed: Int,
    MotorTorque: Int,
    InletPressure: Int,
    DischargePressure: Int,
    FlowRate: Int
]

Actuators == [
    MotorOn: BOOLEAN,
    ValveOpen: Int
]

====