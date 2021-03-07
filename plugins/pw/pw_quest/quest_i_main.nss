// -----------------------------------------------------------------------------
//    File: quest_i_main.nss
//  System: Quest Persistent World Subsystem (core)
// -----------------------------------------------------------------------------
// Description:
//  Primary functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------
// Changelog:
//
// 20210301:
//      Initial Release

// -----------------------------------------------------------------------------
//                          Database Function Prototypes
// -----------------------------------------------------------------------------

/*
    The following prototype are listed separately from the primary quest system
    prototypes because they are database-related direct-access functions.  These
    functions are avaialable for general use by including quest_i_database.
*/

// ---< Create[Module|PC]QuestTables >---
// Creates the required database tables on either the module (usually called in the
// OnModuleLoad event) or on the PC (usually called in the OnClientEnter event).
void CreateModuleQuestTables(int bReset = FALSE);
void CreatePCQuestTables(object oPC, int bReset = FALSE);

// ---< CleanPCQuestTables >---
// Clears PC quest tables of all quest data if a matching quest tag is not found
// in the module's quest database.  If this is called before quest definitions are
// loaded, all PC quest data will be erased.  Usually called in the OnClientEnter
// event.
void CleanPCQuestTables(object oPC);

// ---< GetQuest[Tag|ID] >---
// Converts a QuestTag to a QuestID
string GetQuestTag(int nQuestID);
int GetQuestID(string sQuestTag);

// ---< CountQuestSteps >---
// Counts the total number of steps in a quest, not including the final success/
// completion step.
int CountQuestSteps(int nQuestID);

// ---< CountQuestPrerequisites >---
// Counts the total number or prerequisites assigned to nQuestID.
int CountQuestPrerequisites(int nQuestID);

// ---< GetPCHasQuest >---
// Returns TRUE if oPC has quest sQuestTag assigned.
int GetPCHasQuest(object oPC, string sQuestTag);

// ---< GetIsPCQuestComplete >---
// Returns TRUE if oPC has complete quest nQuestID at least once
int GetIsPCQuestComplete(object oPC, int nQuestID);

// ---< GetPCQuestCompletions >---
// Returns the total number of times oPC has completed quest sQuestTag
int GetPCQuestCompletions(object oPC, string sQuestTag);

// ---< GetPCQuestStep >---
// Returns the current step oPC is on for quest nQuestID
int GetPCQuestStep(object oPC, int nQuestID);

// ---< GetNextPCQuestStep >---
// Given nCurrentStep, returns the step number of the next step in quest nQuestID
int GetNextPCQuestStep(int nQuestID, int nCurrentStep);

#include "util_i_csvlists"
#include "util_i_libraries"  // TODO remove after change to ExecuteScript()
#include "util_i_chat"
#include "util_i_debug"
#include "util_i_time"

#include "quest_i_const"
#include "quest_i_debug"
#include "quest_i_database"

// -----------------------------------------------------------------------------
//                          Quest System Function Prototypes
// -----------------------------------------------------------------------------

// ---< AddQuest >---
// Adds a new quest with tag sTag and Journal Entry Title sTitle.  sTag is required;
// the Journal Entry title can be added later with SetQuestTitle().
int AddQuest(string sTag, string sTitle = "");

// ---< [Get|Set]Quest[Active|Inactive] >---
// Gets or sets the active status of quest sTag.
int GetQuestActive(int nQuestID);
void SetQuestActive(int nQuestID);
void SetQuestInactive(int nQuestID);

// ---< [Get|Set]QuestTitle >---
// TODO Gets or sets the quest title shown for quest sTag in the player's journal,  This is only
// useful for NWNX implementation and currently has no effect.
string GetQuestTitle(int nQuestID);
void SetQuestTitle(int nQuestID, string sTitle);

// ---< [Get|Set]QuestRepetitions >---
// Gets or sets the number of times a PC can complete quest sTag.
int GetQuestRepetitions(int nQuestID);  // TODO sQuestTag?
void SetQuestRepetitions(int nQuestID, int nRepetitions = 1);

// ---< [Get|Set]QuestScriptOn[Accept|Advance|Complete|Fail] >---
// Gets or sets the script associated with quest events OnAccept|Advance|Complete|Fail for
//  quest sTag.
string GetQuestScriptOnAccept(int nQuestID);
string GetQuestScriptOnAdvance(int nQuestID);
string GetQuestScriptOnComplete(int nQuestID);
string GetQuestScriptOnFail(int nQuestID);
void SetQuestScriptOnAccept(int nQuestID, string sScript = "");
void SetQuestScriptOnAdvance(int nQuestID, string sScript = "");
void SetQuestScriptOnComplete(int nQuestID, string sScript = "");
void SetQuestScriptOnFail(int nQuestID, string sScript = "");

// ---< RunQuestScript >---
// Runs the assigned quest script for quest nQuestID and nScriptType with oPC
// as OBJECT_SELF.
// TODO script type constants
void RunQuestScript(object oPC, int nQuestID, int nScriptType);

// ---< [Get|Set]QuestStepOrder >---
// Gets or sets the quest step order for quest sTag to nOrder.
// nOrder can be:
//  QUEST_STEP_ORDER_SEQUENTIAL
//  QUEST_STEP_ORDER_NONSEQUENTIAL
int GetQuestStepOrder(int nQuestID);
void SetQuestStepOrder(int nQuestID, int nOrder = QUEST_STEP_ORDER_SEQUENTIAL);

// ---< [Get|Set]QuestTimeLimit >---
// Gets or sets the quest time limit for quest sQuestTag to sTime.  sTime is a time
// difference vector retrieved with util_i_time.
string GetQuestTimeLimit(int nQuestID);
void SetQuestTimeLimit(int nQuestID, string sTime);

// ---< [Get|Set]QuestCooldown >---
// Gets or sets the quest cooldown for quest sQuestTag to sTime.  sTime is a time
// difference vector retrieved with util_i_time.  Cooldown is the minimum amount of time that
// must elapse before a player can repeat a repeatable quest.
string GetQuestCooldown(int nQuestID);
void SetQuestCooldown(int nQuestID, string sTime);

// ---< SetQuestPrerequisite[Alignment|Class|Gold|Item|LevelMax|LevelMin|Quest|QuestStep|Race] >---
// Sets a prerequisite for a PC to be able to be assigned a quest.  Prerequisites are used by
//  GetIsQuestAssignable() to determine if a PC is eligible to be assigned quest sTag
void SetQuestPrerequisiteAlignment(int nQuestID, int nKey, int nValue = FALSE);
void SetQuestPrerequisiteClass(int nQuestID, int nKey, int nValue = -1);
void SetQuestPrerequisiteGold(int nQuestID, int nValue = 1);
void SetQuestPrerequisiteItem(int nQuestID, string sKey, int nValue = 1);
void SetQuestPrerequisiteLevelMax(int nQuestID, int nValue);
void SetQuestPrerequisiteLevelMin(int nQuestID, int nValue);
void SetQuestPrerequisiteQuest(int nQuestID, string sKey, int nValue = 0);
void SetQuestPrerequisiteRace(int nQuestID, int nKey, int nValue = TRUE);

// ---< AddQuestStep >---
// Adds a new quest step to quest sTag with Journal Entry sJournalEntry.  The quest
//  step's journal entry can be added at a later time with SetQuestStepJournalEntry().
//  Returns the new quest step for use in assigning quest step variables.
int AddQuestStep(int nQuestID, string sJournalEntry = "", int nID = -1);

// ---< [Get|Set]QuestStepJournalEntry >---
// Gets or sets the journal entry associated with nStep of quest sTag
string GetQuestStepJournalEntry(int nQuestID, int nStep);
void SetQuestStepJournalEntry(int nQuestID, int nStep, string sJournalEntry);

// ---< [Get|Set]QuestTimeLimit >---
// Gets or sets nStep's time limit for quest sQuestTag to sTime.  sTime is a time
// difference vector retrieved with util_i_time.
string GetQuestStepTimeLimit(int nQuestID, int nStep);
void SetQuestStepTimeLimit(int nQuestID, int nStep, string sTime = "");

// ---< [Get|Set]QuestStepPartyCompletion >---
// Gets or sets the ability to allow party members to help complete quest steps
int GetQuestStepPartyCompletion(int nQuestID, int nStep);
void SetQuestStepPartyCompletion(int nQuestID, int nStep, int nParty);

// ---< [AddQuestResolution[Success|Fail] >---
// Adds the final quest step to quest nQuestID.
int AddQuestResolutionSuccess(int nQuestID, string sJournalEntry = "", int nStep = -1);
int AddQuestResolutionFail(int nQuestID, string sJournalEntry = "", int nStep = -1);

// ---< SetQuestStepObjective[Kill|Gather|Deliver|Discover|Speak] >---
// Sets the objective type for a specified quest step
void SetQuestStepObjectiveKill(int nQuestID, int nStep, string sKey, int nValue = 1);
void SetQuestStepObjectiveGather(int nQuestID, int nStep, string sKey, int nValue = 1);
void SetQuestStepObjectiveDeliver(int nQuestID, int nStep, string sKey, string sValue);
void SetQuestStepObjectiveDiscover(int nQuestID, int nStep, string sKey, int nValue = 1);
void SetQuestStepObjectiveSpeak(int nQuestID, int nStep, string sKey, int nValue = 1);

