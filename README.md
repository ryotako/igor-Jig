# igor-Jig
Interactive filtering tool in Igor Pro

## Usage
```
Function JigWin()
	Jig(WinList("*",";","WIN:4183"),"DoWindow/F %s")
End

Function JigHelp()
	Jig(FunctionList("*",";","KIND:1")+OperationList("*",";",""),"DisplayHelpTopic ¥"%s¥"")
End

Function JigFunc()
	Jig(FunctionList("Jig*",";","NPARAMS:0"),"%s()")
End
```
