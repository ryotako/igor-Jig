#pragma ModuleName=Jig
constant Jig_FontSize=16
strconstant Jig_Font=""

/////////////////////////////////////////////////////////////////////////////////
// Public Functions /////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
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
	Variable screenHeight = NumberByKey("HEIGHT",Screen())
	Variable screenWidth  = NumberByKey("WIDTH" ,Screen())
	Variable fontHeight   = FontSizeHeight(Font(),Jig_FontSize,0,"native")*	1.25
	Variable panelHeight  = screenHeight*(2/5)
	Variable panelWidth   = screenWidth *(2/5)
	Variable topMargin    = (screenHeight-panelHeight)/2
	Variable leftMargin   = (screenWidth-panelWidth)/2
	Variable bufferHeight = panelHeight-FontHeight

	// Make source
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:Jig
	Duplicate/O/T w root:Packages:Jig:source
	Duplicate/O/T w root:Packages:Jig:buffer
	
	// Make panel
	if(strlen(WinList("JigPanel",";","WIN:64")))
		KillWindow JigPanel
	endif
	NewPanel/K=1/W=(leftMargin,topMargin,leftMargin+panelWidth,topMargin+panelHeight)/N=JigPanel as cmd
	ModifyPanel/W=JigPanel fixedSize=1,noEdit=1
	String win=S_Name
	
	// Make controls
	//// hidden input control
	SetVariable JigInput,win=$win,pos={panelWidth+10,0}
	SetVariable JigInput,win=$win,size={fontHeight,0}
	SetVariable JigInput,win=$win,fsize=Jig_FontSize
	Execute/Z "SetVariable JigInput,win="+win+",font="+Font()
	SetVariable JigInput,win=$win,value=_str:num2char(18)
	SetVariable JigInput,win=$win,userData=cmd
	SetVariable JigInput,win=$win,proc=Jig#InputAction
	Execute/P/Q "SetVariable JigInput,win="+win+",activate"

	//// input string display
	ControlInfo/W=$win JigInput
	SetVariable JigLine,win=$win,pos={0,0}
	SetVariable JigLine,win=$win,size={panelWidth,V_Height}
	SetVariable JigLine,win=$win,fsize=Jig_FontSize
	Execute/Z "SetVariable JigLine,win="+win+",font="+Font()
	SetVariable JigLine,win=$win,value=_str:""

	//// buffer for candidates
	ListBox JigBuffer,win=$win,pos={0,fontHeight}
	ListBox JigBuffer,win=$win,size={panelWidth,bufferHeight}
	ListBox JigBuffer,win=$win,fsize=Jig_FontSize
	Execute/Z "ListBox JigBuffer,win="+win+",font="+Font()
	ListBox JigBuffer,win=$win,listWave=root:Packages:Jig:buffer
	ListBox JigBuffer,win=$win,mode=2
	ListBox JigBuffer,win=$win,row=0
	ListBox JigBuffer,win=$win,selrow=0

	// Run background process
	CtrlNamedBackground JigBkg,proc=Jig#BkgProc,period=1,start
End

/////////////////////////////////////////////////////////////////////////////////
// Control Action ///////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
static Function InputAction(sv) : SetVariableControl
	STRUCT WMSetVariableAction &sv
	if(sv.eventCode>0)
		if(sv.eventMod==0 && StringMatch(sv.sval,num2char(18))) // Enter
			ControlInfo/W=JigPanel JigBuffer
			KillWindow $sv.win
			WAVE/T w=root:Packages:Jig:buffer
			if(DimSize(w,0)>0)
				String  cmd
				sprintf cmd, sv.userData, w[V_Value]
				Execute/Z cmd
				print num2char(cmpstr(IgorInfo(2),"Macintosh") ? 42 : -91) + cmd
				print GetErrMessage(V_Flag)
			endif
		else		
			if(sv.eventMod==2) // Shift+Enter
				Scroll(+1)
			elseif(sv.eventMod==4) // Alt+Enter
				Scroll(-1)
			elseif(sv.eventMod==8) // Ctrl+Enter
//				print "CMD/CTRL"
			endif		
			SetVariable $sv.ctrlName,win=$sv.win,activate
		endif
	else
		CtrlNamedBackground JigBkg,stop
	endif
End
static Function Scroll(step)
	Variable step
	Variable size=DimSize(root:Packages:Jig:buffer,0)
	if(size>0)
		ControlInfo/W=JigPanel JigBuffer
		Variable next=mod(V_Value+size+step,size)
		ListBox JigBuffer,win=JigPanel,row=next
		ListBox JigBuffer,win=JigPanel,selrow=next
	endif
End

/////////////////////////////////////////////////////////////////////////////////
// Background Process ///////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
static Function BkgProc(s)
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
			
			Duplicate/FREE/T root:Packages:Jig:source buf 
			String list=RemoveFromList(" ",input_str," ")
			Variable i,N=ItemsInList(list," ")
			Make/FREE/T/N=(N) w=StringFromList(p,list," ")
			for(i=0;i<N;i+=1)
				Extract/T/O buf,buf,GrepString(buf,"(?i)"+w[i])				
			endfor
			ListBox JigBuffer,win=JigPanel,row=0
			ListBox JigBuffer,win=JigPanel,selrow=0
			Duplicate/O/T buf root:Packages:Jig:buffer
		endif
		SetVariable JigInput,win=JigPanel,value=_str:num2char(18)
		SetVariable JigInput,win=JigPanel,activate
		return 0
	else
		return 1
	endif
End

/////////////////////////////////////////////////////////////////////////////////
// Utilities ////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
static Function/S Screen()
	String width,height,output
	SplitString/E="RECT=0,0,([0-9]+),([0-9]+)" IgorInfo(0),width,height
	sprintf output,"WIDTH:%s;HEIGHT:%s",width,height
	return output
End 

static Function/S Font()
	if(strlen(FontList(Jig_Font)))
		return GetDefaultFont("")
	endif
End