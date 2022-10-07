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
SetKeyDelay, -1, 1
SetControlDelay, -1
SetMouseDelay, -1
SetWinDelay,-1
ListLines, Off
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
;	 Foobar2000
;	 \ Preferences
;	   \ Components
;		 \ Display
;		   \ Default User Interface
;			 \ Playback state display formatting
;
;  Set the following three boxes to:
;	 %title%
;	 %codec% | %bitrate% kbps | %samplerate% Hz | %channels% | %playback_time%[ / %length%] | [%RATING_STARS_fixed%]
;	 [%artist% - ]%title%
;  or alter the value of FOO_TIME_INDEX to the index of the time in the statusbar
;
;
;  Playback Statistics can be found here: (Rating stars)
;	- foobar2000.org/components/view/foo_playcount
;
;
;  Definitions: ^ = CTRL
;				+ = SHIFT
;
;
;	 #========================================#
;	 |				   Hotkeys				  |
;	 #========================================#
;	 |										  |
;	 | [Gui Movement]						  |
;	 | ^<Gui key> - Fast smooth move		  |
;	 | +<Gui key> - Move					  |
;	 | ^PgUp - Move GUI Up screen			  |
;	 | ^PgDn - Move GUI Down screen 		  |
;	 | ^Del  - Move GUI to left of screen	  |
;	 | ^End  - Move GUI to right of screen	  |
;	 | ^Home - Reset GUI to starting pos	  |
;	 |										  |
;	 | [Media Functions]					  |
;	 | Numpad4 - Previous song				  |
;	 | Numpad5 - Pause/Play 				  |
;	 | Numpad6 - Next song					  |
;	 | Numpad8 - Foobar volume up			  |
;	 | Numpad2 - Foobar volume down 		  |
;	 | Numpad7 - Foobar rating down 		  |
;	 | Numpad9 - Foobar rating up			  |
;	 |										  |
;	 | [Misc Keys]							  |
;	 | F3 - Reload							  |
;	 | ^F3 - Exit							  |
;	 |										  |
;	 #========================================#
;
;//!SECTION Hotkey list


;//SECTION Vars
global appname			:= "foobar2000"
exename 				:= "foobar2000.exe"
idlename				:= "foobar2000 v1.6.2" ;Original script was designed for foobar2000 v1.4.3
classname				:= "{97E27FAA-C0B3-4b8e-A693-ED7881E99FC1}"
stripsongnameend		:= "[foobar2000]"  ;Remove textstamp from what will be displayed
global FOO_TIME_INDEX	:= 5
global FOO_RATING_INDEX := 6
global RATING_STARS 	:= "-----"
nircmd_dir				:= A_ScriptDir . "\nircmd\nircmd.exe"  ;Get: http://www.nirsoft.net/utils/nircmd.html

;Delays (ms)
global COLOUR_CHANGE_DELAY := 200
SONG_CHECK_TIMER		   := 200
;//SECTION GUI Position and Size Settings

;//ANCHOR GUI Coordinate Variables
SCALE_FACTOR  := 1 ;Scale modifier for GUI elements (I use for second monitor)
FONT_SCALE_FACTOR := 1 ;Scale modifier for "Now Playing" song tigle text

GUI_MARGIN_X  := 0
GUI_MARGIN_Y  := 0
global GUI_X  := 0
global GUI_Y  := 600
GUI_WIDTH	  := 270 * SCALE_FACTOR
GUI_HEIGHT	  := 170 * SCALE_FACTOR
SCREEN_WIDTH  := 1920 ;3840
SCREEN_HEIGHT := 1080

;//ANCHOR PREV
GUI_PREV_X	 := 05	* SCALE_FACTOR
GUI_PREV_Y	 := 00	* SCALE_FACTOR
GUI_PREV_W	 := 54	* SCALE_FACTOR
GUI_PREV_H	 := 80	* SCALE_FACTOR

;//ANCHOR Pause/Resume
GUI_PAUSE_X  := 56	* SCALE_FACTOR	;x-position for pause/play symbol when paused
GUI_PAUSE_Y  := -7	* SCALE_FACTOR
GUI_PAUSE_W  := 50	* SCALE_FACTOR
GUI_PAUSE_H  := 100 * SCALE_FACTOR
GUI_RESUME_X := 64	* SCALE_FACTOR ;x-position for pause/play symbol when resume

