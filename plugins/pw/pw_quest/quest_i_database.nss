// -----------------------------------------------------------------------------
//    File: quest_i_database.nss
//  System: Quest Control System
// -----------------------------------------------------------------------------
// Description:
//  Primary functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

/*
    This file contains all the database-related code to support the quest system.
    All sqlite formations and calls should be in this file.  NWN-organic sqlite
    database for the PC (persistent) and the module (volatile) are used.  The
    campaign sqlite db (persistent) is not used in this implementation.  Generally,
    this file should not be modified in any way unless you know exactly what you
    are doing.  All SQL sequences are built as strings and the compiler has no
    way of verifying their veracity until they are run against an sqlite database.

    This is an internal-use file, so very few function prototypes are provided, and
    they are provided in the primary quest system file.
*/

string sQuery;
sqlquery sql;

void CreateModuleQuestTables(int bReset = FALSE)
{
    // Define the tables
    string sQuests = "CREATE TABLE IF NOT EXISTS quest_quests (" +
                        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                        "sTag TEXT NOT NULL default '~' UNIQUE ON CONFLICT IGNORE, " +
                        "nActive TEXT NOT NULL default '0', " +
                        "sJournalTitle TEXT default NULL, " +
                        "nRepetitions TEXT default '1', " +
                        "sScriptOnAccept TEXT default NULL, " +
                        "sScriptOnAdvance TEXT default NULL, " +
                        "sScriptOnComplete TEXT default NULL, " + 
                        "sScriptOnFail TEXT defaul NULL, " +
                        "nStepOrder TEXT default '" + IntToString(QUEST_STEP_ORDER_SEQUENTIAL) + "', " +
                        "sTimeLimit TEXT default NULL, " +
                        "sCooldown TEXT default NULL);";

    string sQuestPrerequisites = "CREATE TABLE IF NOT EXISTS quest_prerequisites (" +
                        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                        "quests_id INTEGER NOT NULL default '0', " +
                        "nValueType INTEGER NOT NULL default '0', " +
                        "sKey TEXT NOT NULL default '', " +
                        "sValue TEXT NOT NULL default '', " +
                        "FOREIGN KEY (quests_id) REFERENCES quest_quests (id) " +
                            "ON UPDATE CASCADE ON DELETE CASCADE);";

    string sQuestSteps = "CREATE TABLE IF NOT EXISTS quest_steps (" +
                        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                        "quests_id INTEGER NOT NULL default '0', " +
                        "nStep INTEGER NOT NULL default '0', " +
                        "sJournalEntry TEXT default NULL, " +
                        "sTimeLimit TEXT default NULL, " +
                        "nPartyCompletion TEXT default '0', " +
                        "nStepType INTEGER default '0', " +
                        "FOREIGN KEY (quests_id) REFERENCES quest_quests (id) " +
                            "ON DELETE CASCADE ON UPDATE CASCADE);";

    string sQuestStepProperties = "CREATE TABLE IF NOT EXISTS quest_step_properties (" +
                        "quest_steps_id INTEGER NOT NULL default '0', " +
                        "nCategoryType INTEGER NOT NULL default '0', " +
                        "nValueType INTEGER NOT NULL default '0', " +
                        "sKey TEXT NOT NULL default '~', " +
                        "sValue INTEGER default NULL, " +
                        "UNIQUE (quest_steps_id, nCategoryType, nValueType, sKey) ON CONFLICT REPLACE, " +
                        "FOREIGN KEY (quest_steps_id) REFERENCES quest_steps (id) " +
                            "ON DELETE CASCADE ON UPDATE CASCADE);";

    // Destroy if required
    if (bReset)
    {
        string sTable, sTables = "quests,prerequisites,steps,step_properties";
        int n, nCount = CountList(sTables);  
    
        for (n = 0; n < nCount; n++)
        {
            sTable = GetListItem(sTables, n);
            sQuery = "DROP TABLE IF EXISTS quest_" + sTable + ";";
            sql = SqlPrepareQueryObject(GetModule(), sQuery);
            SqlStep(sql);
        }
    }

    SetDebugLevel(DEBUG_LEVEL_DEBUG, GetModule());

    sql = SqlPrepareQueryObject(GetModule(), sQuests);              SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_quests", "module");

    sql = SqlPrepareQueryObject(GetModule(), sQuestPrerequisites);  SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_prerequisites", "module");

    sql = SqlPrepareQueryObject(GetModule(), sQuestSteps);          SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_steps", "module");

    sql = SqlPrepareQueryObject(GetModule(), sQuestStepProperties); SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_step_properties", "module");
}

