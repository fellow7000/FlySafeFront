//SQLite SQFLite DataTypes
// ignore_for_file: constant_identifier_names

const String sqlTEXT = "TEXT";
const String sqlVARCHAR = "TEXT";
const String sqlINTEGER = "INTEGER";
const String sqlREAL = "REAL";
const String sqlBool = "BIT";
const String sqlDateTime = "TEXT"; //store DateTime var as String ISO
const String sqlBLOB = "BLOB";

//Common Fields
const String LASTM = "LastM";
const String DELETED = "Deleted";

//Table Location Log
const String LocLog_Tbl = "Location_Time_Log";
const String LOC_ID =         "Loc_ID";
const String LOC_TYPE =       "Loc_Type";
const String LOC_NAME =       "Loc_Name";
const String LOC_LON =        "Loc_Lon";
const String LOC_LAT =        "Loc_Lat";
const String LOC_ELEV =       "Loc_Elev";
const String LOC_ELEV_DIM =   "Loc_Elev_dim";
const String LOC_ACR =        "Loc_Acr"; //accuracy
const String LOC_SPEED =      "Loc_Speed";
const String LOC_SPEED_DIM =  "Loc_Speed_dim";
const String LOC_SPEED_ACR =  "Loc_Speed_Acr"; //accчяuracy
const String LOC_HEADING =    "Loc_Heading";
const String STAMP_CMT =      "Stamp_Cmt";
const String STAMP_DATEUTC =  "Stamp_DateUTC";
const String STAMP_TIMEUTC =  "Stamp_TimeUTC";
const String STAMP_TZO =      "Stamp_TZO"; //Time Zone Offset
//LONG here
//LAT here

//Table Notes
const String Notes_Tbl = "Notes";
const String NOTE_ID =       "Note_ID";
const String NOTE_TYPE =     "Note_Type";
//modified field here (commons)
const String NOTE_SUBFLDR =  "SubFolder";
const String NOTE_NAME =     "Note_Name";
const String NOTE_BODY =     "Note_Body";
const String NOTE_PIC =      "Note_Pic";
//"deleted" field here (commons)

//SCRIPT SECTION STARTS HERE
const  String createDBv5WONotesScript =
"""
CREATE TABLE $LocLog_Tbl (
    $LOC_ID $sqlINTEGER PRIMARY KEY AUTOINCREMENT,
    $LOC_TYPE $sqlINTEGER,
    $LOC_NAME $sqlTEXT,
    $LOC_LON $sqlREAL,
    $LOC_LAT $sqlREAL,
    $LOC_ELEV $sqlREAL,
    $LOC_ELEV_DIM $sqlINTEGER,
    $LOC_ACR $sqlREAL,
    $LOC_SPEED $sqlREAL,
    $LOC_SPEED_DIM $sqlINTEGER,
    $LOC_SPEED_ACR $sqlREAL,
    $LOC_HEADING $sqlREAL,
    $STAMP_CMT $sqlTEXT,        
    $STAMP_DATEUTC $sqlINTEGER,        
    $STAMP_TIMEUTC $sqlTEXT,
    $STAMP_TZO $sqlINTEGER                 
)
""";

const String createDBv5Script = """$createDBv5WONotesScript#
CREATE TABLE $Notes_Tbl (
    $NOTE_ID $sqlINTEGER PRIMARY KEY,
    $NOTE_TYPE $sqlINTEGER, 
    $LASTM $sqlTEXT,
    $NOTE_SUBFLDR $sqlINTEGER,
    $NOTE_NAME $sqlTEXT,
    $NOTE_BODY $sqlTEXT,
    $NOTE_PIC $sqlBLOB,
    $DELETED $sqlBool
)
""";

String deleteAirFromDB =
"""
""";

String deleteAllFromTableNotes =
"""
DELETE FROM $Notes_Tbl WHERE $NOTE_ID <> -1
""";

String deleteAllFromTableTimeStamps =
"""
DELETE FROM $LocLog_Tbl
""";