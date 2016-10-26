
Menu "Jig"
	"Command Help",/Q,Jig_CommandHelp()
	"Function Definition",/Q,Jig_FunctionDefinition()
	
	"-"
	"\M0Window (Open)",/Q,Jig_WindowOpen()
	"\M0Window (Hide)",/Q,Jig_WindowHide()
	"\M0Window (Kill)",/Q,Jig_WindowKill()

End

Function Jig_CommandHelp()
	String list = FunctionList("*",";","KIND:1")+OperationList("*",";","")
	Make/FREE/T/N=(ItemsInList(list)) w=StringFromList(p,list)
	Sort w,w
	Jigw(w,"DisplayHelpTopic \"%s\"")
End

Function Jig_FunctionDefinition()
	String list = FunctionList("*",";","KIND:2")
	Make/FREE/T/N=(ItemsInList(list)) w=StringFromList(p,list)
	Sort w,w
	Jigw(w,"DisplayProcedure \"%s\"")
End

Function Jig_WindowOpen()
	Variable type=1+2+4+16+64+4096
	String list = WinList("*",";","WIN:"+Num2Str(type))
	Make/FREE/T/N=(ItemsInList(list)) w=StringFromList(p,list)
	Sort w,w
	Jigw(w,"DoWindow/F $\"%s\"")
End

Function Jig_WindowHide()
	Variable type=1+2+4+16+64+4096
	String list = WinList("*",";","WIN:"+Num2Str(type))
	Make/FREE/T/N=(ItemsInList(list)) w=StringFromList(p,list)
	Sort w,w
	Jigw(w,"DoWindow/HIDE=1 $\"%s\"")
End

Function Jig_WindowKill()
	Variable type=1+2+4+16+64+4096
	String list = WinList("*",";","WIN:"+Num2Str(type))
	Make/FREE/T/N=(ItemsInList(list)) w=StringFromList(p,list)
	Sort w,w
	Jigw(w,"KillWindow $\"%s\"")
End