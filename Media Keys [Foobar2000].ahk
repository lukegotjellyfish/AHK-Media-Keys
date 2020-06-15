;//SECTION Options
#NoEnv
#SingleInstance, Force
#Persistent
#InstallKeybdHook
#InstallMouseHook
#KeyHistory, 0
#MaxThreadsPerHotkey, 1
Process, Priority,, High
SetBatchLines, -1
SendMode Input
SetWorkingDir %A_ScriptDir%
SetKeyDelay,5, 1
SetControlDelay, -1
SetMouseDelay, -1
SetWinDelay,-1
ListLines, Off
CoordMode, Mouse, Client
OnExit DoBeforeExit
;//!SECTION options


if (A_IsAdmin = 0)
{
    try
    {
        if (A_IsCompiled)
        {
            Run *RunAs "%A_ScriptFullPath%" /restart
        }
        else
        {
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
        }
    }
    ExitApp
}


;//SECTION Hotkey list
;"/(!)<name>" are bookmarks (from a VS Code extension) in the code to be navigated with via:
;  https://marketplace.visualstudio.com/items?itemName=ExodiusStudios.comment-anchors
;
;
;  SETUP:
;    Foobar2000
;    \ Preferences
;      \ Components
;        \ Display
;          \ Default User Interface
;            \ Playback state display formatting
;
;  Set the following three boxes to:
;    %title%
;    %codec% | %bitrate% kbps | %samplerate% Hz | %channels% | %playback_time%[ / %length%] | [%rating_stars_fixed%]
;    [%artist% - ]%title%
;  or alter the value of FOO_TIME_INDEX to the index of the time in the statusbar
;
;
;  Playback Statistics can be found here: (Rating stars)
;   - foobar2000.org/components/view/foo_playcount
;
;
;  Definitions: ^ = CTRL
;               + = SHIFT
;
;
;    #========================================#
;    |                 Hotkeys                |
;    #========================================#
;    |                                        |
;    | [Gui Movement]                         |
;    | ^<Gui key> - Fast smooth move          |
;    | +<Gui key> - Move                      |
;    | ^PgUp - Move GUI Up screen             |
;    | ^PgDn - Move GUI Down screen           |
;    | ^Del  - Move GUI to left of screen     |
;    | ^End  - Move GUI to right of screen    |
;    | ^Home - Reset GUI to starting pos      |
;    |                                        |
;    | [Media Functions]                      |
;    | Numpad4 - Previous song                |
;    | Numpad5 - Pause/Play                   |
;    | Numpad6 - Next song                    |
;    | Numpad8 - Foobar volume up             |
;    | Numpad2 - Foobar volume down           |
;    |                                        |
;    | [Misc Keys]                            |
;    | F3 - Reload                            |
;    | ^F3 - Exit                             |
;    |                                        |
;    #========================================#
;
;//!SECTION Hotkey list


;//SECTION Vars
global appname          := "foobar2000"
exename                 := "foobar2000.exe"
idlename                := "foobar2000 v1.4.3"
classname               := "{97E27FAA-C0B3-4b8e-A693-ED7881E99FC1}"
stripsongnameend        := "[foobar2000]"  ;Remove textstamp from what will be displayed
global FOO_TIME_INDEX   := 5
global FOO_RATING_INDEX := 6
nircmd_dir              := A_ScriptDir . "\nircmd\nircmd.exe"  ;Get: http://www.nirsoft.net/utils/nircmd.html

;Delays
colour_change_delay     := 100
control_send_sleep      := 200
song_check_timer        := 200

;GUI Coordinate Variables
GUI_MARGIN_X            := 0
GUI_MARGIN_Y            := 0 
global GUI_X            := 0
global GUI_Y            := 600
GUI_WIDTH               := 270
GUI_HEIGHT              := 170
SCREEN_WIDTH            := 1920
SCREEN_HEIGHT           := 1080
GUI_PAUSED_X            := 56
GUI_RESUME_X            := 64