void CreatePCQuestTables(object oPC, int bReset = FALSE)
{
    string sQuest = "CREATE TABLE IF NOT EXISTS quest_pc_data (" +
        "quest_tag TEXT UNIQUE ON CONFLICT IGNORE, " +
        "nStep INTEGER default '0', " +
        "nCompletions INTEGER default '0', " +
        "sQuestStartTime TEXT default '', " +
        "sStepStartTime TEXT default '', " +
        "sLastCompleteTime TEXT default '');";

    string sQuestStep = "CREATE TABLE IF NOT EXISTS quest_pc_step (" +
        "quest_tag TEXT, " +
        "nObjectiveType INTEGER, " +
        "sTag TEXT, " +
        "nRequired INTEGER, " +
        "nAcquired INTEGER default '0', " +
        "FOREIGN KEY (quest_tag) REFERENCES quest_pc_data (quest_tag) " +
            "ON UPDATE CASCADE ON DELETE CASCADE);";

    // Destroy if required
    if (bReset)
    {
        string sTable, sTables = "data,step";
        int n, nCount = CountList(sTables);  
    
        for (n = 0; n < nCount; n++)
        {
            sTable = GetListItem(sTables, n);
            sQuery = "DROP TABLE IF EXISTS quest_pc_" + sTable + ";";
            sql = SqlPrepareQueryObject(oPC, sQuery);
            SqlStep(sql);
        }
    }

    sql = SqlPrepareQueryObject(oPC, sQuest);     SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_pc_data", GetName(oPC));

    sql = SqlPrepareQueryObject(oPC, sQuestStep); SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_pc_step", GetName(oPC));
}

void CreateQuestVariablesTable(int bReset = FALSE)
{
    string sQuestVariables = "CREATE TABLE IF NOT EXISTS quest_variables (" +
                        "quests_id INTEGER NOT NULL, " +
                        "sType TEXT NOT NULL, " +
                        "sName TEXT NOT NULL, " +
                        "sValue TEXT NOT NULL, " +
                        "UNIQUE (sType, sName) ON CONFLICT REPLACE, " +
                        "FOREIGN KEY (quests_id) REFERENCES quest_quests (id) " +
                            "ON UPDATE CASCADE ON DELETE CASCADE);";
    
    if (bReset)
    {
        sQuery = "DROP TABLE IF EXISTS quest_variables;";
        sql = SqlPrepareQueryObject(GetModule(), sQuery);
        SqlStep(sql);
    }
    
    sql = SqlPrepareQueryObject(GetModule(), sQuestVariables);
    SqlStep(sql);

    HandleSqlDebugging(sql, "SQL:table", "quest_variables", "module");
}

void CleanPCQuestTables(object oPC)
{
    sQuery = "SELECT GROUP_CONCAT(sTag) " +
             "FROM quest_quests;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    
    if (SqlStep(sql))
    {
        string sQuestTags = SqlGetString(sql, 0);
        sQuery = "DELETE FROM quest_pc_data " +
                 "WHERE quest_tag NOT IN (@tags);";
        sql = SqlPrepareQueryObject(oPC, sQuery);
        SqlBindString(sql, "@tags", sQuestTags);

        SqlStep(sql);
    }

    HandleSqlDebugging(sql);
}