// ---< SetQuestStep[Preward|Reward][Alignment|Gold|Item|XP] >---
// Sets nStep's preward or reward
void SetQuestStepPrewardAlignment(int nQuestID, int nStep, int nKey, int nValue);
void SetQuestStepPrewardGold(int nQuestID, int nStep, int nValue);
void SetQuestStepPrewardItem(int nQuestID, int nStep, string sKey, int nValue = 1);
void SetQuestStepPrewardXP(int nQuestID, int nStep, int nValue);
void SetQuestStepPrewardMessage(int nQuestID, int nStep, string sValue);
void SetQuestStepRewardAlignment(int nQuestID, int nStep, int nKey, int nValue);
void SetQuestStepRewardGold(int nQuestID, int nStep, int nValue);
void SetQuestStepRewardItem(int nQuestID, int nStep, string sKey, int nValue = 1);
void SetQuestStepRewardXP(int nQuestID, int nStep, int nValue);
void SetQuestStepRewardMessage(int nQuestID, int nStep, string sValue);

// ---< GetIsQuestAssignable >---
// Returns whether oPC meets all prerequisites for quest sTag.  If nStep is passed,
// will evaluate reprequisites for a specific step.  Quest prerequisites can only
// be satisfied by the PC object, not party members.
int GetIsQuestAssignable(object oPC, string sTag);

// ---< [Un]AssignQuest >---
// Assigns or unassigns quest sTag to player object oPC.  Does not check for quest elgibility. 
// GetIsQuestAssignable() should be run before calling this procedure to ensure the PC
// meets all prerequisites for quest assignment.
void AssignQuest(object oPC, string sQuestTag);
void UnassignQuest(object oPC, int nQuestID);

// ---< AdvanceQuest >---
// Called from the internal function that checks quest progress, this function can be called
// on its own to force-advance the quest by one step regardless of whether the PC completed
// the current step.
void AdvanceQuest(object oPC, int nQuestID, int nRequestType = QUEST_ADVANCE_SUCCESS);

// ---< SignalQuestStepProgress >---
// Called from module/game object scripts to signal the quest system to advance the quest, if
// the PC has completed all required objectives for the current step.
void SignalQuestStepProgress(object oPC, object oTarget, int nObjectiveType);

// ---< GetCurrentQuest[Step] >---
// Global accessors to retrieve the current quest tag and step number when quest scripts are
// running.
string GetCurrentQuest();
int GetCurrentQuestStep();

// ---< [Get|Set|Delete]Quest[Int|String] >---
// Gets|Sets|Deletes a variable from a database table associated with nQuestID.  These variables
// are stored in a module-level sqlite database table and associated with the quest, so it's
// a good place to store random variables that you want to save to the quest.  Currently only
// implemented with Ints and Strings.
int GetQuestInt(string sTag, string sVarName);
void SetQuestInt(string sTag, string sVarName, int nValue);
void DeleteQuestInt(string sTag, string sVarName);

string GetQuestString(string sTag, string sVarName);
void SetQuestString(string sTag, string sVarName, string sValue);
void DeleteQuestString(string sTag, string sVarName);

// -----------------------------------------------------------------------------
//                          Private Function Definitions
// -----------------------------------------------------------------------------

string _GetPCQuestData(object oPC, int nQuestID, string sField)
{
    string sResult, sQuestTag = GetQuestTag(nQuestID);

    string sQuery = "SELECT " + sField + " " +
                    "FROM quest_pc_data " +
                    "WHERE quest_tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);

    if (SqlStep(sql))
        sResult = SqlGetString(sql, 0);

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        HandleSqlDebugging(sql, "SQL:retrieve-field", IntToString(nQuestID),
            sField, PCToString(oPC), sResult);

    return sResult;
    //return (SqlStep(sql) ? SqlGetString(sql, 0) : "");
}

void _SetPCQuestData(object oPC, int nQuestID, string sField, string sValue)
{
    string sResult, sQuestTag = GetQuestTag(nQuestID);
    string sQuery = "UPDATE quest_pc_data " +
                    "SET " + sField + " = @value " +
                    "WHERE quest_tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@value", sValue);
    SqlBindString(sql, "@tag", sQuestTag);
    
    SqlStep(sql);

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        HandleSqlDebugging(sql, "SQL:set-field", IntToString(nQuestID),
            sField, PCToString(oPC), sValue);
}

// Should only be called after the quest has been created
// Done
void _SetQuestData(int nQuestID, string sField, string sValue)
{
    if (nQuestID == 0)
    {
        QuestError("Attempt to set quest data when quest does not exist" +
              "\n  Quest ID -> " + IntToString(nQuestID) +
              "\n  Field    -> " + sField +
              "\n  Value    -> " + sValue);
        return;
    }

    string sQuery = "UPDATE quest_quests " +
                    "SET " + sField + " = @sValue " +
                    "WHERE id = @id;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindString(sql, "@sValue", sValue);
    SqlBindInt(sql, "@id", nQuestID);
    SqlStep(sql);

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        HandleSqlDebugging(sql, "SQL:set-field", IntToString(nQuestID),
            sField, "module", sValue);
}

// Done
string _GetQuestData(int nQuestID, string sField)
{
    string sQuery = "SELECT " + sField + " " +
                    "FROM quest_quests " +
                    "WHERE id = @id;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);

    string sResult;
    if (SqlStep(sql))
        sResult = SqlGetString(sql, 0);

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        HandleSqlDebugging(sql, "SQL:retrieve-field", IntToString(nQuestID),
            sField, "module", sResult);

    return sResult;
    //return SqlStep(sql) ? SqlGetString(sql, 0) : "";
}

// Done
void _SetQuestVariable(int nQuestID, string sType, string sVarName, string sValue)
{
    // Don't create the table unless we need it
    CreateQuestVariablesTable();

    string sQuery = "INSERT INTO quest_variables (quests_id, sType, sName, sValue) " +
                    "VALUES (@id, @type, @name, @value);";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindString(sql, "@type", sType);
    SqlBindString(sql, "@name", sVarName);
    SqlBindString(sql, "@value", sValue);

    SqlStep(sql);
}

// Done
string _GetQuestVariable(int nQuestID, string sType, string sVarName)
{
    string sQuery = "SELECT sValue FROM quest_variables " +
                    "WHERE quests_id = @id " +
                        "AND sType = @type " +
                        "AND sName = @name;";

    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindString(sql, "@type", sType);
    SqlBindString(sql, "@name", sVarName);

    return (SqlStep(sql) ? SqlGetString(sql, 0) : "");
}

// Done
void _DeleteQuestVariable(int nQuestID, string sType, string sVarName)
{
    string sQuery = "DELETE FROM quest_variables " +
                    "WHERE quests_id = @id " +
                        "AND sPropertyType = @type " +
                        "AND sPropertyName = @name;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindString(sql, "@type", sType);
    SqlBindString(sql, "@name", sVarName);

    SqlStep(sql);
}

// Accessors for quest variables  -- All Done
void SetQuestInt(string sTag, string sVarName, int nValue)
{
    int nQuestID = GetQuestID(sTag);
    if (nQuestID == 0 || sVarName == "")
        return;

    _SetQuestVariable(nQuestID, "INT", sVarName, IntToString(nValue));
}

int GetQuestInt(string sTag, string sVarName)
{
    int nQuestID = GetQuestID(sTag);
    if (nQuestID == 0 || sVarName == "")
        return 0;

    return StringToInt(_GetQuestVariable(nQuestID, "INT", sVarName));
}

void DeleteQuestInt(string sTag, string sVarName)
{
    int nQuestID = GetQuestID(sTag);
    if (nQuestID == 0 || sVarName == "")
        return;

    _DeleteQuestVariable(nQuestID, "INT", sVarName);
}

void SetQuestString(string sTag, string sVarName, string sValue)
{
    int nQuestID = GetQuestID(sTag);
    if (nQuestID == 0 || sVarName == "")
        return;

    _SetQuestVariable(nQuestID, "STRING", sVarName, sValue);
}

string GetQuestString(string sTag, string sVarName)
{
    int nQuestID = GetQuestID(sTag);
    if (nQuestID == 0 || sVarName == "")
        return "";

    return _GetQuestVariable(nQuestID, "STRING", sVarName);
}

void DeleteQuestString(string sTag, string sVarName)
{
    int nQuestID = GetQuestID(sTag);
    if (nQuestID == 0 || sVarName == "")
        return;

    _DeleteQuestVariable(nQuestID, "STRING", sVarName);
}
// Not planning on other types, this is probably of limited use anyway.
// End accessors for quest variables

// Set quest step data // done
void _SetQuestStepData(int nQuestID, int nStep, string sField, string sValue)
{
    string sQuery = "UPDATE quest_steps " +
                    "SET " + sField + " = @value " +
                    "WHERE quests_id = @id " +
                        "AND nStep = @nStep;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@nStep", nStep);
    SqlBindString(sql, "@value", sValue);

    SqlStep(sql);

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        HandleSqlDebugging(sql, "SQL:set-step", IntToString(nQuestID),
            IntToString(nStep), sField, sValue);
}

