// -----------------------------------------------------------------------------
//    File: quest_l_plugin.nss
//  System: Quest Persistent World Subsystem
// -----------------------------------------------------------------------------
// Description:
//  Library functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "quest_i_events"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    object oPlugin = GetPlugin("pw");

    // ----- Module Events -----
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_MODULE_LOAD, "quest_OnModuleLoad", 4.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "quest_OnClientEnter", 4.0);
    RegisterEventScripts(oPlugin, CHAT_PREFIX + "!quest", "quest_OnPlayerChat", 4.0);

    // ----- Module Events -----
    RegisterLibraryScript("quest_OnModuleLoad", 1);
    RegisterLibraryScript("quest_OnClientEnter", 2);
    RegisterLibraryScript("quest_OnPlayerChat", 3);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1:  quest_OnModuleLoad(); break;
        case 2:  quest_OnClientEnter(); break;
        case 3:  quest_OnPlayerChat(); break;

        default: CriticalError("Library function " + sScript + " not found");
    }
}
