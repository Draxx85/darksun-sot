// -----------------------------------------------------------------------------
//    File: test_l_dialog.nss
//  System: Dynamic Dialogs (library script)
// -----------------------------------------------------------------------------
// Talking 'bout stuff.
// -----------------------------------------------------------------------------

#include "dlg_i_dialogs"
#include "util_i_library"
#include "util_i_debug"

// -----------------------------------------------------------------------------
//                                  Test Dialog
// -----------------------------------------------------------------------------
// What can I say, it's a sandbox.
// -----------------------------------------------------------------------------

const string TRACKING_DIALOG = "TrackingDialog";
const string TRACKING_INIT = "Tracking_Init";

void TrackingDialog()
{
    if (GetDialogEvent() != DLG_EVENT_INIT)
        return;

    SetDialogPage(TRACKING_INIT);
    AddDialogPage(TRACKING_INIT, "Welcome to the sandbox!  We'll be using this dialog " +
        "to test various functions of the module as they're installed.  " +
        "Which system or function would you like to test?");
    EnableDialogEnd("Nothing for me today, thanks!", TRACKING_INIT);
}


//====================Library Dispatch================================

void OnLibraryLoad()
{
    RegisterLibraryScript(TRACKING_DIALOG);
    RegisterDialogScript(TRACKING_DIALOG);
}

void OnLibraryScript(string sScript, int nEntry)
{
    if (sScript == TRACKING_DIALOG) 
        TrackingDialog();
}