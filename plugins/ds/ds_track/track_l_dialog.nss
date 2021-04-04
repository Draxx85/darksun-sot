// -----------------------------------------------------------------------------
//    File: test_l_dialog.nss
//  System: Dynamic Dialogs (library script)
// -----------------------------------------------------------------------------
// Talking 'bout stuff.
// -----------------------------------------------------------------------------

#include "dlg_i_dialogs"
#include "util_i_library"
#include "util_i_debug"

// Temporary includes go here
#include "util_i_libraries"

// -----------------------------------------------------------------------------
//                                  Test Dialog
// -----------------------------------------------------------------------------
// What can I say, it's a sandbox.
// -----------------------------------------------------------------------------

const string TRACKING_DIALOG = "TrackingDialog";
const string TRACKING_INIT = "Tracking_Init";
const string TRACKING_QUIT = "Tracking_Init_Quit";

const string PAGE_MAIN = "PAGE_MAIN";

void Tracking_Init()
{
    if (GetDialogEvent() != DLG_EVENT_INIT)
        return;

    SetDialogPage(PAGE_MAIN);
    AddDialogPage(PAGE_MAIN, "Welcome to the sandbox!  We'll be using this dialog " +
        "to test various functions of the module as they're installed.  " +
        "Which system or function would you like to test?");
    EnableDialogEnd("Nothing for me today, thanks!", PAGE_MAIN);
}

void Tracking_Quit()
{
    // Meh, we're good.
}

void OnLibraryLoad()
{
    RegisterLibraryScript(TRACKING_DIALOG);
}

void OnLibraryScript(string sScript, int nEntry)
{
    if (sScript == TRACKING_DIALOG) 
        Tracking_Init();
}