// done
string _GetQuestStepData(int nQuestID, int nStep, string sField)
{
    string sQuery = "SELECT " + sField + " " +
                    "FROM quest_steps " +
                    "WHERE quests_id = @id " +
                        "AND nStep = @step;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@step", nStep);
    
    string sResult;
    if (SqlStep(sql))
        sResult = SqlGetString(sql, 0);

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        HandleSqlDebugging(sql, "SQL:retrieve-step", IntToString(nQuestID),
            IntToString(nStep), sField, sResult);

    return sResult;
    //return SqlStep(sql) ? SqlGetString(sql, 0) : "";
}

//done
int _GetIsPropertyStackable(int nPropertyType)
{
    if (nPropertyType == QUEST_VALUE_GOLD ||
        nPropertyType == QUEST_VALUE_LEVEL_MAX ||
        nPropertyType == QUEST_VALUE_LEVEL_MIN ||
        nPropertyType == QUEST_VALUE_XP)
        return FALSE;
    else
        return TRUE;
}

//done
void _SetQuestStepProperty(int nQuestID, int nStep, int nCategoryType, 
                           int nValueType, string sKey, string sValue)
{
    // If an objective, must the same type as the rest of the objectives, if any
    if (nCategoryType == QUEST_CATEGORY_OBJECTIVE)
    {
        int nCurrentType = GetQuestStepObjectiveType(nQuestID, nStep);
        if (nCurrentType != 0)
        {
            if (nValueType != nCurrentType)
            {
                QuestError("Attempted to add an objective type that is not the same as " +
                    "current objective types" +
                    "\n  Quest ID -> " + IntToString(nQuestID) +
                    "\n  Step -> " + IntToString(nStep) +
                    "\n  Category Type -> Objective" +
                    "\n  Value Type -> " + IntToString(nValueType) +
                    "\n  Key -> " + sKey +
                    "\n  Value -> " + sValue);
                return;
            }
        }
    }
    else    // If it's not stackable, delete the previous record and replace
    {
        if (_GetIsPropertyStackable(nValueType) == FALSE)
            DeleteQuestStepPropertyPair(nQuestID, nStep, nCategoryType, nValueType);
    }

    string sQuery = "INSERT INTO quest_step_properties " +
                        "(quest_steps_id, nCategoryType, nValueType, sKey, sValue) " +
                    "VALUES (@step_id, @category, @type, @key, @value);";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@step_id", GetQuestStepID(nQuestID, nStep));
    SqlBindInt(sql, "@type", nValueType);
    SqlBindInt(sql, "@category", nCategoryType);
    SqlBindString(sql, "@key", sKey);
    SqlBindString(sql, "@value", sValue);

    SqlStep(sql);

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        HandleSqlDebugging(sql, "SQL:set-step-property", IntToString(nQuestID),
            IntToString(nStep), IntToString(nCategoryType), IntToString(nValueType),
            sKey, sValue);
}

// Private accessor for setting quest step objectives
void _SetQuestObjective(int nQuestID, int nStep, int nValueType, string sKey, string sValue)
{
    int nCategoryType = QUEST_CATEGORY_OBJECTIVE;
    _SetQuestStepProperty(nQuestID, nStep, nCategoryType, nValueType, sKey, sValue);
}

// Private accessor for setting quest step prewards
void _SetQuestPreward(int nQuestID, int nStep, int nValueType, string sKey, string sValue)
{
    int nCategoryType = QUEST_CATEGORY_PREWARD;
    _SetQuestStepProperty(nQuestID, nStep, nCategoryType, nValueType, sKey, sValue);
}

// Private accessor for setting quest step rewards
void _SetQuestReward(int nQuestID, int nStep, int nValueType, string sKey, string sValue)
{
    int nCategoryType = QUEST_CATEGORY_REWARD;
    _SetQuestStepProperty(nQuestID, nStep, nCategoryType, nValueType, sKey, sValue);
}

void _AssignQuest(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    if (GetPCHasQuest(oPC, sQuestTag))
    {
        DeletePCQuestProgress(oPC, nQuestID);
        _SetPCQuestData(oPC, nQuestID, QUEST_PC_STEP, "0");
        _SetPCQuestData(oPC, nQuestID, QUEST_PC_STEP_TIME, "");
    }
    else
        _AddQuestToPC(oPC, nQuestID);

    // Set the quest start time
    _SetPCQuestData(oPC, nQuestID, QUEST_PC_QUEST_TIME, GetSystemTime());
    
    RunQuestScript(oPC, nQuestID, QUEST_SCRIPT_TYPE_ON_ACCEPT);
    // Go to the first step
    AdvanceQuest(oPC, nQuestID);

    QuestDebug(PCToString(oPC) + " has been assigned quest " + QuestToString(nQuestID));
}

// Checks to see if oPC or their party members have at least nMinQuantity of sItemTag
int _HasMinimumItemCount(object oPC, string sItemTag, int nMinQuantity = 1, int bIncludeParty = FALSE)
{
    int bHasMinimum = FALSE;

    int nItemCount = 0;
    object oItem = GetItemPossessedBy(oPC, sItemTag);
    if (GetIsObjectValid(oItem))
    {
        oItem = GetFirstItemInInventory(oPC);
        while (GetIsObjectValid(oItem))
        {
            if (GetTag(oItem) == sItemTag)
                nItemCount += GetNumStackedItems(oItem);

            if (nItemCount >= nMinQuantity)
            {
                bHasMinimum = TRUE;
                break;
            }

            oItem = GetNextItemInInventory(oPC);
        }
    }

    // We haven't met the minimum yet, so let's check the other party members.
    if (bIncludeParty && !bHasMinimum)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            oItem = GetItemPossessedBy(oPC, sItemTag);
            if (GetIsObjectValid(oItem))
            {
                oItem = GetFirstItemInInventory(oPartyMember);
                while (GetIsObjectValid(oItem))
                {
                    if (GetTag(oItem) == sItemTag)
                        nItemCount += GetItemStackSize(oItem);
                    
                    if (nItemCount >= nMinQuantity)
                    {
                        bHasMinimum = TRUE;
                        break;
                    }

                    oItem = GetNextItemInInventory(oPartyMember);
                }
            }

            if (bHasMinimum) break;
            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
    {
        if (bHasMinimum)
            QuestDebug("Minimum Item Count: " + PCToString(oPC) + " and party members " +
                "have at least " + IntToString(nMinQuantity) + " " + sItemTag);
        else
            QuestDebug("Minimum Item Count: " + PCToString(oPC) + " and party members " +
                "only have " + IntToString(nItemCount) + " of the required " +
                IntToString(nMinQuantity) + " " + sItemTag);
    }

    return bHasMinimum;
}

int GetPCItemCount(object oPC, string sItemTag)
{
    int nItemCount = 0;
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (GetStringLowerCase(GetTag(oItem)) == GetStringLowerCase(sItemTag))
            nItemCount += GetNumStackedItems(oItem);
        oItem = GetNextItemInInventory(oPC);
    }

    QuestDebug("Found " + IntToString(nItemCount) + " " + sItemTag + " on " +
        PCToString(oPC));

    return nItemCount;
}

// Awards gold to oPC and/or their party members
void _AwardGold(object oPC, int nGold, int bParty = FALSE)
{
    if (bParty)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            if (nGold < 0)
                TakeGoldFromCreature(abs(nGold), oPartyMember, TRUE);
            else
                GiveGoldToCreature(oPartyMember, nGold);
            
            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }
    else
    {
        if (nGold < 0)
            TakeGoldFromCreature(abs(nGold), oPC, TRUE);
        else
            GiveGoldToCreature(oPC, nGold);
    }

    QuestDebug((nGold < 0 ? "Removing " : "Awarding ") + IntToString(nGold) +
        "gp " + (nGold < 0 ? "from " : "to ") + PCToString(oPC) +
        (bParty ? " and party members" : ""));
}

// Awards XP to oPC and/or their party members
void _AwardXP(object oPC, int nXP, int bParty = FALSE)
{
    if (bParty)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            SetXP(oPartyMember, GetXP(oPartyMember) + nXP);
            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }
    else
        SetXP(oPC, GetXP(oPC) + nXP);

    QuestDebug((nXP < 0 ? "Removing " : "Awarding ") + IntToString(nXP) +
        "xp " + (nXP < 0 ? "from " : "to ") + PCToString(oPC) +
        (bParty ? " and party members" : ""));
}

void _AwardQuest(object oPC, int nQuestID, int nFlag = TRUE, int bParty = FALSE)
{
    int nAssigned, nComplete;
    string sQuestTag = GetQuestTag(nQuestID);

    if (bParty)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            nAssigned = GetPCHasQuest(oPartyMember, sQuestTag);
            nComplete = GetIsPCQuestComplete(oPartyMember, nQuestID);

            if (nFlag)
            {
                if (!nAssigned || (nAssigned && nComplete))
                    _AssignQuest(oPartyMember, nQuestID);
            }
            else
                UnassignQuest(oPartyMember, nQuestID);
            
            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }
    else
    {
        nAssigned = GetPCHasQuest(oPC, sQuestTag);
        nComplete = GetIsPCQuestComplete(oPC, nQuestID);

        if (nFlag)
        {
            if (!nAssigned || (nAssigned && nComplete))
                _AssignQuest(oPC, nQuestID);
        }
        else
            UnassignQuest(oPC, nQuestID);
    }

    QuestDebug("Awarding quest " + QuestToString(nQuestID) +
        " to " + PCToString(oPC) +
        (bParty ? " and party members" : ""));
}

