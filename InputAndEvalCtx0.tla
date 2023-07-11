---- MODULE CriticalMnfCtx1 ----
EXTENDS TLC, Integers


CriticalWellData == [
    UidWellName: STRING,
    Customer: STRING,
    
    SalesPerson: STRING,
    SalesManager: STRING,
    RegionalSalesManager: STRING,
    CountrySalesManager: STRING,

    ProjectManager: STRING,
    EngineeringTeamLead: STRING,
    CriticalMnfTeamLead: STRING,
    RegionOperationsLead: STRING,
    QualityControlLead: STRING,

    SizingRef: Int,
    SizingType: {"ESP", "HPS"},
    MeetsCWCriteria: BOOLEAN,
    LeadTimeEstimateTs: Int
]



(* Customer Requirements *)
wfCustReq == [
    state: {"Start", "CustReqFormDone", "CustReqFormApproved"},
    completers: SUBSET STRING,
    formCM_1F2Id: Int,
    approvers: SUBSET STRING
]

(* Technical Evaluation *)
wfTechEval == [
    state: {"Start", "TechEvalDone", "TechEvalApproved"},
    completers: SUBSET STRING,
    formCM_1F6Id: Int,
    approvers: SUBSET STRING
]

wfSuppliersDataReqLs == [
    state: {"Start", "SDRLDone"},
    completers: SUBSET STRING,
    formCM_1F8: Int
]

wfInspectionTestPlan == [
    state: {"Start", "ITPDone", "ITPApproved"},
    completers: SUBSET STRING,
    formCM_GL1Id: Int,
    formCM_GL2Id: Int,
    approvers: SUBSET STRING
]

cpMeetsCWCriteria == [
    state: {"Start", "MeetsCWCriteriaDone"},
    completers: SUBSET STRING,
    approvers: SUBSET STRING
]

wfRiskAssessment == [
    state: {"Start", "RisAssessDone", "RiskAssessApproved"},
    completers: SUBSET STRING,
    formCM_1F4Id: Int,
    approvers: SUBSET STRING
]

wfChangeLog == [
    state: {"Start", "ChangeLogDone"},
    formCM_1F9Id: Int,
    dependencies: SUBSET STRING
]


====