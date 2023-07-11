---- MODULE QCntrlManufacturingCtx0 ----
EXTENDS TLC, Integers
CONSTANTS NoForm

DocTemplate == {NoForm} \union Int
DocLocation == Int

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

Entities == {"Customer", "SalesPerson", "SalesManager", "RegionalSalesManager", "CountrySalesManager", 
    "ProjectManager", "EngineeringTeamLead", "CriticalMnfTeamLead", "RegionOperationsLead", 
    "QualityControlLead"}

CheckpointStep == [
    state: {"Waiting", "Started", "Approved"},
    approvers: SUBSET Entities
]

DocExecuteStep == [
    state: {"Waiting", "Started", "Completed", "Approved"},
    docTemplate: DocTemplate \union DocLocation,
    completers: SUBSET Entities,
    approvers: SUBSET Entities
]

DocCreateStep == [
    state: {"Waiting", "Started", "Completed", "Approved"},
    docLocation : DocLocation,
    completers: SUBSET Entities,
    approvers: SUBSET Entities
]

AsmblyTestStep == [
    state: {"Waiting", "Started", "Completed", "Approved", "Witnessed"},
    docLocation: DocLocation,
    completers: SUBSET Entities,
    approvers: SUBSET Entities,
    witnesses: SUBSET Entities
]

ProcessStep == DocExecuteStep \union DocCreateStep \union AsmblyTestStep

InitialStep == [
    state: {"Waiting"},
    docTemplate: {NoForm},
    completers: SUBSET {},
    approvers: SUBSET {"ProjectManager", "QualityControlLead"}
] \union [
    state: {"Waiting"},
    docTemplate: {1},
    completers: SUBSET {"EngineeringTeamLead", "CriticalMnfTeamLead"},
    approvers: SUBSET {"ProjectManager", "QualityControlLead"}
]

====