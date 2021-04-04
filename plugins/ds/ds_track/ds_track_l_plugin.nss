// -----------------------------------------------------------------------------
//    File: tr_l_plugin.nss
//  System: Travel (library)
//     URL: 
// Authors: Oliver Plunkett (Skarltar) <plunkettoli@hotmail.com>
// -----------------------------------------------------------------------------
// Description:
//  Library functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------
// Acknowledgment:
// -----------------------------------------------------------------------------
//  Revision:
//      Date:
//    Author:
//   Summary:
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    object oPlugin = GetPlugin("ds");

    // ----- Module Events -----
  //  RegisterEventScripts(oPlugin, AREA_EVENT_ON_ENTER,              "tr_OnAreaEnter");

    // ----- Module Events -----
   // RegisterLibraryScript("tr_encounter_OnTimerExpire", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        default: CriticalError("Library function " + sScript + " not found");
    }
}
