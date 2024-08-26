---- MODULE SyncCtx0 ----
EXTENDS TLC, Integers

CData == [
    Value: Int,
    ClientNm: STRING,
    SyncTime: Int,
    LastSyncTime: Int
]

SData == [
    Value: Int,
    ClientNm: STRING,
    CreateTime: Int,
    UpdateTime: Int
]
====