int GetLastInsertedID(string sTable)
{
    sQuery = "SELECT seq FROM sqlite_sequence WHERE name = @name;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindString(sql, "@name", sTable);
    
    return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

string GetQuestTag(int nQuestID)
{
    sQuery = "SELECT sTag FROM quest_quests " +
             "WHERE id = @id;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);

    return (SqlStep(sql) ? SqlGetString(sql, 0) : "");
}

int GetQuestID(string sQuestTag)
{
    sQuery = "SELECT id FROM quest_quests WHERE sTag = @sQuestTag;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindString(sql, "@sQuestTag", sQuestTag);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

void AddQuestPrerequisite(int nQuestID, int nValueType, string sKey, string sValue)
{
    sQuery = "INSERT INTO quest_prerequisites (quests_id, nValueType, sKey, sValue) " +
             "VALUES (@quests_id, @nValueType, @key, @sValue);";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@quests_id", nQuestID);
    SqlBindInt(sql, "@nValueType", nValueType);
    SqlBindString(sql, "@key", sKey);
    SqlBindString(sql, "@sValue", sValue);

    SqlStep(sql);

    HandleSqlDebugging(sql);
}

int _AddQuest(string sQuestTag, string sJournalTitle)
{
    string sQuery = "INSERT INTO quest_quests (sTag, sJournalTitle) " +
                    "VALUES (@sTag, @sTitle);";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindString(sql, "@sTag", sQuestTag);
    SqlBindString(sql, "@sTitle", sJournalTitle);

    SqlStep(sql);
    HandleSqlDebugging(sql);

    return GetLastInsertedID("quest_quests");
}

void _AddQuestStep(int nQuestID, string sJournalEntry, int nStep)
{
    string sQuest = "INSERT INTO quest_steps (quests_id, nStep, sJournalEntry) " +
                    "VALUES (@quests_id, @nStep, @sJournalEntry);";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuest);
    SqlBindInt(sql, "@quests_id", nQuestID);
    SqlBindInt(sql, "@nStep", nStep);
    SqlBindString(sql, "@sJournalEntry", sJournalEntry);
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

sqlquery GetQuestPrerequisites(int nQuestID)
{
    sQuery = "SELECT nPropertyType, sKey, sValue " +
             "FROM quest_prerequisites " + 
             "WHERE quests_id = @id;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);

    return sql;
}

sqlquery GetQuestPrerequisiteTypes(int nQuestID)
{
    sQuery = "SELECT nValueType, COUNT(sKey) " +
             "FROM quest_prerequisites " +
             "WHERE quests_id = @id " +
             "GROUP BY nValueType " +
             "ORDER BY nValueType;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);

    return sql;
}

sqlquery GetQuestPrerequisitesByType(int nQuestID, int nValueType)
{
    sQuery = "SELECT sKey, sValue " +
             "FROM quest_prerequisites " +
             "WHERE quests_id = @id " +
                "AND nValueType = @type;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@type", nValueType);

    return sql;
}

int CountQuestSteps(int nQuestID)
{
    sQuery = "SELECT COUNT(*) " +
             "FROM quest_steps " +
             "WHERE quests_id = @id " +
                "AND nStepType = @type;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@type", QUEST_STEP_TYPE_PROGRESS);

    int nSteps;
    if (SqlStep(sql))
        nSteps = SqlGetInt(sql, 0);

    HandleSqlDebugging(sql);
    return nSteps;
    //return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

int CountQuestPrerequisites(int nQuestID)
{
    sQuery = "SELECT COUNT(id) " +
             "FROM quest_prerequisites " +
             "WHERE quests_id = @id;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);

    int nCount;
    if (SqlStep(sql))
        nCount = SqlGetInt(sql, 0);

    HandleSqlDebugging(sql);
    return nCount;
    //return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

sqlquery GetQuestData(int nQuestID)
{
    sQuery = "SELECT * FROM quest_quests WHERE id = @nQuestID;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@nQuestID", nQuestID);

    return sql;
}

sqlquery GetQuestProperties(int nQuestID)
{
    sQuery = "SELECT * FROM quest_properties WHERE quest_id = @nQuestID;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@nQuestID", nQuestID);

    return sql;
}

