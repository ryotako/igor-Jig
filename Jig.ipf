#pragma ModuleName=Jig

Function Jig(list,cmd [delim])
	String list,cmd,delim
	if(ParamIsDefault(delim))
		delim=";"
	endif
	Make/FREE/T/N=(ItemsInList(list,delim)) w=StringFromList(p,list,delim)
	Jigw(w,cmd)
End

Function Jigw(w,cmd)
	WAVE/T w; String cmd

	// Make source
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:Jig
	Duplicate/O/T w root:Packages:Jig:source
	Duplicate/O/T w root:Packages:Jig:buffer
	
	// Make panel
	if(strlen(WinList("JigPanel",";","WIN:64")))
		KillWindow JigPanel
	endif

	Variable width =NumberByKey("WIDTH" ,Screen())
	Variable height=NumberByKey("HEIGHT",Screen())
	NewPanel/K=1/W=(width*(1/4),height*(1/4),width*(3/4),height*(3/4))/N=JigPanel as cmd
	ModifyPanel/W=JigPanel fixedSize=1,noEdit=1
	String win=S_Name
	
	// Make controls
	//// input character
	SetVariable JigInput,win=$win,pos={width*(1/2)+10,0}
	SetVariable JigInput,win=$win,value=_str:num2char(18)
	SetVariable JigInput,win=$win,fsize=16
	SetVariable JigInput,win=$win,size={20,0}
	SetVariable JigInput,win=$win,userData=cmd
	SetVariable JigInput,win=$win,proc=Jig#InputAction
	Execute/P/Q "SetVariable JigInput,win="+win+",activate"
	//// display input string
	SetVariable JigLine,win=$win,pos={0,0}
	SetVariable JigLine,win=$win,value=_str:""
	SetVariable JigLine,win=$win,fsize=16
	SetVariable JigLine,win=$win,size={width/2,0}

	//// output
	ListBox JigBuffer,win=$win,pos={0,30}
	ListBox JigBuffer,win=$win,fsize=14
	ListBox JigBuffer,win=$win,size={width,height*(2/3)}
	ListBox JigBuffer,win=$win,listWave=root:Packages:Jig:buffer
	
	// Run background process
	CtrlNamedBackground JigBkg,proc=JigBkgProc,period=1,start
End


static Function InputAction(sv) : SetVariableControl
	STRUCT WMSetVariableAction &sv
	if(sv.eventCode>0)
		if(sv.eventMod==0 && StringMatch(sv.sval,num2char(18))) // Enter
			ControlInfo/W=JigPanel JigLine
			KillWindow $sv.win
			String  cmd
			sprintf cmd, sv.userData, S_Value
			Execute/Z cmd
			print num2char(cmpstr(IgorInfo(2),"Macintosh") ? 42 : -91) + cmd
			print GetErrMessage(V_Flag)
		else		
			if(sv.eventMod==2) // Shift+Enter
//				print "SHIFT"
			elseif(sv.eventMod==4) // Alt+Enter
//				print "OPTION/ALT"
			elseif(sv.eventMod==8) // Ctrl+Enter
//				print "CMD/CTRL"
			endif		
			SetVariable $sv.ctrlName,win=$sv.win,activate
		endif
	else
		CtrlNamedBackground JigBkg,stop
	endif
End

Function JigBkgProc(s)
	STRUCT WMBackgroundStruct &s
	if(strlen(WinList("JigPanel",";","WIN:64")))
		ControlUpdate/W=JigPanel JigInput
		ControlInfo/W=JigPanel JigInput
		String input_chr=S_Value
		ControlInfo/W=JigPanel JigLine
		String input_str=S_Value
		if(!StringMatch(input_chr,num2char(18)))
			if(strlen(input_chr)<1)
				input_str=input_str[0,strlen(input_str)-2]
			else
				input_str=input_str+input_chr
			endif
			SetVariable JigLine,win=JigPanel,value=_str:input_str
			WAVE/T buf=root:Packages:Jig:buffer
			WAVE/T src=root:Packages:Jig:source

			Extract/T/O src,buf,GrepString(src,"(?i)"+input_str)
		endif
		SetVariable JigInput,win=JigPanel,value=_str:num2char(18)
		SetVariable JigInput,win=JigPanel,activate
		return 0
	else
		return 1
	endif
End

Function/S Screen()
	String width,height,output
	SplitString/E="RECT=0,0,([0-9]+),([0-9]+)" IgorInfo(0),width,height
	sprintf output,"WIDTH:%s;HEIGHT:%s",width,height
	return output
End 
