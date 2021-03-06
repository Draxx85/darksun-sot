// -----------------------------------------------------------------------------
//    File: quest_i_events.nss
//  System: Quest Persistent World Subsystem (events)
// -----------------------------------------------------------------------------
// Description:
//  Event functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "quest_i_main"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void quest_OnModuleLoad()
{
    CreateModuleQuestTables();
}

void quest_OnClientEnter()
{
    object oPC = GetEnteringObject();
    CreatePCQuestTables(oPC);
    CleanPCQuestTables(oPC);
}

void quest_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();

    if (HasChatOption(oPC, "load"))
        DefineQuests();

    if (HasChatOption(oPC, "reset"))
    {
        CreateModuleQuestTables(TRUE);
        CreatePCQuestTables(oPC, TRUE);
    }

    if (HasChatOption(oPC, "assign"))
        AssignQuestToPC(oPC);

    if (HasChatOption(oPC, "restart"))
    {
        CreateModuleQuestTables(TRUE);
        CreatePCQuestTables(oPC, TRUE);
        DefineQuests();
        AssignQuestToPC(oPC);
    }

    if (HasChatOption(oPC, "dump"))
    {
        if (HasChatOption(oPC, "pc"))
        {
            Notice("Dumping PC Quest data");

            string sPCQuestTag, sPCStepStartTime, sPCQuestStartTime, sPCLastCompleteTime;
            int n, nPCStep, nPCCompletions;

            string sQuery = "SELECT * FROM quest_pc_data;";
            sqlquery sql = SqlPrepareQueryObject(oPC, sQuery);
            while (SqlStep(sql))
            {
                n = 0;
                sPCQuestTag = SqlGetString(sql, n);
                nPCStep = SqlGetInt(sql, ++n);
                nPCCompletions = SqlGetInt(sql, ++n);
                sPCQuestStartTime = SqlGetString(sql, ++n);
                sPCStepStartTime = SqlGetString(sql, ++n);
                sPCLastCompleteTime = SqlGetString(sql, ++n);

                Notice(HexColorString("Dumping PC data for " + sPCQuestTag, COLOR_CYAN));
                Notice("  Step  " + ColorValue(IntToString(nPCStep)) +
                     "\n  Completions  " + ColorValue(IntToString(nPCCompletions)) +
                     "\n  Quest Start  " + ColorValue(sPCQuestStartTime) +
                     "\n  Step Start  " + ColorValue(sPCStepStartTime) +
                     "\n  Last Completion = " + ColorValue(sPCLastCompleteTime)); 

                string sQuery1 = "SELECT * FROM quest_pc_step " +
                                 "WHERE quest_tag = @tag;";
                sqlquery sql1 = SqlPrepareQueryObject(oPC, sQuery1);
                SqlBindString(sql1, "@tag", sPCQuestTag);

                while (SqlStep(sql1))
                {
                    n = 1;
                    string sObjectiveType = ObjectiveTypeToString(SqlGetInt(sql1, n));
                    string sTag = SqlGetString(sql1, ++n);
                    string sRequired = SqlGetString(sql1, ++n);
                    string sAcquired = SqlGetString(sql1, ++n);

                    Notice(HexColorString("Dumping PC step data for " + sPCQuestTag + "/" + IntToString(nPCStep), COLOR_CYAN));
                    Notice("    Objective Type  " + ColorValue(sObjectiveType) +
                         "\n    Tag  " + ColorValue(sTag) +
                         "\n    Required  " + ColorValue(sRequired) +
                         "\n    Acquired  " + ColorValue(sAcquired));
                }
            }
        }
        else 
        {
            int n, nID, nActive, nRepetitions, nStepOrder;
            string sTag, sTitle, sAccept, sAdvance, sComplete, sFail;
            string sTime, sCooldown;

            int nStepID, nQuestID, nStep, nPartyCompletion;
            string sJournalEntry, sTimeLimit;

            string sNewQuery, sSubQuery, sQuery = "SELECT * FROM quest_quests;";
            sqlquery sqlNew, sqlSub, sql = SqlPrepareQueryObject(GetModule(), sQuery);
            while (SqlStep(sql))
            {
                // Display all the quest data
                n = 0;
                nID = SqlGetInt(sql, n);
                sTag = SqlGetString(sql, ++n);
                nActive = SqlGetInt(sql, ++n);
                sTitle = SqlGetString(sql, ++n);
                nRepetitions = SqlGetInt(sql, ++n);
                sAccept = SqlGetString(sql, ++n);
                sAdvance = SqlGetString(sql, ++n);
                sComplete = SqlGetString(sql, ++n);
                sFail = SqlGetString(sql, ++n);
                nStepOrder = SqlGetInt(sql, ++n);
                sTime = SqlGetString(sql, ++n);
                sCooldown = SqlGetString(sql, ++n);
            
                Notice(HexColorString("Dumping data for " + QuestToString(nID), COLOR_CYAN));
                Notice("  Tag  " + ColorValue(sTag) +
                    "\n  Active  " + ColorValue((nActive ? "TRUE":"FALSE")) +
                    "\n  Journal  " + ColorValue(sTitle) +
                    "\n  Repetitions  " + ColorValue(IntToString(nRepetitions)) +
                    "\n  Accept Script  " + ColorValue(sAccept) +
                    "\n  Advance Script  " + ColorValue(sAdvance) +
                    "\n  Complete Script  " + ColorValue(sComplete) +
                    "\n  Fail Script  " + ColorValue(sFail) +
                    "\n  Step Order  " + ColorValue(StepOrderToString(nStepOrder)) +
                    "\n  Time Limit  " + ColorValue(sTime) +
                    "\n  Cooldown Time  " + ColorValue(sCooldown));

                if (CountQuestPrerequisites(nID) > 0)
                {
                    Notice(HexColorString("  Dumping prerequisites for " + QuestToString(nID), COLOR_CYAN));
                    
                    sSubQuery = "SELECT * FROM quest_prerequisites " +
                                "WHERE quests_id = @id;";
                    sqlSub = SqlPrepareQueryObject(GetModule(), sSubQuery);
                    SqlBindInt(sqlSub, "@id", nID);
                    while (SqlStep(sqlSub))
                    {
                        n = 0;
                        int nPrereqID = SqlGetInt(sqlSub, 0);
                        int nPrereqQuest = SqlGetInt(sqlSub, 1);
                        int nValueType = SqlGetInt(sqlSub, 2);
                        string sKey = SqlGetString(sqlSub, 3);
                        string sValue = SqlGetString(sqlSub, 4);


                        Notice(HexColorString("    " + IntToString(nPrereqID), COLOR_CYAN) +
                                TranslateValue(nValueType, sKey, sValue));
                    }
                }
                else
                    Notice(HexColorString("  No prerequisites found for " + QuestToString(nID), COLOR_RED_LIGHT));

                if (CountQuestSteps(nID) > 0)
                {
                    // Dump Step data
                    Notice(HexColorString("  Dumping step data for " + QuestToString(nID), COLOR_CYAN));
                    sSubQuery = "SELECT * FROM quest_steps " +
                            "WHERE quests_id = @id;";
                    sqlSub = SqlPrepareQueryObject(GetModule(), sSubQuery);
                    SqlBindInt(sqlSub, "@id", nID);

                    while (SqlStep(sqlSub))
                    {
                        n = 0;
                        nStepID = SqlGetInt(sqlSub, n);
                        nQuestID = SqlGetInt(sqlSub, ++n);
                        nStep = SqlGetInt(sqlSub, ++n);
                        sJournalEntry = SqlGetString(sqlSub, ++n);
                        sTimeLimit = SqlGetString(sqlSub, ++n);
                        nPartyCompletion = SqlGetInt(sqlSub, ++n);

                        string sStep = HexColorString(IntToString(nStep), COLOR_CYAN);
                        Notice("    " + sStep + "  Journal  " + ColorValue(sJournalEntry) +
                            "\n        Time Limit  " + ColorValue(sTimeLimit == "" ? "" : "(" + sTimeLimit + ")") +
                            "\n        Party Completion  " + ColorValue((nPartyCompletion ? "TRUE":"FALSE")));
                    
                        // Another inside loop for the step objectives/properties
                        Notice(HexColorString("        Dumping step properties for Step " + IntToString(nStep), COLOR_CYAN));
                        sNewQuery = "SELECT quest_step_properties.* FROM quest_steps INNER JOIN quest_step_properties " +
                                        "ON quest_steps.id = quest_step_properties.quest_steps_id " +
                                    "WHERE quest_steps.quests_id = @id " +
                                    "AND quest_steps.nStep = @step;";
                        sqlNew = SqlPrepareQueryObject(GetModule(), sNewQuery);
                        SqlBindInt(sqlNew, "@id", nID);
                        SqlBindInt(sqlNew, "@step", nStep);

                        while (SqlStep(sqlNew))
                        {
                            int nCategoryType = SqlGetInt(sqlNew, 1);
                            int nValueType = SqlGetInt(sqlNew, 2);
                            string sTag = SqlGetString(sqlNew, 3);
                            int nRequired = SqlGetInt(sqlNew, 4);
                            Notice(TranslateCategoryValue(nCategoryType, nValueType, sTag, nRequired));
                        }
                    }       
                }
                else
                    Notice(HexColorString("  No step data found for " + QuestToString(nID), COLOR_RED_LIGHT));
            }
        }
    }
}

void quest_OnAdvance()
{
    string sCurrentQuest = GetCurrentQuest();
    int nCurrentStep = GetCurrentQuestStep();

    if (sCurrentQuest == "myFirstQuest")
    {
        if (nCurrentStep == 1)
        {
            QuestDebug("This message is from the script assigned to the quest's ON_ADVANCE " +
                "script.  It was triggered by moving from quest assignment (step 0) to " +
                "the first step in the quest (step 1).  It creates a bad guy in front of " +
                "the PC which allows quest resolution upon creature death.");

            object oWP = GetWaypointByTag("quest_test");
            location lWP = GetLocation(oWP);
            object oTarget = CreateObject(OBJECT_TYPE_CREATURE, "nw_goblina", lWP);

            SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DEATH, "hook_creature05");
            SetLocalString(oTarget, CREATURE_EVENT_ON_DEATH, "test_goblindeath");
        }
    }

}

void test_goblindeath()
{
    object oTarget = OBJECT_SELF;
    object oPC = GetLastKiller();

    SignalQuestStepProgress(oPC, oTarget, QUEST_OBJECTIVE_KILL);
}