int GetQuestExists(string sTag)
{
    sQuery = "SELECT COUNT(id) FROM quest_quests " +
             "WHERE sTag = @tag;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindString(sql, "@tag", sTag);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : FALSE;
}


int GetQuestStepID(int nQuestID, int nStep)
{
    sQuery = "SELECT id FROM quest_steps " +
             "WHERE quests_id = @id " +
                "AND nStep = @step;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@step", nStep);

    int nID;
    if (SqlStep(sql))
        nID = SqlGetInt(sql, 0);

    HandleSqlDebugging(sql);
    return nID;
    //return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

sqlquery GetQuestStepPropertySets(int nQuestID, int nStep, int nCategoryType)
{
    string sQuery = "SELECT nValueType, sKey, sValue " +
                    "FROM quest_step_properties " +
                    "WHERE nCategoryType = @category " +
                        "AND quest_steps_id = @id;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@category", nCategoryType);
    SqlBindInt(sql, "@id", GetQuestStepID(nQuestID, nStep));

    return sql;
}

sqlquery GetQuestStepPropertyPairs(int nQuestID, int nStep, int nCategoryType, int nValueType)
{
    sQuery = "SELECT quest_step_properties.sKey, " +
                    "quest_step_properties.sValue " +
             "FROM quest_steps INNER JOIN quest_step_properties " +
                "ON quest_steps.id = quest_step_properties.quest_steps_id " +
             "WHERE quest_steps.id = @id " +
                "AND quest_steps.nStep = @step " +
                "AND quest_step_properties.nCategoryType = @category " +
                "AND quest_step_properties.nValueType = @value_type;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@step", nStep);
    SqlBindInt(sql, "@category", nCategoryType);
    SqlBindInt(sql, "@value_type", nValueType);

    return sql;
}

void DeleteQuestStepPropertyPair(int nQuestID, int nStep, int nCategoryType, int nValueType)
{
    string sQuery = "DELETE FROM quest_step_properties " +
             "WHERE nCategoryType = @category " +
                "AND nValueType = @type " +
                "AND quest_steps_id = @id;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@category", nCategoryType);
    SqlBindInt(sql, "@type", nValueType);
    SqlBindInt(sql, "@id", GetQuestStepID(nQuestID, nStep));

    SqlStep(sql);

    HandleSqlDebugging(sql);
}

sqlquery GetQuestStepObjectiveData(int nQuestID, int nStep)
{
    sQuery = "SELECT quest_step_properties.nValueType, " +
                    "quest_step_properties.sKey, " +
                    "quest_step_properties.sValue " +
             "FROM quest_steps INNER JOIN quest_step_properties " +
                "ON quest_steps.id = quest_step_properties.quest_steps_id " +
             "WHERE quest_step_properties.nCategoryType = @category " +
                "AND quest_steps.nStep = @step " +
                "AND quest_steps.quests_id = @id;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@category", QUEST_CATEGORY_OBJECTIVE);
    SqlBindInt(sql, "@step", nStep);
    SqlBindInt(sql, "@id", nQuestID);

    return sql;
}

int GetQuestStepObjectiveType(int nQuestID, int nStep)
{
    sQuery = "SELECT quest_step_properties.nValueType " +
             "FROM quest_steps INNER JOIN quest_step_properties " +
                "ON quest_steps.id = quest_step_properties.quest_steps_id " +
             "WHERE quest_step_properties.nCategoryType = @category " +
                "AND quest_steps.nStep = @step " +
                "AND quest_steps.quests_id = @id " +
            "LIMIT 1;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@category", QUEST_CATEGORY_OBJECTIVE);
    SqlBindInt(sql, "@step", nStep);
    SqlBindInt(sql, "@id", nQuestID);

    int nType;
    if (SqlStep(sql))
        nType = SqlGetInt(sql, 0);

    HandleSqlDebugging(sql);
    return nType;
    //return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