;GUI Font Settings
GUI_CONTROLS_SIZE       := 60
GUI_CONTROLS_FONT       := "Arial"
GUI_VOLUME_SIZE         := 24
GUI_VOLUME_FONT         := "Arial"
GUI_TIMER_SIZE          := 14
GUI_TIMER_FONT          := "Consolas"
GUI_RATING_SIZE         := 18
GUI_RATING_FONT         := "Consolas"
GUI_NOWPLAYING_SIZE     := "10"
GUI_NOWPLAYING_FONT     := "Arial"
GUI_FONT_COLOUR_ONE     := "FFFFFF"  ;white
GUI_FONT_COLOUR_TWO     := "FF89F1"  ;pastel pink

;GUI Colours
GUI_TRANSPARENCY        := 220  ;/255
GUI_COLOUR              := "c000000"

;GUI Strings
global playingstring    := "()"
global pausedstring     := "||"
prev                    := "<"
next                    := ">"
;//!SECTION Vars


;//SECTION Get Foobar and nircmd
;##################################################################################
;                       Initial process for CheckSongName
;##################################################################################
SetTimer, CheckSongName, %song_check_timer%  ;Find if a song is already playing
SetTimer, CheckPlayingStatus, -50
SetTimer, UpdateRating, 500
SetTimer, Record_Time, 1000


global volume
if (FileExist(appname . "_volume.txt"))
{
    FileRead, readfile, % appname . "_volume.txt"
    readfile := StrSplit(readfile, ",")
    if (readfile.MaxIndex() = 4)
    {
        volume           := readfile[1]
        volume_increment := readfile[2]
        GUI_X            := readfile[3]
        GUI_Y            := readfile[4]
    }

    if (volume < 0)
    {
        volume = 0
    }
    else if (volume > 100)
    {
        volume = 100
    }
    else if (ErrorLevel) ;error, set volume to half
    {
        volume = 50
    }

    if (volume_increment < 0)
    {
        volume_increment = 5
    }
    else if ((volume_increment > 100) or (ErrorLevel))
    {
        volume_increment = 5
    }
}
;//!SECTION Get foobar and nircmd


;//SECTION GUI
;//ANCHOR GUI settings
Gui, +AlwaysOnTop +ToolWindow +LastFound -Caption +E0x20 ;+hwndGUI_Overlay_hwnd
; +AlwaysOnTop - Keep above windows
; +ToolWindow  - Don't show in taskbar
; +LastFound   - For transparency to work
; -Caption     - Don't include window title
; +E0x20       - Don't register clicks on window
Gui, Margin, %GUI_MARGIN_X%, %GUI_MARGIN_Y%
Gui, Color, %GUI_COLOUR%

;//ANCHOR Prev-PAUSE-Next
Gui, Font, c%GUI_FONT_COLOUR_ONE% s%GUI_CONTROLS_SIZE%, %GUI_CONTROLS_FONT%
Gui, Add, Text, x05  		     y00 w54  h80  BackgroundTrans vprev,      %prev%
Gui, Add, Text, x%GUI_PAUSED_X%  y-7 w59  h100 BackgroundTrans vpauseplay, %pausedstring%
Gui, Add, Text, x116 			 y00 w54  h80  BackgroundTrans vnext,      %next%