// Awards item(s) to oPC and/or their party members
void _AwardItem(object oPC, string sResref, int nQuantity, int bParty = FALSE)
{
    int nCount;
    object oItem;

    if (bParty)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);

        while (GetIsObjectValid(oPartyMember))
        {
            nCount = nQuantity;
            if (nCount < 0)
            {
                while (nCount < 0)
                {
                    oItem = GetItemPossessedBy(oPartyMember, sResref);
                    DestroyObject(oItem);
                    nCount++;
                }
            }
            else
                CreateItemOnObject(sResref, oPartyMember, nQuantity);

            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }
    else
    {
        nCount = nQuantity;
        if (nCount < 0)
        {
            while (nCount < 0)
            {
                oItem = GetItemPossessedBy(oPC, sResref);
                DestroyObject(oItem);
                nCount++;
            }
        }
        else
            CreateItemOnObject(sResref, oPC, nQuantity);
    }

    QuestDebug((nQuantity < 0 ? "Removing " : "Awarding ") + "item " + sResref + 
        " (" + IntToString(abs(nQuantity)) + ") " +
        (nQuantity < 0 ? "from " : "to ") + PCToString(oPC) +
        (bParty ? " and party members" : ""));
}

// Awards alignment shift to oPC and/or their party members
void _AwardAlignment(object oPC, int nAxis, int nShift, int bParty = FALSE)
{
    if (bParty)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            AdjustAlignment(oPartyMember, nAxis, nShift, FALSE);
            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }
    else
        AdjustAlignment(oPC, nAxis, nShift, FALSE);

    QuestDebug("Awarding alignment shift of " + IntToString(nShift) +
        " on alignment axis " + AlignmentAxisToString(nAxis) + " to " +
        PCToString(oPC) + (bParty ? " and party members" : ""));
}

// Awards quest sTag step nStep [p]rewards.  The awards type will be limited by nAwardType and can be
// provided to the entire party with bParty.  nCategoryType is a QUEST_CATEGORY_* constant.
void _AwardQuestStepAllotments(object oPC, int nQuestID, int nStep, int nCategoryType, 
                               int nAwardType = AWARD_ALL, int bParty = FALSE)
{
    int nValueType, nAllotmentCount;
    string sKey, sValue;

    QuestDebug("Awarding quest step allotments for " + QuestToString(nQuestID) +
        " " + StepToString(nStep) + " of type " + CategoryTypeToString(nCategoryType) +
        " to " + PCToString(oPC));

    sqlquery sPairs = GetQuestStepPropertySets(nQuestID, nStep, nCategoryType);
    while (SqlStep(sPairs))
    {
        nAllotmentCount++;
        nValueType = SqlGetInt(sPairs, 0);
        sKey = SqlGetString(sPairs, 1);
        sValue = SqlGetString(sPairs, 2);

        QuestDebug("  " + HexColorString("Allotment #" + IntToString(nAllotmentCount), COLOR_CYAN) + " " +
            "  Value Type -> " + ValueTypeToString(nValueType));            

        switch (nValueType)
        {
            case QUEST_VALUE_GOLD:
            {
                if ((nAwardType && AWARD_GOLD) || nAwardType == AWARD_ALL)
                {
                    int nGold = StringToInt(sValue);
                    _AwardGold(oPC, nGold, bParty);
                }
                continue;
            }
            case QUEST_VALUE_XP:
            {
                if ((nAwardType && AWARD_XP) || nAwardType == AWARD_ALL)
                {
                    int nXP = StringToInt(sValue);
                    _AwardXP(oPC, nXP, bParty);
                }
                continue;
            }
            case QUEST_VALUE_ALIGNMENT:
            {
                if ((nAwardType && AWARD_ALIGNMENT) || nAwardType == AWARD_ALL)
                {
                    int nAxis = StringToInt(sKey);
                    int nShift = StringToInt(sValue);
                    _AwardAlignment(oPC, nAxis, nShift, bParty);
                }
                continue;
            }  
            case QUEST_VALUE_ITEM:
            {
                if ((nAwardType && AWARD_ITEM) || nAwardType == AWARD_ALL)
                {
                    string sResref = sKey;     
                    int nQuantity = StringToInt(sValue);
                    _AwardItem(oPC, sResref, nQuantity, bParty);
                }
                continue;
            }
            case QUEST_VALUE_QUEST:
            {
                if ((nAwardType && AWARD_QUEST) || nAwardType == AWARD_ALL)
                {
                    int nValue = StringToInt(sValue);
                    int nFlag = StringToInt(sValue);
                    _AwardQuest(oPC, nValue, nFlag, bParty);
                }
                continue;
            }
            case QUEST_VALUE_MESSAGE:
            {
                if ((nAwardType && AWARD_MESSAGE) || nAwardType == AWARD_ALL)
                {
                    string sMessage = HexColorString(sValue, COLOR_CYAN);
                    SendMessageToPC(oPC, sMessage);
                }
                continue;
            }
        }
    }

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
    {
        QuestDebug("Found " + IntToString(nAllotmentCount) + " allotments for " + QuestToString(nQuestID) + " " + StepToString(nStep) +
            (nAllotmentCount > 0 ?          
                "\n  Category -> " + CategoryTypeToString(nCategoryType) +
                "\n  Award -> " + AwardTypeToString(nAwardType) : ""));
        
        if (nAllotmentCount > 0)
            QuestDebug("Awarded " + IntToString(nAllotmentCount) + " allotments to " + PCToString(oPC) + (bParty ? " and party members" : ""));
        else
            QuestDebug("No allotments to award, no action taken");
    }
}

// -----------------------------------------------------------------------------
//                          Public Function Definitions
// -----------------------------------------------------------------------------

int AddQuest(string sQuestTag, string sTitle = "")
{
    if (GetQuestExists(sQuestTag) == TRUE || sQuestTag == "")
        return FALSE;
    
    int nQuestID = _AddQuest(sQuestTag, sTitle);
    if (nQuestID == -1)
        QuestError(QuestToString(nQuestID) + " could not be created");
    else
        QuestDebug(QuestToString(nQuestID) + " has been created with questID " + IntToString(nQuestID));

    return nQuestID;
    //return _AddQuest(sQuestTag, sTitle);
}

//done
int AddQuestStep(int nQuestID, string sJournalEntry = "", int nStep = -1)
{   
    // Steps must be created in order of sending a custom step id (i.e. if using existing
    // journal entries).
    if (nStep == -1)
        nStep = CountQuestSteps(nQuestID) + 1;

    _AddQuestStep(nQuestID, sJournalEntry, nStep);
    return nStep;
}