int CountQuestStepObjectivePairs(int nQuestID, int nStep)
{
    sQuery = "SELECT COUNT(sValues) " +
             "FROM quest_steps INNER JOIN quest_step_properties " +
                "ON quest_steps.id = quest_step_properties.quest_steps_id " +
             "WHERE quest_step_properties.nCategoryType = @category " +
                "AND quest_steps.nStep = @step " +
                "AND quest_steps.quests_id = @id;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@category", QUEST_CATEGORY_OBJECTIVE);
    SqlBindInt(sql, "@step", nStep);
    SqlBindInt(sql, "@id", nQuestID);
    
    int nCount;
    if (SqlStep(sql))
        nCount = SqlGetInt(sql, 0);

    HandleSqlDebugging(sql);
    return nCount;
    //return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

void _AddQuestToPC(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "INSERT INTO quest_pc_data (quest_tag) " +
             "VALUES (@tag);";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);

    SqlStep(sql);

    HandleSqlDebugging(sql);
}

void DeletePCQuest(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "DELETE FROM quest_pc_data " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

int GetPCHasQuest(object oPC, string sQuestTag)
{
    sQuery = "SELECT COUNT(quest_tag) FROM quest_pc_data " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    
    int nHas;
    if (SqlStep(sql))
        nHas = SqlGetInt(sql, 0);

    HandleSqlDebugging(sql);
    return nHas;
    //return SqlStep(sql) ? SqlGetInt(sql, 0) : FALSE;
}

int GetIsPCQuestComplete(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "SELECT COUNT(*) FROM quest_pc_step " +
                "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);

    int nComplete;
    if (SqlStep(sql))
        nComplete = SqlGetInt(sql, 0);

    HandleSqlDebugging(sql);
    return nComplete;

    //return SqlStep(sql) ? SqlGetInt(sql, 0) == 0 : FALSE;
}

int GetPCQuestCompletions(object oPC, string sQuestTag)
{
    sQuery = "SELECT nCompletions FROM quest_pc_data " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);

    int nCount;
    if (SqlStep(sql))
        nCount = SqlGetInt(sql, 0);

    HandleSqlDebugging(sql);
    return nCount;

    //return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

void ResetPCQuestData(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);
    string sQuery = "UPDATE quest_pc_data " +
                    "SET nStep = @step, " +
                        "sQuestStartTime = @quest_start, " +
                        "sStepStartTime = @step_start " +
                    "WHERE quest_tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlBindInt(sql, "@step", 0);
    SqlBindString(sql, "@quest_start", "");
    SqlBindString(sql, "@step_start", "");

    SqlStep(sql);

    HandleSqlDebugging(sql);
}