;//ANCHOR Volume
Gui, Font, c%GUI_FONT_COLOUR_ONE% s%GUI_VOLUME_SIZE%, %GUI_VOLUME_FONT%
Gui, Add, Text, x180 y20 w80 vvolume, %volume%`%

;//ANCHOR Timer
Gui, Font, c%GUI_FONT_COLOUR_TWO% s%GUI_TIMER_SIZE%, %GUI_TIMER_FONT%
Gui, Add, Text, x182 y60 w73 vtimer, 0:00

;//ANCHOR Rating Status
Gui, Font, c%GUI_FONT_COLOUR_TWO% s%GUI_RATING_SIZE%, %GUI_RATING_FONT%
Gui, Add, Text, x163 y73 w86 BackgroundTrans vrating, ------

;//ANCHOR Nowplaying status
Gui, Font, c%GUI_FONT_COLOUR_ONE% s%GUI_NOWPLAYING_SIZE%, %GUI_NOWPLAYING_FONT%
Gui, Add, Text, x005 y95 BackgroundTrans, [Now Playing]
Gui, Font, c%GUI_FONT_COLOUR_TWO%
Gui, Add, Text, x005 y111 w250 h50 BackgroundTrans vsongtitle, `
;//ANCHOR Gui Show
WinSet, Transparent, %GUI_TRANSPARENCY%
Gui, Show, x%GUI_X% y%GUI_Y% h%GUI_HEIGHT% w%GUI_WIDTH% NoActivate

div_vol := (volume / 100)
Run, %nircmd_dir% setappvolume %exename% %div_vol%  ;Match with script's volume seting (0.5) to perform on
return
;//!SECTION


;//SECTION Hotkeys
;//SECTION GUI Hotkeys
^Home::  ;//ANCHOR Ctrl+Home
{
    GUI_Y := 600
    GUI_X := 0
    Gui, Show, x%GUI_X% y%GUI_Y% NoActivate
}
return


;//SECTION PgUp
^PgUp::  ;//ANCHOR Ctrl+PgUp
{
    while (GetKeyState("PgUp", "P"))
    {
        if (GUI_Y > 0)
        {
            GUI_Y -= 10
            Gui, Show, y%GUI_Y% NoActivate
            Sleep, 10
        }
        else
        {
            return
        }
    }
}
return


+PgUp::  ;//ANCHOR Shift+PgUp
{
    if (GUI_Y > 0)
    {
        GUI_Y -= 10
        Gui, Show, y%GUI_Y% NoActivate
        Sleep, 100
    }
    else
    {
        return
    }
}
return
;//!SECTION PgUp


;//SECTION PgDn
^PgDn::  ;//ANCHOR Ctrl+PgDn
{
    while (GetKeyState("PgDn", "P"))
    {
        if (GUI_Y < (SCREEN_HEIGHT - GUI_HEIGHT))
        {
            GUI_Y += 10
            Gui, Show, y%GUI_Y% NoActivate
            Sleep, 10
        }
        else
        {
            return
        }
    }
}
return


+PgDn::  ;//ANCHOR Shift+PgDn
{
    if (GUI_Y < (SCREEN_HEIGHT - GUI_HEIGHT))
    {
        GUI_Y += 10
        Gui, Show, y%GUI_Y% NoActivate
        Sleep, 10
    }
    else
    {
        return
    }
}
return
;//!SECTION PgDn


;//SECTION Del
^Del::  ;//ANCHOR Del
{
    while (GetKeyState("Del", "P"))
    {
        if (GUI_X > 0)
        {
            GUI_X -= 10
            Gui, Show, x%GUI_X% NoActivate
            Sleep, 10
        }
        else
        {
            return
        }
    }
}
return


+Del::  ;//ANCHOR Shift+Del
{
    if (GUI_X > 0)
    {
        GUI_X -= 10
        Gui, Show, x%GUI_X% NoActivate
        Sleep, 10
    }
    else
    {
        return
    }
}
return
;//!SECTION Del


;//SECTION End
^End::  ;//ANCHOR End
{
    while (GetKeyState("End", "P"))
    {
        if (GUI_X < (SCREEN_WIDTH - GUI_WIDTH))
        {
            GUI_X += 10
            Gui, Show, x%GUI_X% NoActivate
            Sleep, 10
        }
        else
        {
            return
        }
    }
}
return