;//ANCHOR Next
GUI_NEXT_X	 := 116 * SCALE_FACTOR
GUI_NEXT_Y	 := 00	* SCALE_FACTOR
GUI_NEXT_W	 := 54	* SCALE_FACTOR
GUI_NEXT_H	 := 80	* SCALE_FACTOR

;//ANCHOR Volume
GUI_VOL_X	 := 175 * SCALE_FACTOR
GUI_VOL_Y	 := 20	* SCALE_FACTOR
GUI_VOL_W	 := 80	* SCALE_FACTOR
GUI_VOL_H	 := 30	* SCALE_FACTOR

;//ANCHOR Timer
GUI_TIMER_X  := 182 * SCALE_FACTOR
GUI_TIMER_Y  := 60	* SCALE_FACTOR
GUI_TIMER_W  := 80	* SCALE_FACTOR
GUI_TIMER_H  := 18	* SCALE_FACTOR

;//ANCHOR Rating Status
GUI_RATING_X := 175 * SCALE_FACTOR
GUI_RATING_Y := 80	* SCALE_FACTOR
GUI_RATING_W := 85	* SCALE_FACTOR
GUI_RATING_H := 24	* SCALE_FACTOR

;//ANCHOR NowPlaying Status
GUI_NP_X	 := 005 * SCALE_FACTOR
GUI_NP_Y	 := 95	* SCALE_FACTOR
GUI_NP_W	 := 90	* SCALE_FACTOR
GUI_NP_H	 := 16	* SCALE_FACTOR

;//ANCHOR Song Title
GUI_SONG_X	 := 005 * SCALE_FACTOR
GUI_SONG_Y	 := 111 * SCALE_FACTOR
GUI_SONG_W	 := 250 * SCALE_FACTOR
GUI_SONG_H	 := 50	* SCALE_FACTOR


;//!SECTION GUI Position and Size Settings

;//ANCHOR GUI Font Settings
GUI_CONTROLS_SIZE	 := 60 * SCALE_FACTOR
GUI_CONTROLS_FONT	 := "Arial"
GUI_VOLUME_SIZE 	 := 24 * SCALE_FACTOR
GUI_VOLUME_FONT 	 := "Arial"
GUI_TIMER_SIZE		 := 14 * SCALE_FACTOR
GUI_TIMER_FONT		 := "Consolas"
GUI_RATING_SIZE 	 := 18 * SCALE_FACTOR
GUI_RATING_FONT 	 := "Consolas"
GUI_NOWPLAYING_SIZE  := 10 * SCALE_FACTOR * FONT_SCALE_FACTOR
GUI_NOWPLAYING_FONT  := "Arial"
GUI_FONT_COLOUR_ONE  := "FFFFFF"  ;white
GUI_FONT_COLOUR_TWO  := "FF89F1"  ;pastel pink

;//ANCHOR GUI Colours
GUI_TRANSPARENCY	 := 220  ;/255
GUI_COLOUR			 := "c000000"

;//ANCHOR GUI Strings
global playingstring := "()"
global pausedstring  := "||"
prev				 := "<"
next				 := ">"
;//!SECTION Vars


;//SECTION Get Foobar and nircmd
;##################################################################################
;						Initial process for CheckSongName
;##################################################################################
SetTimer, CheckSongName, %SONG_CHECK_TIMER%  ;Find if a song is already playing
SetTimer, CheckPlayingStatus, -200
SetTimer, UpdateRating, 500
SetTimer, Record_Time, 1000


global volume
if (FileExist(appname . "_volume.txt"))
{
	FileRead, readfile, % appname . "_volume.txt"
	readfile := StrSplit(readfile, ",")
	if (readfile.MaxIndex() = 4)
	{
		volume			 := readfile[1]
		volume_increment := readfile[2]
		GUI_X			 := readfile[3]
		GUI_Y			 := readfile[4]
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
		volume_increment = 2
	}
	else if ((volume_increment > 100) or (ErrorLevel))
	{
		volume_increment = 2
	}
}
;//!SECTION Get foobar and nircmd


;//SECTION GUI
;//ANCHOR GUI settings
Gui, +AlwaysOnTop +ToolWindow +LastFound -Caption +E0x20 ;+hwndGUI_Overlay_hwnd
; +AlwaysOnTop - Keep above windows
; +ToolWindow  - Don't show in taskbar
; +LastFound   - For transparency to work
; -Caption	   - Don't include window title
; +E0x20	   - Don't register clicks on window
Gui, Margin, %GUI_MARGIN_X%, %GUI_MARGIN_Y%
Gui, Color, %GUI_COLOUR%