void IncrementPCQuestCompletions(object oPC, int nQuestID, string sTime = "")
{
    if (sTime == "")
        sTime = GetSystemTime();

    ResetPCQuestData(oPC, nQuestID);

    string sQuestTag = GetQuestTag(nQuestID);
    sQuery = "UPDATE quest_pc_data " +
             "SET nCompletions = nCompletions + 1 " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

sqlquery GetStepObjectivesByTarget(object oPC, string sTarget)
{
    string sQuery = "SELECT quest_pc_step.sTag, " +
                        "quest_pc_data.quest_tag, " +
                        "quest_pc_data.nStep " +
                    "FROM quest_pc_data INNER JOIN quest_pc_step " +
                        "ON quest_pc_data.quest_tag = quest_pc_step.quest_tag " +
                    "WHERE quest_pc_step.sTag = @target;";

    sqlquery sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@target", sTarget);

    return sql;
}

sqlquery GetTargetQuestData(object oPC, string sTargetTag, int nObjectiveType)
{
    sQuery = "SELECT quest_pc_data.quest_tag, " +
                    "quest_pc_data.nStep " +
             "FROM quest_pc_data INNER JOIN quest_pc_step " +
                "ON quest_pc_data.quest_tag = quest_pc_step.quest_tag " +
             "WHERE quest_pc_step.nObjectiveType = @type " +
                "AND quest_pc_step.sTag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindInt(sql, "@type", nObjectiveType);
    SqlBindString(sql, "@tag", sTargetTag);

    return sql;
}

void IncrementQuestStepQuantity(object oPC, string sTargetTag, int nObjectiveType)
{
    sQuery = "UPDATE quest_pc_step " +
             "SET nAcquired = nAcquired + 1 " +
             "WHERE nObjectiveType = @type " +
                "AND sTag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindInt(sql, "@type", nObjectiveType);
    SqlBindString(sql, "@tag", sTargetTag);

    SqlStep(sql);

    HandleSqlDebugging(sql);
}

sqlquery GetQuestStepSums(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "SELECT quest_tag, SUM(nRequired), SUM(nAcquired) " +
             "FROM quest_pc_step " +
             "WHERE quest_tag = @tag " +
                "AND nRequired > @zero " +
             "GROUP BY quest_tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlBindInt(sql, "@zero", 0);
    return sql;
}

sqlquery GetQuestStepSumsFailure(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "SELECT quest_tag, SUM(nRequired), SUM(nAcquired) " +
             "FROM quest_pc_step " +
             "WHERE quest_tag = @tag " +
                "AND nRequired = @zero " +
             "GROUP BY quest_tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlBindInt(sql, "@zero", 0);
    return sql;
}

void DeletePCQuestProgress(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "DELETE FROM quest_pc_step " + 
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

int GetPCQuestStep(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "SELECT nStep FROM quest_pc_data " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);

    int nStep;
    if (SqlStep(sql))
        nStep = SqlGetInt(sql, 0);
    else
        nStep = -1;

    HandleSqlDebugging(sql);
    return nStep;

    // This could be 0 for the first step, so return -1
    //return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

int GetNextPCQuestStep(int nQuestID, int nCurrentStep)
{
    sQuery = "SELECT nStep FROM quest_steps " +
             "WHERE quests_id = @id " +
                "AND nStep > @step " +
                "AND nStepType = @step_type " +
             "ORDER BY nStep ASC LIMIT 1;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@step", nCurrentStep);
    SqlBindInt(sql, "@step_type", QUEST_STEP_TYPE_PROGRESS);

    int nStep;
    if (SqlStep(sql))
        nStep = SqlGetInt(sql, 0);
    else
        nStep = -1;

    HandleSqlDebugging(sql);
    return nStep;

    //return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

void AddQuestStepObjectiveData(object oPC, int nQuestID, int nObjectiveType, 
                               string sTargetTag, int nQuantity)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "INSERT INTO quest_pc_step (quest_tag, nObjectiveType, " +
                "sTag, nRequired) " +
             "VALUES (@quest_tag, @type, @tag, @qty);";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@quest_tag", sQuestTag);
    SqlBindInt(sql, "@type", nObjectiveType);
    SqlBindString(sql, "@tag", sTargetTag);
    SqlBindInt(sql, "@qty", nQuantity);

    SqlStep(sql);

    HandleSqlDebugging(sql);
}

int GetQuestCompletionStep(int nQuestID, int nRequestType = QUEST_ADVANCE_SUCCESS)
{
    sQuery = "SELECT nStep FROM quest_steps " +
             "WHERE quests_id = @id " +
                "AND nStepType = @step_type;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@step_type", nRequestType == QUEST_ADVANCE_SUCCESS ? 
                                                    QUEST_STEP_TYPE_SUCCESS :
                                                    QUEST_STEP_TYPE_FAIL);

    int nStep;
    if (SqlStep(sql))
        nStep = SqlGetInt(sql, 0);
    else
        nStep = -1;

    HandleSqlDebugging(sql);
    return nStep;

    //return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

int GetPCQuestStepAcquired(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "SELECT nAcquired FROM quest_pc_step " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    
    int nStep;
    if (SqlStep(sql))
        nStep = SqlGetInt(sql, 0);
    else
        nStep = -1;

    HandleSqlDebugging(sql);
    return nStep;

    //return SqlStep(sql) ? SqlGetString(sql, 0) : "";
}
