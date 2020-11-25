*$J::
DetectHiddenWindows, On
WinGet, x, ControlList, AHK_CLASS {97E27FAA-C0B3-4b8e-A693-ED7881E99FC1}

ControlGetText, otput, x[24]
MsgBox % otput

Loop, Parse, x, `n
{
	ControlGetPos,xx,yy,ww,hh,%A_LoopField%, AHK_CLASS {97E27FAA-C0B3-4b8e-A693-ED7881E99FC1}
	ControlGetText, text,%A_LoopField%, AHK_CLASS {97E27FAA-C0B3-4b8e-A693-ED7881E99FC1}
	MouseMove, %xx%, %yy%
	ToolTip, %A_Index%
	Sleep, 800
	ToolTip
	FileAppend, X:%xx%|Y:%yy%|W:%ww%|H:%hh%|T:%text%|`n, yosh.txt
	;MsgBox, 4,, Control #%A_Index% is "%temp%". Continue?
	;IfMsgBox, No
;		break
}
return