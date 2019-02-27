#NoEnv
#SingleInstance, Force
#Persistent
#MaxThreadsPerHotkey, 1
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
traytip, MediaKeys, Running in background!, 0.1, 16


/*
Theory:
If song on spotify is playing, we can InStr and RegMatch it to get the process ID 
(spotify doesn't like) exe interaction or class or anything else (even PID)

If no song is playing, the wintitle will be "Spotify" and it's unlikely that any other wintitle
will be "Spotify" so we fetch the ID from this process
*/

WinGet, win, List
Loop, %win% {
	WinGetTitle, title, % "ahk_id" . win%A_Index%

    if (title = "Spotify")
    {
        WinGetClass, spot_class, %title%
        if (spot_class != "ahk_class Chrome_WidgetWin_1")
        {
            initial_playing_status := "||"
            WinGet, spotify, ID, %title%
            Found := 1
            break
        }
        continue
    }

    if InStr(title, "Spotify") ;Won't actually be spotify, above will be
    {
        continue
    }

	if InStr(title, " - ")
    {
        if InStr(title, "Volume Mixer")
        {
            continue
        }
        if InStr(title, "Autohotkey")
        {
            continue
        }
        if InStr(title, "ahk")
        {
            continue
        }
        FoundPos := RegExMatch(title, "*-*-*")
        if (FoundPos)
        {
            continue
        }
        initial_playing_status := "||"
        WinGet, spotify, ID, %title%
        Found := 1
        break
    }
}

;Timers
;##################################################################################
SetTimer, CheckSongName, 2000 ;Songs are minutes long
;##################################################################################

if !Found
{
    ;spotify not found, basic media keys
    initial_playing_status := "||"
    SetTimer, CheckSongName, OFF
    ;no need to check for spotify if it doesn't exist
}



;Media variables
pauseplay := "||" ; Looks like a pause symbol when larger and bold
prev := "⏮"
next := "⏭" ; Skip symbol, trust me notepad users
pause_status := 0
volume := 0.5  ;default to max volume on spotify vol mixer
prev_SongName := ""

;Dual option GUI variables
counter_A := 0
counter_B := 0
recoil_status := "Disabled"
auto_fire_status := "Disabled"


;##################################################################################
;First part of GUI                                                                 
;##################################################################################
Gui, +AlwaysOnTop -Caption +Owner +LastFound +E0x20
Gui, Margin, 0, 0
Gui, Color, Grey
Gui, Font, cRed s30 bold, Arial
;##################################################################################
;                          Second part of GUI (Media)                              
;##################################################################################
Gui, Font, cWhite s60 q4 bold, Arial
Gui, Add, Text, x034 y00 w54 h80 vprev, %prev%
Gui, Add, Text, x105 y00 w54 h100 vpauseplay, %initial_playing_status%
Gui, Add, Text, x170 y00 w54 h80 vnext, %next%
Gui, Font, s10 q4 bold, Arial
if Found
{
    Gui, Add, Text, x005 y95, Now Playing:
    Gui, Add, Text, x005 y111 w288 h40 vsongtitle, pending
    WinSet, Transparent, 200
    Gui, Show, x0 y600 h150 w300 NA NoActivate
}
else
{
    WinSet, Transparent, 200
    Gui, Show, x0 y600 h110 w300 NA NoActivate
}
;##################################################################################
;                                  Media keys                                      
;##################################################################################
Run, C:\Users\Luke\Desktop\AHK\Media Keys\nircmd\nircmd.exe setappvolume Spotify.exe %volume%

*Numpad4::
{
    Send, {Media_Prev}
    pause_status := 1
    GuiControl,, pauseplay, %pauseplay%
    Sleep, 300
    GoSub, CheckSongName
}
return

*Numpad5::
{
    if (pause_status == 1)
    {
        Send, {Media_Play_Pause}
        pause_status -= 1
        GuiControl,, pauseplay, ▶️
        Sleep, 20
    }
    else
    {
        Send, {Media_Play_Pause}
        GuiControl,, pauseplay, %pauseplay%
        pause_status := 1
    }
}
return

*Numpad6::
{
    Send, {Media_Next}
    pause_status := 1
    GuiControl,, pauseplay, %pauseplay%
    Sleep, 300
    GoSub, CheckSongName
}
return

*Numpad8::
{
    if (volume != 1)
    {
        volume += 0.05
        Run, C:\Users\Luke\Desktop\AHK\Media Keys\nircmd\nircmd.exe setappvolume Spotify.exe %volume%
    }
    
}
return

*Numpad2::
{
    if (volume != 0)
    {
        volume -= 0.05
        Run, C:\Users\Luke\Desktop\AHK\Media Keys\nircmd\nircmd.exe setappvolume Spotify.exe %volume%
    }
}
return


; needs spotify to be minimized because reasons
CheckSongName:
{
    WinGetTitle, SongName, ahk_id %spotify%
    if (SongName != prev_SongName) and (SongName != "Spotify")
    {
        GuiControl,, songtitle, %SongName%
        prev_SongName := SongName
    }
}
return
;##################################################################################

F3::
{
    Reload
}