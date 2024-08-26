---------------------------- MODULE DocQueueCtx0 ----------------------------
EXTENDS Integers

QItem == [
    \* msg: STRING,
    \* msg_type: {"translate"},
    \* msg_version: Int,
    revId: Int,
    submitCnt: Int,
    scheduledTm: Int,
    createTm: Int
]

Status == {"submitted", "success", "failure"}

Revision == [
    \* originalLanguage: {"en", "zh"},
    id: Int,
    translateStatus: Status,
    translateStatusDt: Int
]

=============================================================================
\* Modification History
\* Last modified Tue Apr 02 08:30:57 EDT 2024 by H291954
\* Created Mon Apr 01 13:03:33 EDT 2024 by H291954