+End::
{
    if (GUI_X < (SCREEN_WIDTH - GUI_WIDTH))
    {
        GUI_X += 10
        Gui, Show, x%GUI_X% NoActivate
        Sleep, 10
    }
    else
    {
        return
    }
}
return
;//!SECTION End
;//!SECTION GUI Hotkeys


;//SECTION Media Functions
$Media_Prev::
*NumpadLeft::
*Numpad4::  ;//ANCHOR Numpad4
{
    Send, {Media_Prev}
    GuiControl,, timer, 0:00
    if (playing_status = 0)
    {
        playing_status = 1
        GuiControl,, pauseplay, %playingstring%
		GuiControl, Move, pauseplay, x%GUI_PAUSED_X%
    }
    SetTimer, CheckSongName, %song_check_timer%
	SetTimer, UpdateRating, 500
    ItemActivated(GUI_FONT_COLOUR_TWO, "60", "prev", GUI_FONT_COLOUR_ONE)
}
return


$Media_Play_Pause::
*NumpadClear::
*Numpad5::  ;//ANCHOR Numpad5
{
    Send, {Media_Play_Pause}
    if (playing_status = 1)
    {
        playing_status = 0
        playpausestring := pausedstring
		GuiControl, Move, pauseplay, x%GUI_RESUME_X%
    }
    else
    {
        playing_status = 1
        playpausestring := playingstring
		GuiControl, Move, pauseplay, x%GUI_PAUSED_X%
    }
    GuiControl, Text, pauseplay, %playpausestring%
    ItemActivated(GUI_FONT_COLOUR_TWO, "60", "pauseplay", GUI_FONT_COLOUR_ONE)
    Sleep, 10  ;prevents the wrong symbol being displayed
}
return

$Media_Next::
*NumpadRight::
*Numpad6::  ;//ANCHOR Numpad6
{
    Send, {Media_Next}
    GuiControl,, timer, 0:00
    if (playing_status = 0)
    {
        playing_status = 1
        GuiControl,, pauseplay, %playingstring%
		GuiControl, Move, pauseplay, x%GUI_RESUME_X%
    }
	else
	{
		GuiControl, Move, pauseplay, x%GUI_PAUSED_X%
	}
    SetTimer, CheckSongName, %song_check_timer%
	SetTimer, UpdateRating, 500
    ItemActivated(GUI_FONT_COLOUR_TWO, "60", "next", GUI_FONT_COLOUR_ONE)
}
return


*NumpadUp::
*Numpad8::  ;//ANCHOR Numpad8
{
	if (volume + volume_increment > 100)
	{
		volume = 100
		GuiControl,, volume, %volume%`%
	}
	else
	{
		volume += %volume_increment%
		GuiControl,, volume, %volume%`%
	}
	div_vol := (volume / 100)
	Run, %nircmd_dir% setappvolume %exename% %div_vol%
}
return


*NumpadDown::
*Numpad2::  ;//ANCHOR Numpad2
{
    if (volume - volume_increment < 0)
    {
        volume = 0
    }
    else
    {
        volume -= %volume_increment%
    }
    div_vol := (volume / 100)
    GuiControl,, volume, %volume%`%
    Run, %nircmd_dir% setappvolume %exename% %div_vol%
}
return


~Media_Stop::  ;//ANCHOR Media_Stop
{
    controltext := "0:00"
    GuiControl,, SongTitle, `
    GuiControl,, Timer, %controltext%
}
return
;//!SECTION Media Functions


;//SECTION Misc
F3::  ;//ANCHOR F3
{
    reload
    Sleep, 100  ;avoids multiple GUIs being created....yeah
}
return


^F3::ExitApp  ;//ANCHOR ^F3
;//!SECTION Misc
;//!SECTION Hotkeys