;//ANCHOR Prev-PAUSE-Next
Gui, Font, c%GUI_FONT_COLOUR_ONE% s%GUI_CONTROLS_SIZE% q4, %GUI_CONTROLS_FONT%
Gui, Add, Text, x%GUI_PREV_X%  y%GUI_PREV_Y%  w%GUI_PREV_W%  h%GUI_PREV_H%	vprev, %prev%
Gui, Add, Text, x%GUI_PAUSE_X% y%GUI_PAUSE_Y% w%GUI_PAUSE_W% h%GUI_PAUSE_H% vpauseplay, %pausedstring%
Gui, Add, Text, x%GUI_NEXT_X%  y%GUI_NEXT_Y%  w%GUI_NEXT_W%  h%GUI_NEXT_H%	vnext, %next%

;//ANCHOR Volume
Gui, Font, c%GUI_FONT_COLOUR_ONE% s%GUI_VOLUME_SIZE%, %GUI_VOLUME_FONT%
Gui, Add, Text, x%GUI_VOL_X% y%GUI_VOL_Y% w%GUI_VOL_W% h%GUI_VOL_H% vvolume, %volume%`%

;//ANCHOR Timer
Gui, Font, c%GUI_FONT_COLOUR_TWO% s%GUI_TIMER_SIZE%, %GUI_TIMER_FONT%
Gui, Add, Text, x%GUI_TIMER_X% y%GUI_TIMER_Y% h%GUI_TIMER_H% w%GUI_TIMER_W% vtimer, 0:00

;//ANCHOR Rating Status
Gui, Font, c%GUI_FONT_COLOUR_TWO% s%GUI_RATING_SIZE%, %GUI_RATING_FONT%
Gui, Add, Text, x%GUI_RATING_X% y%GUI_RATING_Y% h%GUI_RATING_H% w%GUI_RATING_W% vrating, ------

;//ANCHOR Nowplaying status
Gui, Font, c%GUI_FONT_COLOUR_ONE% s%GUI_NOWPLAYING_SIZE%, %GUI_NOWPLAYING_FONT%
Gui, Add, Text, x%GUI_NP_X%   y%GUI_NP_Y%   w%GUI_NP_W%   h%GUI_NP_H%, [Now Playing]
Gui, Font, c%GUI_FONT_COLOUR_TWO%
Gui, Add, Text, x%GUI_SONG_X% y%GUI_SONG_Y% w%GUI_SONG_W% h%GUI_SONG_H% vsongtitle, `

;//ANCHOR Gui Show
WinSet, Transparent, %GUI_TRANSPARENCY%
Gui, Show, x%GUI_X% y%GUI_Y% h%GUI_HEIGHT% w%GUI_WIDTH% NoActivate

div_vol := (volume / 100)
Run, %nircmd_dir% setappvolume %exename% %div_vol%	;Match with script's volume seting (0.5) to perform on
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
^Del::	;//ANCHOR Del
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


+Del::	;//ANCHOR Shift+Del
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
^End::	;//ANCHOR End
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
*Numpad4::	;//ANCHOR Numpad4
{
	Send, {Media_Prev}
	GuiControl,, timer, 0:00
	if (playing_status = 0)
	{
		playing_status = 1
		GuiControl,, pauseplay, %playingstring%
		GuiControl, Move, pauseplay, x%GUI_PAUSE_X%
	}
	SetTimer, CheckSongName, %SONG_CHECK_TIMER%
	SetTimer, UpdateRating, 500
	ItemActivated(GUI_FONT_COLOUR_TWO, GUI_CONTROLS_SIZE, "prev", GUI_FONT_COLOUR_ONE)
}
return


$Media_Play_Pause::
*NumpadClear::
*Numpad5::	;//ANCHOR Numpad5
{
	Send, {Media_Play_Pause}
	Sleep, 50
	if (playing_status = 1)
	{
		playing_status = 0
		playpausestring := pausedstring
		GuiControl, Move, pauseplay, x%GUI_RESUME_X%
		GuiControl,, xval, %GUI_RESUME_X%
	}
	else
	{
		playing_status = 1
		playpausestring := playingstring
		GuiControl, Move, pauseplay, x%GUI_PAUSE_X%
	}
	GuiControl, Text, pauseplay, %playpausestring%
	;ItemActivated(GUI_FONT_COLOUR_TWO, "60", "pauseplay", GUI_FONT_COLOUR_ONE)
	Sleep, 10  ;prevents the wrong symbol being displayed
}
return

