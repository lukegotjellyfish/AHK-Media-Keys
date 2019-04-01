ControlGetText, controltext, ATL:msctls_statusbar321, ahk_exe foobar2000.exe
controltext := StrSplit(controltext, " | ")
tempp := controltext[5]