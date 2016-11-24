#pragma ModuleName=JigSamples
#include "Jig"


Menu "Jig"
	"Jig Functions/F1",/Q,Jig_JigFunction()
	"-"
	"\M0Window (Show)",/Q,Jig_WindowShow()
	"\M0Window (Hide)",/Q,Jig_WindowHide()
	"\M0Window (Kill)",/Q,Jig_WindowKill()
	"-"
	"\M0Command (Show)",/Q,Jig_CommandShow()
	"\M0Command (Execute)",/Q,Jig_CommandExecute()
End

////////////////////////////////////////////////////////////////////////////////
// Jig /////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

Function Jig_JigFunction()
	Jig(RemoveFromList("Jig_JigFunction",FunctionList("Jig_*",";","")),"%s()")
End

////////////////////////////////////////////////////////////////////////////////
// Window //////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static Function/S windows()
	return WinList("*",";","WIN:"+Num2Str(1+2+4+16+64+4096))
End

Function Jig_WindowShow()
	Jig(sorted(windows()),"DoWindow/F $\"%s\"")
End

Function Jig_WindowHide()
	Jig(sorted(windows()),"DoWindow/HIDE=1 $\"%s\"")
End

Function Jig_WindowKill()
	Jig(sorted(windows()),"KillWindow $\"%s\"")
End

////////////////////////////////////////////////////////////////////////////////
// Command /////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static Function/S commands()
	return MacroList("*",";","")+FunctionList("*",";","")+OperationList("*",";","")
End

Function Jig_CommandShow()
	Jig(sorted(commands()),"DisplayHelpTopic \"%s\"")
End

static Function CommandShow(name)
	String name
	if(ItemsInList(MacroList("*",";","")))
		DisplayProcedure name
	elseif(ItemsInList(FunctionList(name,";","KIND:1")))
		DisplayProcedure name
	elseif(ItemsInList(OperationList("*",";","")))
		DisplayHelpTopic name
	elseif(ItemsInList(FunctionList(name,";","KIND:2")))
		DisplayHelpTopic name
	endif
End

static Function/S executables()
	return MacroList("*",";","NPARAMS:0")+FunctionList("*",";","KIND:2,NPARAMS:0")
End

Function Jig_CommandExecute()
	Jig(sorted(executables()),"%s()")
End

////////////////////////////////////////////////////////////////////////////////
// Utilities ///////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static Function/S sorted(list) // case insensitive sort for a list
	String list
	return SortList(list,";",4)
End