int GetIsQuestAssignable(object oPC, string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    int bAssignable = FALSE;
    string sError, sErrors;

    QuestDebug("Checking if " + PCToString(oPC) + " meets prerequisites for " + 
        QuestToString(nQuestID));

    if (CountQuestSteps(nQuestID) > 0)
        QuestDebug(QuestToString(nQuestID) + " has the minimum number of steps");
    else
        QuestError(QuestToString(nQuestID) + " does not have any steps and cannot " +
            "be assigned");

    if (GetPCHasQuest(oPC, sQuestTag) == TRUE)
    {
        if (GetIsPCQuestComplete(oPC, nQuestID))
        {
            string sCompleteTime, sCooldownTime = _GetQuestData(nQuestID, QUEST_COOLDOWN);
            if (sCooldownTime == "")
            {
                QuestDebug("There is no cooldown time for this quest");
                bAssignable = TRUE;
            }
            else
            {
                sCompleteTime = _GetPCQuestData(oPC, nQuestID, QUEST_PC_LAST_COMPLETE);
                sCompleteTime = AddSystemTimeVector(sCompleteTime, sCooldownTime);
                if (GetMinSystemTime(sCompleteTime) == sCompleteTime)
                {
                    QuestDebug(PCToString(oPC) + " has met the required cooldown time");
                    bAssignable = TRUE;
                }
                else
                {
                    QuestDebug(PCToString(oPC) + " has not met the required cooldown time" +
                        "for this quest");
                    sErrors = AddListItem(sErrors, "COOLDOWN TIME");
                }
            }
        }
        else
        {
            QuestDebug(PCToString(oPC) + " is still completing this quest, it cannot be " +
                "reassigned until the current attempt is complete");
            sErrors = AddListItem(sErrors, "QUEST COMPLETION");
        }
    }
    else
    {
        QuestDebug(PCToString(oPC) + " does not have " + QuestToString(nQuestID) + " assigned");
        bAssignable = TRUE;
    }

    // If there are no quest prerequisites, allow the assignment
    if (CountQuestPrerequisites(nQuestID) == 0)
    {
        QuestDebug("Quest prerequisites for " + QuestToString(nQuestID) + " not found");
        return TRUE;
    }
    else
        QuestDebug("Found " + IntToString(CountQuestPrerequisites(nQuestID)) + " prerequisites for " + QuestToString(nQuestID));

    sqlquery sqlPrerequisites = GetQuestPrerequisiteTypes(nQuestID);
    while (SqlStep(sqlPrerequisites))
    {
        int nValueType = SqlGetInt(sqlPrerequisites, 0);
        int nTypeCount = SqlGetInt(sqlPrerequisites, 1);

        QuestDebug(HexColorString("Checking quest prerequisite " + ValueTypeToString(nValueType) + " " + IntToString(nTypeCount), COLOR_CYAN));

        if (_GetIsPropertyStackable(nValueType) == FALSE && nTypeCount > 1)
        {
            QuestError("GetIsQuestAssignable found multiple entries for a " +
                "non-stackable property" +
                "\n  Quest ID -> " + IntToString(nQuestID) +
                "\n  Quest Tag -> " + GetQuestTag(nQuestID) +
                "\n  Category -> " + CategoryTypeToString(QUEST_CATEGORY_PREREQUISITE) +
                "\n  Value -> " + ValueTypeToString(nValueType) +
                "\n  Entries -> " + IntToString(nTypeCount));
            return FALSE;
        }

        sqlquery sqlPrerequisitesByType = GetQuestPrerequisitesByType(nQuestID, nValueType);
        switch (nValueType)
        {
            case QUEST_VALUE_ALIGNMENT:
            {
                int nAxis, bNeutral, bQualifies;
                int nGE = GetAlignmentGoodEvil(oPC);
                int nLC = GetAlignmentLawChaos(oPC);
                
                QuestDebug("  PC Good/Evil Alignment -> " + AlignmentAxisToString(nGE) +
                     "\n  PC Law/Chaos Alignment -> " + AlignmentAxisToString(nLC));                

                while (SqlStep(sqlPrerequisitesByType))
                {
                    nAxis = SqlGetInt(sqlPrerequisitesByType, 0);
                    bNeutral = SqlGetInt(sqlPrerequisitesByType, 1);

                    QuestDebug("  ALIGNMENT | " + AlignmentAxisToString(nAxis) + " | " + (bNeutral ? "TRUE":"FALSE"));

                    if (bNeutral == TRUE)
                    {
                        if (nGE == ALIGNMENT_NEUTRAL ||
                            nLC == ALIGNMENT_NEUTRAL)
                            bQualifies = TRUE;
                    }
                    else
                    {
                        if (nGE == nAxis || nLC == nAxis)
                            bQualifies = TRUE;
                    }
                }

                QuestDebug("  ALIGNMENT resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_CLASS:
            {
                int nClass, nLevels, bQualifies;
                int nClass1 = GetClassByPosition(1, oPC);
                int nClass2 = GetClassByPosition(2, oPC);
                int nClass3 = GetClassByPosition(3, oPC);
                int nLevels1 = GetLevelByClass(nClass1, oPC);
                int nLevels2 = GetLevelByClass(nClass2, oPC);
                int nLevels3 = GetLevelByClass(nClass3, oPC);
                
                QuestDebug("  PC Classes -> " + ClassToString(nClass1) + " (" + IntToString(nLevels1) + ")" +
                    (nClass2 == CLASS_TYPE_INVALID ? "" : " | " + ClassToString(nClass2) + " (" + IntToString(nLevels2) + ")") +
                    (nClass3 == CLASS_TYPE_INVALID ? "" : " | " + ClassToString(nClass3) + " (" + IntToString(nLevels3) + ")"));

                while (SqlStep(sqlPrerequisitesByType))
                {
                    nClass = SqlGetInt(sqlPrerequisitesByType, 0);
                    nLevels = SqlGetInt(sqlPrerequisitesByType, 1);

                    QuestDebug("  CLASS | " + ClassToString(nClass) + " | Levels " + IntToString(nLevels));

                    switch (nLevels)
                    {
                        case 0:   // No levels in specific class
                            if (nClass1 == nClass || nClass2 == nClass || nClass3 == nClass)
                            {
                                bQualifies = FALSE;
                                break;
                            }

                            QuestDebug("  Setting assigability by exclusion check");
                            bQualifies = TRUE;
                            break;
                        default:  // Specific number or more of levels in a specified class
                            if (nClass1 == nClass && nLevels1 >= nLevels)
                                bQualifies = TRUE;
                            else if (nClass2 == nClass && nLevels2 >= nLevels)
                                bQualifies = TRUE;
                            else if (nClass3 == nClass && nLevels3 >= nLevels)
                                bQualifies = TRUE;
                            
                            QuestNotice("  Setting assigability by inclusion check");
                            break;
                    }
                }

                QuestDebug("  CLASS resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_FACTION:   // TODO
                // Not yet implemented
                break;
            case QUEST_VALUE_GOLD:
            {
                SqlStep(sqlPrerequisitesByType);
                int bQualifies, nGoldRequired = SqlGetInt(sqlPrerequisitesByType, 1);
                
                QuestDebug("  PC Gold Balance -> " + IntToString(GetGold(oPC)));
                QuestDebug("  GOLD | " + IntToString(nGoldRequired));
                
                if (GetGold(oPC) >= nGoldRequired)
                    bQualifies = TRUE;

                QuestDebug("  GOLD resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_ITEM:
            {
                string sItemTag;
                int nItemQuantity, bQualifies;

                while (SqlStep(sqlPrerequisitesByType))
                {
                    sItemTag = SqlGetString(sqlPrerequisitesByType, 0);
                    nItemQuantity = SqlGetInt(sqlPrerequisitesByType, 1);

                    QuestDebug("  ITEM | " + sItemTag + " | " + IntToString(nItemQuantity));

                    int nItemCount = GetPCItemCount(oPC, sItemTag);
                    QuestDebug("  PC has " + IntToString(nItemCount) + " " + sItemTag);
                    
                    if (nItemQuantity == 0 && nItemCount > 0)
                    {
                        bQualifies = FALSE;
                        break;
                    }
                    else if (nItemQuantity > 0 && nItemCount >= nItemQuantity)
                        bQualifies = TRUE;
                }

                QuestDebug("  ITEM resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_LEVEL_MAX:
            {
                SqlStep(sqlPrerequisitesByType);
                int bQualifies, nMaximumLevel = SqlGetInt(sqlPrerequisitesByType, 1);

                QuestDebug("  PC Total Levels -> " + IntToString(GetHitDice(oPC)));
                QuestDebug("  LEVEL_MAX | " + IntToString(nMaximumLevel));
                
                if (GetHitDice(oPC) <= nMaximumLevel)
                    bQualifies = TRUE;
                
                QuestDebug("  LEVEL_MAX resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_LEVEL_MIN:
            {
                SqlStep(sqlPrerequisitesByType);
                int bQualifies, nMinimumLevel = SqlGetInt(sqlPrerequisitesByType, 1);
                
                QuestDebug("  PC Total Levels -> " + IntToString(GetHitDice(oPC)));
                QuestDebug("  LEVEL_MIN | " + IntToString(nMinimumLevel));
                
                if (GetHitDice(oPC) >= nMinimumLevel)
                    bQualifies = TRUE;

                QuestDebug("  LEVEL_MAX resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_QUEST:
            {
                string sQuestTag;
                int nRequiredCompletions;
                int bQualifies, bPCHasQuest, nPCCompletions;

                while (SqlStep(sqlPrerequisitesByType))
                {
                    sQuestTag = SqlGetString(sqlPrerequisitesByType, 0);
                    nRequiredCompletions = SqlGetInt(sqlPrerequisitesByType, 1);
                    
                    bPCHasQuest = GetPCHasQuest(oPC, sQuestTag);
                    nPCCompletions = GetPCQuestCompletions(oPC, sQuestTag);
                    QuestDebug("  PC | Has Quest -> " + (bPCHasQuest ? "TRUE":"FALSE") + " | Completions -> " + IntToString(nPCCompletions));
                    QuestDebug("  QUEST | " + sQuestTag + " | Required -> " + IntToString(nRequiredCompletions));

                    if (nRequiredCompletions > 0)
                    {
                        if (bPCHasQuest == TRUE && nPCCompletions >= nRequiredCompletions)
                            bQualifies = TRUE;
                    }
                    else if (nRequiredCompletions == 0)
                    {
                        if (bPCHasQuest == TRUE && nPCCompletions == 0)
                            bQualifies = TRUE;
                    }
                    else if (nRequiredCompletions < 0)
                    {
                        if (bPCHasQuest == TRUE)
                        {
                            bQualifies = FALSE;
                            break;
                        }
                    }
                }

                QuestDebug("  QUEST resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_QUEST_STEP:
            {
                string sQuestTag;
                int nRequiredStep;
                int bQualifies, bPCHasQuest, nPCStep;

                while (SqlStep(sqlPrerequisitesByType))
                {
                    sQuestTag = SqlGetString(sqlPrerequisitesByType, 0);
                    nRequiredStep = SqlGetInt(sqlPrerequisitesByType, 1);

                    QuestDebug("  QUEST_STEP | " + sQuestTag + " | Step -> " + IntToString(nRequiredStep));

                    bPCHasQuest = GetPCHasQuest(oPC, sQuestTag);
                    nPCStep = GetPCQuestStep(oPC, nQuestID);

                    QuestDebug("  PC | Has Quest -> " + (bPCHasQuest ? "TRUE":"FALSE") + " | Step -> " + IntToString(nRequiredStep));

                    if (bPCHasQuest)
                    {
                        if (nPCStep >= nRequiredStep)
                            bQualifies = TRUE;
                    }
                    else
                    {
                        bQualifies = FALSE;
                        break;
                    }
                }

                QuestDebug("  QUEST_STEP resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_RACE:
            {
                int nRace, nPCRace = GetRacialType(oPC);
                int bQualifies, bAllowed;

                QuestDebug("  PC Race -> " + RaceToString(nPCRace));
                
                while (SqlStep(sqlPrerequisitesByType))
                {
                    nRace = SqlGetInt(sqlPrerequisitesByType, 0);
                    bAllowed = SqlGetInt(sqlPrerequisitesByType, 1);

                    QuestDebug("  RACE | " + RaceToString(nRace) + " | Allowed -> " + (bAllowed ? "TRUE":"FALSE"));

                    if (bAllowed == TRUE)
                    {
                        if (nPCRace == nRace)
                            bQualifies = TRUE;
                    }
                    else if (bAllowed == FALSE)
                    {
                        if (nPCRace == nRace)
                        {
                            bQualifies = FALSE;
                            break;
                        }
                        else
                            bQualifies = TRUE;
                    }
                }
                    
                QuestDebug("  RACE resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
        }
    }

    if (sErrors != "")
    {
        int n, nCount = CountList(sErrors);
        string sResult;

        for (n = 0; n < nCount; n++)
        {
            string sError = GetListItem(sErrors, n);
            sResult = AddListItem(sResult, ValueTypeToString(StringToInt(sError)));
        }

        QuestNotice("Quest " + sQuestTag + " could not be assigned to " + PCToString(oPC) +
            "; PC did not meet the following prerequisites: " + sResult);

        return FALSE;
    }
    else
        return TRUE;
}

void AssignQuest(object oPC, string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    _AssignQuest(oPC, nQuestID);
}

void RunQuestScript(object oPC, int nQuestID, int nScriptType)
{
    string sScript, sQuestTag = GetQuestTag(nQuestID);
    int bSetStep = FALSE;

    if (nScriptType == QUEST_SCRIPT_TYPE_ON_ACCEPT)
        sScript = GetQuestScriptOnAccept(nQuestID);
    else if (nScriptType == QUEST_SCRIPT_TYPE_ON_ADVANCE)
    {
        sScript = GetQuestScriptOnAdvance(nQuestID);
        bSetStep = TRUE;
    }
    else if (nScriptType == QUEST_SCRIPT_TYPE_ON_COMPLETE)
        sScript = GetQuestScriptOnComplete(nQuestID);
    else if (nScriptType == QUEST_SCRIPT_TYPE_ON_FAIL)
        sScript = GetQuestScriptOnFail(nQuestID);

    if (sScript == "")
        return;
    
    // Set values that the script has available to it
    SetLocalString(GetModule(), QUEST_CURRENT_QUEST, sQuestTag);
    if (bSetStep)
    {
        int nStep = GetPCQuestStep(oPC, nQuestID);
        SetLocalInt(GetModule(), QUEST_CURRENT_STEP, nStep);
    }

    QuestDebug("Running " + ScriptTypeToString(nScriptType) + " script " +
        " for " + QuestToString(nQuestID) + " on " + PCToString(oPC));
    
    // TODO pick one or the other, library for the framework, execute
    // for standalone
    RunLibraryScript(sScript, oPC);
    //ExecuteScript(sScript, oPC);

    DeleteLocalInt(GetModule(), QUEST_CURRENT_QUEST);
    DeleteLocalInt(GetModule(), QUEST_CURRENT_STEP);
}

void UnassignQuest(object oPC, int nQuestID)
{
    QuestDebug("Unassigning " + QuestToString(nQuestID) + " from " + PCToString(oPC));

    DeletePCQuest(oPC, nQuestID);
    // TODO remove the journal entry?
}

int CountPCQuestCompletions(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);
    return GetPCQuestCompletions(oPC, sQuestTag);
}

void CopyQuestStepObjectiveData(object oPC, int nQuestID, int nStep)
{
    sqlquery sqlStepData = GetQuestStepObjectiveData(nQuestID, nStep);
    while (SqlStep(sqlStepData))
    {
        int nObjectiveType = SqlGetInt(sql, 0);
        string sTag = SqlGetString(sql, 1);
        int nQuantity = SqlGetInt(sql, 2);

        AddQuestStepObjectiveData(oPC, nQuestID, nObjectiveType, sTag, nQuantity);
    }
}

void SendJournalQuestEntry(object oPC, int nQuestID, int nStep)
{
    QuestDebug("Sending " + PCToString(oPC) + " a journal entry for " +
        QuestToString(nQuestID));

    string sTag = GetQuestTag(nQuestID);
    AddJournalQuestEntry(sTag, nStep, oPC, FALSE, FALSE, TRUE);
}

void AdvanceQuest(object oPC, int nQuestID, int nRequestType = QUEST_ADVANCE_SUCCESS)
{
    QuestDebug("Attempting to advance quest " + QuestToString(nQuestID) +
        " for " + PCToString(oPC));

    if (nRequestType == QUEST_ADVANCE_SUCCESS)
    {
        int nCurrentStep = GetPCQuestStep(oPC, nQuestID);
        int nNextStep = GetNextPCQuestStep(nQuestID, nCurrentStep);

        if (nNextStep == -1)
        {
            // Next step is the last step, go to the completion step
            nNextStep = GetQuestCompletionStep(nQuestID);

            DeletePCQuestProgress(oPC, nQuestID);
            SendJournalQuestEntry(oPC, nQuestID, nNextStep);
            _AwardQuestStepAllotments(oPC, nQuestID, nNextStep, QUEST_CATEGORY_REWARD);
            IncrementPCQuestCompletions(oPC, nQuestID);
            ResetPCQuestData(oPC, nQuestID);
            RunQuestScript(oPC, nQuestID, QUEST_SCRIPT_TYPE_ON_COMPLETE);
        }
        else
        {
            DeletePCQuestProgress(oPC, nQuestID);
            CopyQuestStepObjectiveData(oPC, nQuestID, nNextStep);
            SendJournalQuestEntry(oPC, nQuestID, nNextStep);
            _AwardQuestStepAllotments(oPC, nQuestID, nCurrentStep, QUEST_CATEGORY_REWARD);
            _AwardQuestStepAllotments(oPC, nQuestID, nNextStep, QUEST_CATEGORY_PREWARD);
            _SetPCQuestData(oPC, nQuestID, QUEST_PC_STEP, IntToString(nNextStep));
            _SetPCQuestData(oPC, nQuestID, QUEST_PC_STEP_TIME, GetSystemTime());
            RunQuestScript(oPC, nQuestID, QUEST_SCRIPT_TYPE_ON_ADVANCE);
        }

        QuestDebug("Advanced quest " + QuestToString(nQuestID) + " for " +
            PCToString(oPC) + " from step " + IntToString(nCurrentStep) +
            " to step " + IntToString(nNextStep));
    }
    else if (nRequestType == QUEST_ADVANCE_FAIL)
    {
        int nNextStep = GetQuestCompletionStep(nQuestID, QUEST_ADVANCE_FAIL);
        DeletePCQuestProgress(oPC, nQuestID);
        ResetPCQuestData(oPC, nQuestID);

        QuestDebug(PCToString(oPC) + " failed to complete quest " + QuestToString(nQuestID) +
            " due to a quest objective failure");

        if (nNextStep != -1)
        {
            SendJournalQuestEntry(oPC, nQuestID, nNextStep);
            _AwardQuestStepAllotments(oPC, nQuestID, nNextStep, QUEST_CATEGORY_REWARD);
        }

        RunQuestScript(oPC, nQuestID, QUEST_SCRIPT_TYPE_ON_FAIL);
    }
}

void CheckQuestStepProgress(object oPC, int nQuestID, int nStep)
{

    int QUEST_STEP_INCOMPLETE = 1;
    int QUEST_STEP_COMPLETE = 2;
    int QUEST_STEP_FAIL = 3;

    int nRequired, nAcquired, nStatus = QUEST_STEP_INCOMPLETE;
    string sStartTime, sGoalTime;

    // Check for time failure first, if there is a time limit
    string sQuestTimeLimit = GetQuestTimeLimit(nQuestID);
    string sStepTimeLimit = GetQuestStepTimeLimit(nQuestID, nStep);

    // Check for quest step time limit ...
    if (sStepTimeLimit != "")
    {   // There was a time limit assigned
        sStartTime = _GetPCQuestData(oPC, nQuestID, QUEST_PC_STEP_TIME);
        sGoalTime = AddSystemTimeVector(sStartTime, sStepTimeLimit);
        if (GetMinSystemTime(sGoalTime) == sGoalTime)
            nStatus = QUEST_STEP_FAIL;

        QuestDebug(PCToString(oPC) + " failed to meet the time limit for " +
            QuestToString(nQuestID) + " " + StepToString(nStep));    
    }

    if (nStatus != QUEST_STEP_FAIL)
    {
        // Check for overall quest time limit ...
        if (sQuestTimeLimit != "")
        {
            sStartTime = _GetPCQuestData(oPC, nQuestID, QUEST_PC_QUEST_TIME);
            sGoalTime = AddSystemTimeVector(sStartTime, sQuestTimeLimit);
            if (GetMinSystemTime(sGoalTime) == sGoalTime)
                nStatus = QUEST_STEP_FAIL;

            QuestDebug(PCToString(oPC) + " failed to meet the time limit for " +
                QuestToString(nQuestID));
        }
    }

    // Okay, we passed the time tests, not see if we failed an "exclusive" objective
    if (nStatus != QUEST_STEP_FAIL)
    {
        sqlquery sqlSums = GetQuestStepSums(oPC, nQuestID);
        sqlquery sqlFail = GetQuestStepSumsFailure(oPC, nQuestID);

        if (SqlStep(sqlFail))
        {
            nRequired = SqlGetInt(sqlFail, 1);
            nAcquired = SqlGetInt(sqlFail, 2);

            if (nAcquired > nRequired)
                nStatus = QUEST_STEP_FAIL;

            QuestDebug(PCToString(oPC) + "failed to meet an exclusive quest objective " +
                "for " + QuestToString(nQuestID) + " " + StepToString(nStep));
        }

        // We passed the exclusive checks, see about the inclusive checks
        if (nStatus != QUEST_STEP_FAIL)
        {
            // Check for success
            if (SqlStep(sqlSums))
            {
                nRequired = SqlGetInt(sqlSums, 1);
                nAcquired = SqlGetInt(sqlSums, 2);

                if (nAcquired >= nRequired)
                    nStatus = QUEST_STEP_COMPLETE;

                QuestDebug(PCToString(oPC) + " has met all requirements to " +
                    "successfully complete " + QuestToString(nQuestID) +
                    " " + StepToString(nStep));
            }
        }
    }

    if (nStatus == QUEST_STEP_COMPLETE)
        AdvanceQuest(oPC, nQuestID);
    else if (nStatus == QUEST_STEP_FAIL)
        AdvanceQuest(oPC, nQuestID, QUEST_ADVANCE_FAIL);
}

void SignalQuestStepProgress(object oPC, object oTarget, int nObjectiveType)
{
    QuestDebug(GetName(oTarget) + " (tag: " + GetTag(oTarget) + ") is signalling " +
        "quest progress triggered by " + PCToString(oPC) + " for objective " +
        "type " + ObjectiveTypeToString(nObjectiveType));

    string sTargetTag = GetStringLowerCase(GetTag(oTarget));
    int bPCFound = FALSE;

    // TODO should we have the scripter send the PC in, or just take the target
    // and objective type to find the pc (i.e. GetEnteringObject())?  For now,
    // probably easier on use if we let the scripter determine who conducted the
    // action and go from there, this allows easier future expansion of quest
    // types.

    // TODO find a way to make this recursive, if possible, to prevent maintaining
    // multiple redundant loops

    // Ensure we're not running on a henchman or NPC
    while (GetIsObjectValid(GetMaster(oPC)))
        oPC = GetMaster(oPC);

    // ... and that the final solution is a pc, shouldn't be any
    // npc characters that are not henchmen/associates
    if (GetIsPC(oPC) == FALSE)
        return;

    // Two ways to go here, we can either check to see if the pc has any
    //  quest with the targets tag, if not check all party pcs ...
    // ... or we can query the main database for all quests that have the
    // target tag and objective type and then query each pc to see if
    // they have those quests on board.  Going to try the first version
    // first, might be more efficient since I think we'll have to loop all the
    // pcs in the party anyway.
    
    // Get the database records from the pc that are associated with
    // the target and objective type
    sqlquery sqlQuestData = GetTargetQuestData(oPC, sTargetTag, nObjectiveType);
    
    // See if there are any records to look at it
    while (SqlStep(sqlQuestData))
    {   
        // If this loop doesn't execute, then there are no records to retrieve
        // that involve that target and objective type
        string sQuestTag = SqlGetString(sql, 0);
        int nStep = SqlGetInt(sql, 1);
        int nQuestID = GetQuestID(sQuestTag);

        // Probably need to put some of this in another function for recursion
        // we'll figure that out after the basic logic works

        // Since we're here, that means that this pc has at least one quest
        // active associated with oTarget and objective type.  Since we only 
        // have active steps in this table, it should be safe to simply increment 
        // those values without a further check
        IncrementQuestStepQuantity(oPC, sTargetTag, nObjectiveType);
        
        // Check the new status of the quest, this checks to see if the quest step
        // is now complete, incomplete or failed and takes the appropriate action.
        // None of those actions, however should prevent us from completing these
        // checks, however, so press on
        CheckQuestStepProgress(oPC, nQuestID, nStep);

        // See if this can be done with party members
        // this will have to be optioned out so if we're already looping
        // party members from another pc, we don't loop the same party over
        // again, do that if/when we get to recursion.

        QuestDebug("Quest handling for triggering PC complete, checking for party status");
        if (GetQuestStepPartyCompletion(nQuestID, nStep) == TRUE)
        {
            object oParty = GetFirstFactionMember(oPC, TRUE);
            while (GetIsObjectValid(oParty))
            {
                // Don't need to do a bunch of checking here, if they have the
                // data, they get it incremented
                IncrementQuestStepQuantity(oParty, sTargetTag, nObjectiveType);
                CheckQuestStepProgress(oPC, nQuestID, nStep);
                oParty = GetNextFactionMember(oPC, TRUE);
            }
        }

        bPCFound = TRUE;
    }

    if (bPCFound)
        return;

    // if we're here, the original acting pc (oPC) didnt' have any quests
    // associated with oTarget and nObjectiveType

    QuestDebug("The triggering PC does not have a quest associated with " + sTargetTag + 
    "; checking party members");

    // Loop the party to see if anyone has a quest that does
    object oParty = GetFirstFactionMember(oPC, TRUE);
    while (GetIsObjectValid(oParty))
    {
        // We already checked the current pc, skip!
        if (oParty == oPC)
        {
            oParty = GetNextFactionMember(oPC, TRUE);
            continue;
        }
        
        // Get the quest data for that pc to see if they have any qualifying
        // quests ... we can re-use slqQuestData from above, so might be able
        // to recurse this
        sqlquery sqlPartyData = GetTargetQuestData(oParty, sTargetTag, nObjectiveType);
        while (SqlStep(sqlPartyData))
        {
            // If we're in here, they do have at least one qualifying quest...
            int nQuestID = SqlGetInt(sql, 0);
            int nStep = SqlGetInt(sql, 1);

            // This isn't the original actor, so we need party completion before
            // we can increment
            if (GetQuestStepPartyCompletion(nQuestID, nStep) == TRUE)
            {
                IncrementQuestStepQuantity(oParty, sTargetTag, nObjectiveType);
                CheckQuestStepProgress(oPC, nQuestID, nStep);
            }
        }

        oParty = GetNextFactionMember(oPC, TRUE);
    } 
}

// These two functions are used to access temporary variables to
// allow script access for quest events
string GetCurrentQuest()
{
    return GetLocalString(GetModule(), QUEST_CURRENT_QUEST);
}

int GetCurrentQuestStep()
{
    return GetLocalInt(GetModule(), QUEST_CURRENT_STEP);
}



void AwardQuestStepPrewards(object oPC, int nQuestID, int nStep, int bParty = FALSE, int nAwardType = AWARD_ALL)
{
    _AwardQuestStepAllotments(oPC, nQuestID, nStep, QUEST_CATEGORY_PREWARD, nAwardType, bParty);
}

void AwardQuestStepRewards(object oPC, int nQuestID, int nStep, int bParty = FALSE, int nAwardType = AWARD_ALL)
{
    _AwardQuestStepAllotments(oPC, nQuestID, nStep, QUEST_CATEGORY_REWARD, nAwardType, bParty);
}

string GetQuestTitle(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_TITLE);
}

void SetQuestTitle(int nQuestID, string sTitle)
{
    _SetQuestData(nQuestID, QUEST_TITLE, sTitle);
}

int GetQuestActive(int nQuestID)
{
    string sActive = _GetQuestData(nQuestID, QUEST_ACTIVE);
    return StringToInt(sActive);
}

void SetQuestActive(int nQuestID)
{
    _SetQuestData(nQuestID, QUEST_ACTIVE, IntToString(TRUE));
}

void SetQuestInactive(int nQuestID)
{
    _SetQuestData(nQuestID, QUEST_ACTIVE, IntToString(FALSE));
}

int GetQuestRepetitions(int nQuestID)
{
    string sRepetitions = _GetQuestData(nQuestID, QUEST_REPETITIONS);
    return StringToInt(sRepetitions);
}

void SetQuestRepetitions(int nQuestID, int nRepetitions = 1)
{
    string sRepetitions = IntToString(nRepetitions);
    _SetQuestData(nQuestID, QUEST_REPETITIONS, sRepetitions);
}

string GetQuestTimeLimit(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_TIME_LIMIT);
}

void SetQuestTimeLimit(int nQuestID, string sTime)
{
    _SetQuestData(nQuestID, QUEST_TIME_LIMIT, sTime);
}

string GetQuestCooldown(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_COOLDOWN);
}

void SetQuestCooldown(int nQuestID, string sTime)
{
    _SetQuestData(nQuestID, QUEST_COOLDOWN, sTime);
}

int GetQuestStepOrder(int nQuestID)
{
    string sStepOrder = _GetQuestData(nQuestID, QUEST_STEP_ORDER);
    return StringToInt(sStepOrder);
}

void SetQuestStepOrder(int nQuestID, int nOrder = QUEST_STEP_ORDER_SEQUENTIAL)
{
    string sOrder = IntToString(nOrder);
    _SetQuestData(nQuestID, QUEST_STEP_ORDER, sOrder);
}

string GetQuestScriptOnAccept(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_SCRIPT_ON_ACCEPT);
}

void SetQuestScriptOnAccept(int nQuestID, string sScript = "")
{
    _SetQuestData(nQuestID, QUEST_SCRIPT_ON_ACCEPT, sScript);
}

string GetQuestScriptOnAdvance(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_SCRIPT_ON_ADVANCE);
}

void SetQuestScriptOnAdvance(int nQuestID, string sScript = "")
{
    _SetQuestData(nQuestID, QUEST_SCRIPT_ON_ADVANCE, sScript);
}

string GetQuestScriptOnComplete(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_SCRIPT_ON_COMPLETE);
}

void SetQuestScriptOnComplete(int nQuestID, string sScript = "")
{
    _SetQuestData(nQuestID, QUEST_SCRIPT_ON_COMPLETE, sScript);
}

string GetQuestScriptOnFail(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_SCRIPT_ON_FAIL);
}

void SetQuestScriptOnFail(int nQuestID, string sScript = "")
{
    _SetQuestData(nQuestID, QUEST_SCRIPT_ON_FAIL, sScript);
}

string GetQuestStepJournalEntry(int nQuestID, int nStep)
{
    return _GetQuestStepData(nQuestID, nStep, QUEST_STEP_JOURNAL_ENTRY);
}

void SetQuestStepJournalEntry(int nQuestID, int nStep, string sJournalEntry)
{
    _SetQuestStepData(nQuestID, nStep, QUEST_STEP_JOURNAL_ENTRY, sJournalEntry);
}

string GetQuestStepTimeLimit(int nQuestID, int nStep)
{
    return _GetQuestStepData(nQuestID, nStep, QUEST_STEP_TIME_LIMIT);
}

void SetQuestStepTimeLimit(int nQuestID, int nStep, string sTime = "")
{
    _SetQuestStepData(nQuestID, nStep, QUEST_STEP_TIME_LIMIT, sTime);
}

int GetQuestStepPartyCompletion(int nQuestID, int nStep)
{   
    string sData = _GetQuestStepData(nQuestID, nStep, QUEST_STEP_PARTY_COMPLETION);
    return StringToInt(sData);
}

void SetQuestStepPartyCompletion(int nQuestID, int nStep, int nParty)
{
    string sData = IntToString(nParty);
    _SetQuestStepData(nQuestID, nStep, QUEST_STEP_PARTY_COMPLETION, sData);
}

void SetQuestPrerequisiteAlignment(int nQuestID, int nKey, int nValue = FALSE)
{
    string sKey = IntToString(nKey);
    string sValue = IntToString(nValue);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_ALIGNMENT, sKey, sValue);
}

void SetQuestPrerequisiteClass(int nQuestID, int nKey, int nValue = -1)
{
    string sKey = IntToString(nKey);
    string sValue = IntToString(nValue);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_CLASS, sKey, sValue);
}

void SetQuestPrerequisiteGold(int nQuestID, int nValue = 1)
{
    string sValue = IntToString(max(0, nValue));
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_GOLD, "", sValue);
}

void SetQuestPrerequisiteItem(int nQuestID, string sKey, int nValue = 1)
{
    string sValue = IntToString(nValue);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_ITEM, sKey, sValue);
}

void SetQuestPrerequisiteLevelMax(int nQuestID, int nValue)
{
    string sValue = IntToString(nValue);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_LEVEL_MAX, "", sValue);
}

void SetQuestPrerequisiteLevelMin(int nQuestID, int nValue)
{
    string sValue = IntToString(nValue);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_LEVEL_MIN, "", sValue);
}

void SetQuestPrerequisiteQuest(int nQuestID, string sKey, int nValue = 1)
{
    string sValue = IntToString(nValue);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_QUEST, sKey, sValue);
}

void SetQuestPrerequisiteQuestStep(int nQuestID, string sKey, int nValue)
{
    string sValue = IntToString(nValue);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_QUEST_STEP, sKey, sValue);
}

void SetQuestPrerequisiteRace(int nQuestID, int nKey, int nValue = TRUE)
{
    string sKey = IntToString(nKey);
    string sValue = IntToString(nValue);    
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_RACE, sKey, sValue);
}

void SetQuestStepObjectiveKill(int nQuestID, int nStep, string sKey, int nValue = 1)
{
    string sValue = IntToString(nValue);
    _SetQuestObjective(nQuestID, nStep, QUEST_OBJECTIVE_KILL, sKey, sValue);
}

void SetQuestStepObjectiveGather(int nQuestID, int nStep, string sKey, int nValue = 1)
{
    string sValue = IntToString(nValue);
    _SetQuestObjective(nQuestID, nStep, QUEST_OBJECTIVE_GATHER, sKey, sValue);
}

void SetQuestStepObjectiveDeliver(int nQuestID, int nStep, string sKey, string sValue)
{
    _SetQuestObjective(nQuestID, nStep, QUEST_OBJECTIVE_DELIVER, sKey, sValue);
}

void SetQuestStepObjectiveDiscover(int nQuestID, int nStep, string sKey, int nValue = 1)
{
    string sValue = IntToString(nValue);
    _SetQuestObjective(nQuestID, nStep, QUEST_OBJECTIVE_DISCOVER, sKey, sValue);
}

void SetQuestStepObjectiveSpeak(int nQuestID, int nStep, string sKey, int nValue = 1)
{
    string sValue = IntToString(nValue);
    _SetQuestObjective(nQuestID, nStep, QUEST_OBJECTIVE_SPEAK, sKey, sValue);
}

void SetQuestStepPrewardAlignment(int nQuestID, int nStep, int nKey, int nValue)
{
    string sKey = IntToString(nKey);
    string sValue = IntToString(nValue);
    _SetQuestPreward(nQuestID, nStep, QUEST_VALUE_ALIGNMENT, sKey, sValue);
}

void SetQuestStepPrewardGold(int nQuestID, int nStep, int nValue)
{
    string sValue = IntToString(nValue);
    _SetQuestPreward(nQuestID, nStep, QUEST_VALUE_GOLD, "", sValue);
}

void SetQuestStepPrewardItem(int nQuestID, int nStep, string sKey, int nValue)
{
    string sValue = IntToString(nValue);
    _SetQuestPreward(nQuestID, nStep, QUEST_VALUE_ITEM, sKey, sValue);
}

void SetQuestStepPrewardXP(int nQuestID, int nStep, int nValue)
{
    string sValue = IntToString(nValue);
    _SetQuestPreward(nQuestID, nStep, QUEST_VALUE_XP, "", sValue);
}

void SetQuestStepPrewardMessage(int nQuestID, int nStep, string sValue)
{
    _SetQuestPreward(nQuestID, nStep, QUEST_VALUE_MESSAGE, "", sValue);
}

void SetQuestStepRewardAlignment(int nQuestID, int nStep, int nKey, int nValue)
{
    string sKey = IntToString(nKey);
    string sValue = IntToString(nValue);
    _SetQuestReward(nQuestID, nStep, QUEST_VALUE_ALIGNMENT, sKey, sValue);
}

void SetQuestStepRewardGold(int nQuestID, int nStep, int nValue)
{
    string sValue = IntToString(nValue);
    _SetQuestReward(nQuestID, nStep, QUEST_VALUE_GOLD, "", sValue);
}

void SetQuestStepRewardItem(int nQuestID, int nStep, string sKey, int nValue = 1)
{
    string sValue = IntToString(nValue);
    _SetQuestReward(nQuestID, nStep, QUEST_VALUE_ITEM, sKey, sValue);
}

void SetQuestStepRewardQuest(int nQuestID, int nStep, string sKey, int nValue = TRUE)
{
    string sValue = IntToString(nValue);
    _SetQuestReward(nQuestID, nStep, QUEST_VALUE_QUEST, sKey, sValue);
}

void SetQuestStepRewardXP(int nQuestID, int nStep, int nValue)
{
    string sValue = IntToString(nValue);
    _SetQuestReward(nQuestID, nStep, QUEST_VALUE_XP, "", sValue);
}

void SetQuestStepRewardMessage(int nQuestID, int nStep, string sValue)
{
    _SetQuestReward(nQuestID, nStep, QUEST_VALUE_MESSAGE, "", sValue);
}

int AddQuestResolutionSuccess(int nQuestID, string sJournalEntry = "", int nStep = -1)
{
    nStep = AddQuestStep(nQuestID, sJournalEntry, nStep);
    
    string sType = IntToString(QUEST_STEP_TYPE_SUCCESS);
    _SetQuestStepData(nQuestID, nStep, QUEST_STEP_TYPE, sType);

    return nStep;
}

int AddQuestResolutionFail(int nQuestID, string sJournalEntry = "", int nStep = -1)
{
    nStep = AddQuestStep(nQuestID, sJournalEntry, nStep);
    
    string sType = IntToString(QUEST_STEP_TYPE_FAIL);
    _SetQuestStepData(nQuestID, nStep, QUEST_STEP_TYPE, sType);

    return nStep;
}
