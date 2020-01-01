MyGetWindowText(ByRef EdtWindowTextFastVisible, ByRef EdtWindowTextSlowVisible, ByRef EdtWindowTextFastHidden,ByRef EdtWindowTextSlowHidden)
{
; Source: https://code.google.com/p/autohotkey-cn/source/browse/trunk/Source/AHK_Window_Info/AHK_Window_Info_v1.7.ahk?r=6
EdtWindowTextFastVisible =
EdtWindowTextSlowVisible =
EdtWindowTextFastHidden =
EdtWindowTextSlowHidden =

WindowControlTextSize = 32767
VarSetCapacity(WindowControlText, WindowControlTextSize)
WinGet, WindowUniqueID, ID, A

;Suggested by Chris
WinGet, ListOfControlHandles, ControlListHwnd, ahk_id %WindowUniqueID% ; Requires v1.0.43.06+.
Loop, Parse, ListOfControlHandles, `n
{
    text_is_fast := true
    If not DllCall("GetWindowText", "uint", A_LoopField, "str", WindowControlText, "int", WindowControlTextSize)
    {
        text_is_fast := false
        SendMessage, 0xD, WindowControlTextSize, &WindowControlText,, ahk_id %A_LoopField% ; 0xD is WM_GETTEXT
    }
    If (WindowControlText <> ""){
        ControlGet, WindowControlStyle, Style,,, ahk_id %A_LoopField%
        If (WindowControlStyle & 0x10000000)
        { ; Control is visible vs. hidden (WS_VISIBLE).
            If text_is_fast
            EdtWindowTextFastVisible = %EdtWindowTextFastVisible%%WindowControlText%`r`n
            Else
            EdtWindowTextSlowVisible = %EdtWindowTextSlowVisible%%WindowControlText%`r`n
        } Else
        { ; Hidden text.
            If text_is_fast
            EdtWindowTextFastHidden = %EdtWindowTextFastHidden%%WindowControlText%`r`n
            Else
            EdtWindowTextSlowHidden = %EdtWindowTextSlowHidden%%WindowControlText%`r`n
        }
    }
}

;EdtWindowTextFastVisibleFull := ShowOnlyAPartInGui("EdtWindowTextFastVisible", EdtWindowTextFastVisible, 400)
;EdtWindowTextSlowVisibleFull := ShowOnlyAPartInGui("EdtWindowTextSlowVisible", EdtWindowTextSlowVisible, 400)
;EdtWindowTextFastHiddenFull := ShowOnlyAPartInGui("EdtWindowTextFastHidden", EdtWindowTextFastHidden, 400)
;EdtWindowTextSlowHiddenFull := ShowOnlyAPartInGui("EdtWindowTextSlowHidden", EdtWindowTextSlowHidden, 400)

Return
}