;//SECTION Labels/Subs, Functions
CheckSongName:  ;//ANCHOR CheckSongName
{
    WinGetTitle, SongName, ahk_class %classname%
    if InStr(SongName, "&")
    {
        SongName := RegExReplace(SongName, "&", "+")
    }
	if InStr(SongName, "_")
	{
		if InStr(SongName, "_",,2)
		{
			rule := "|"
		}
		else
		{
			rule := ""
		}
		SongName := RegExReplace(SongName, "_", rule)
	}

    SongName := StrSplit(SongName, stripsongnameend)
    SongName := SongName[1]

    if (SongName != prev_SongName) and (SongName = idlename)  ;no song playing
    {
        playing_status = 0
        GuiControl,, pauseplay, %pausedstring%
        last_song     := prev_SongName
        prev_SongName := SongName
        SetTimer, Record_Time, 1000
    }
    else if (SongName != prev_SongName) and (SongName != idlename)  ;new song found
    {
        GuiControl,, songtitle, %SongName%
        GuiControl,, pauseplay, %playingstring%

        if (was_paused = 1)
        {
            was_paused = 0
        }

        prev_SongName := SongName
        playing_status = 1

        if (SongName != last_song)
        {
            SetTimer, Record_Time, 1000
        }
    }
}
return

CheckPlayingStatus:  ;ANCHOR CheckPlayingStatus
{
    WinGetTitle, SongName, ahk_class %classname%
    if InStr(SongName, "&")
    {
        SongName := RegExReplace(SongName, "&", "and")
    }

    SongName := StrSplit(SongName, stripsongnameend)
    SongName := SongName[1]

    GuiControl,, songtitle, %SongName%
    GuiControl,, pauseplay, %playingstring%
    if (was_paused = 1)
    {
        was_paused = 0
    }

    prev_SongName := SongName
    playing_status = 1
    ;MsgBox, playing
}


Record_Time:  ;//ANCHOR Timer
{
    ControlGetText, controltext, ATL:msctls_statusbar321, ahk_class %classname%
    controltext := StrSplit(controltext, " | ")
    controltext := StrSplit(controltext[FOO_TIME_INDEX], "/")[1]
    if (controltext > 0)
    {
        GuiControl,, timer, %controltext%
    }
}
return


ItemActivated(GUI_FONT_COLOUR_TWO, font_size, control_name, GUI_FONT_COLOUR_ONE)  ;//ANCHOR ItemActivated procedure
{
    Gui, Font, c%GUI_FONT_COLOUR_TWO% s%font_size%
    GuiControl, Font, %control_name%
    Sleep, 100
    Gui, Font, c%GUI_FONT_COLOUR_ONE% s%font_size%
    GuiControl, Font, %control_name%
}
return


UpdateRating:
{
    ControlGetText, controltext, ATL:msctls_statusbar321, ahk_class %classname%
    controltext := StrSplit(controltext, " | ")
    rating_stars := controltext[FOO_RATING_INDEX]
    GuiControl,, rating, %rating_stars%
}
return

DoBeforeExit:
{
    Sleep, 100 ;seems to stop a file "_volume.txt" from being created :thonk:
    FileDelete, %appname%_volume.txt
    FileAppend, %volume%, %appname%_volume.txt
    FileAppend, `,%volume_increment%, %appname%_volume.txt
    FileAppend, `,%GUI_X%, %appname%_volume.txt
    FileAppend, `,%GUI_Y%, %appname%_volume.txt
    FileSetAttrib, +H, %appname%_volume.txt
    ;+H = hide file to try and prevent editing and take up less visual space
    ExitApp
}
return
;//!SECTION


/*  //NOTE Notices
╔════════════════════════════════════════════════════════════════════════════════╗
║╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳║
╠════════════════════════════════════════════════════════════════════════════════╣
║    My Discord: Lukegotjellyfish#0473                                           ║
║    GitHub rep: https://github.com/lukegotjellyfish/Media-Keys                  ║
║    Copyright (C) 2019  Luke Roper                                              ║
╚════════════════════════════════════════════════════════════════════════════════╝
*/