$Media_Next::
*NumpadRight::
*Numpad6::	;//ANCHOR Numpad6
{
	Send, {Media_Next}
	GuiControl,, timer, 0:00
	if (playing_status = 0)
	{
		playing_status = 1
		GuiControl,, pauseplay, %playingstring%
		GuiControl, Move, pauseplay, x%GUI_PAUSE_X%
	}
	SetTimer, CheckSongName, %SONG_CHECK_TIMER%
	SetTimer, UpdateRating, 500
	ItemActivated(GUI_FONT_COLOUR_TWO, GUI_CONTROLS_SIZE, "next", GUI_FONT_COLOUR_ONE)
}
return


*NumpadUp::
*Numpad8::	;//ANCHOR Numpad8
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
*Numpad2::	;//ANCHOR Numpad2
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


;My keybinds for rating in Foobar with the Playback Statistics plugin:
;  Playback Statistics / Rating / -
*Numpad7::	;//ANCHOR Numpad7
{
	ControlSend,, {NUMPAD7}, AHK_EXE %exename%
}
return


;  Playback Statistics / Rating / +
*Numpad9::	;//ANCHOR Numpad9
{
	ControlSend,, {NUMPAD9}, AHK_EXE %exename%
}
return
;//!SECTION Media Functions


;//SECTION Misc
F3::  ;//ANCHOR F3
{
	reload
	Sleep, 100	;avoids multiple GUIs being created....yeah
}
return


^F3::ExitApp  ;//ANCHOR ^F3
;//!SECTION Misc
;//!SECTION Hotkeys


;//SECTION Labels/Subs, Functions
CheckSongName:	;//ANCHOR CheckSongName
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
		last_song	  := prev_SongName
		prev_SongName := SongName
		SetTimer, Record_Time, 1000
	}
	else if (SongName != prev_SongName) and (SongName != idlename)	;new song found
	{
		GuiControl,, songtitle, %SongName%
		GuiControl,, pauseplay, %playingstring%

		prev_SongName := SongName

		if (playing_status = 0)
		{
			playing_status = 1
			GuiControl,, pauseplay, %playingstring%
			GuiControl, Move, pauseplay, x%GUI_PAUSE_X%
		}

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

	prev_SongName := SongName

	if (playing_status = 0)
	{
		playing_status = 1
		GuiControl,, pauseplay, %playingstring%
		GuiControl, Move, pauseplay, x%GUI_PAUSE_X%
	}
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
	Sleep, %COLOUR_CHANGE_DELAY%
	Gui, Font, c%GUI_FONT_COLOUR_ONE% s%font_size%
	GuiControl, Font, %control_name%
}
return


UpdateRating:
{
	ControlGetText, controltext, ATL:msctls_statusbar321, ahk_class %classname%
	controltext := StrSplit(controltext, " | ")

	if (controltext[FOO_RATING_INDEX] = previousrating)
	{
		return
	}
	else if (controltext[FOO_RATING_INDEX] = "")
	{
		RATING_STARS := "-----"
	}
	else
	{
		RATING_STARS := controltext[FOO_RATING_INDEX]
	}

	previousrating := RATING_STARS
	GuiControl,, rating, %RATING_STARS%
}
return

DoBeforeExit:
{
	Sleep, 500 ;seems to stop a file "_volume.txt" from being created :thonk:
	FileDelete, 					  %appname%_volume.txt
	FileAppend, %volume%,			  %appname%_volume.txt
	FileAppend, `,%volume_increment%, %appname%_volume.txt
	FileAppend, `,%GUI_X%,			  %appname%_volume.txt
	FileAppend, `,%GUI_Y%,			  %appname%_volume.txt
	FileSetAttrib, +H,				  %appname%_volume.txt
	;+H = hide file to try and prevent editing and take up less visual space
	ExitApp
}
return
;//!SECTION


/*	//NOTE Notices
		╔═══════════════════════════════════════════════════════════════╗
		║╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳║
		╠═══════════════════════════════════════════════════════════════╣
		║	My Discord: Lukegotjellyfish#0473							║
		║	GitHub rep: https://github.com/lukegotjellyfish/Media-Keys	║
		╚═══════════════════════════════════════════════════════════════╝
*/