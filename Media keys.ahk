#NoEnv
#SingleInstance, Force
#Persistent
#MaxThreadsPerHotkey, 2
Process, Priority,, High
SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Client
traytip, MediaKeys, Running in background!, 0.1, 16

colour_change_delay := 300
control_send_sleep  := 50 

;##################################################################################
;                       Initial process for CheckSongName
;##################################################################################
WinGet, win, List

Loop, %win% 
{
    WinGetTitle, title, % "ahk_id" . win%A_Index%
    WinGet, spot_name, ProcessName, %title%
    if (spot_name = "Spotify.exe") ;find window (not other spotify exes) from spotify.exe
    {
        initial_playing_status := "||"
        WinGet, spotify, ID, %title%
        Found := 1
        break
    }
}

if !(Found)
{
    ;spotify not found, basic media keys
    initial_playing_status := "||"
}
else
{
    playing_status := -1
    SetTimer, Ini_Playing, -0
    #Persistent
    SetTimer, CheckSongName, 2000
}
;##################################################################################
;                               Media variables
;##################################################################################
;Get: http://www.nirsoft.net/utils/nircmd.html
nircmd_dir := "C:\Users\Luke\Desktop\AHK\nircmd\nircmd.exe"
if FileExist(nircmd_dir)
{
    nircmd := 1
    volume := 0.2  ;default to max volume on spotify vol mixer
    volume_increment := 0.05
    if (Found)
    {
        Run, %nircmd_dir% setappvolume Spotify.exe %volume%  ;Match with script's volume seting (0.5) to perform on
    }
}
else
{
    Hotkey, *Numpad8, OFF
    Hotkey, *Numpad2, OFF
}

playingstring := "||" ; Looks like a pause symbol when larger and bold
pausedstring  := "▶️"
prev := "⏮"
next := "⏭" ; Skip symbol, trust me notepad++ users
if (playing_status != -1)
{
    playing_status := 0
}
prev_SongName := ""
;##################################################################################
;                                    GUI                                           
;##################################################################################
Gui, +AlwaysOnTop -Caption +Owner +LastFound +E0x20
Gui, Margin, 0, 0
Gui, Color, Grey
Gui, Font, cWhite s60 q4 bold, Arial
Gui, Add, Text, x034 y00 w54 h80 vprev, %prev%
if Found
{
    Gui, Add, Text, x120 y00 w54 h100 vpauseplay, %initial_playing_status%
}
else
{
    Gui, Add, Text, x107 y00 w54 h100 vpauseplay, %initial_playing_status%
}
Gui, Add, Text, x170 y00 w54 h80 vnext, %next%



Gui, Font, s10 q4 bold, Arial
if Found
{
    if FileExist(nircmd_dir)
    {
        Gui, Font, cWhite s14 q4 bold, Arial
        Gui, Add, Text, x236 y29 vvol_up, + %volume_increment%
        Gui, Add, Text, x236 y58 vvol_down, -  %volume_increment%
    }
    Gui, Font, s10 q4 bold, Arial
    Gui, Add, Text, x005 y95, Now Playing:
    Gui, Add, Text, x220 y95 vadded, [Not Added]
    Gui, Font, cFF69B4
    Gui, Add, Text, x005 y111 w288 h50 vsongtitle, pending
    WinSet, Transparent, 200
    Gui, Show, x0 y600 h160 w300 NA NoActivate
}
else
{
    WinSet, Transparent, 200
    Gui, Show, x0 y600 h110 w300 NoActivate
}
return
;##################################################################################
;                                  Media keys                                      
;##################################################################################

*Numpad4::
{
    Send, {Media_Prev}
    SetTimer, ChangePrev, -0
    playing_status := 1
    GuiControl,, pauseplay, %playingstring%
    if (Found)
    {
        GoSub, CheckSongName
    }
}
return

*Numpad5::
{
    if (playing_status = 1)
    {
        Send, {Media_Play_Pause}
        playing_status := 0
        GuiControl, Move, pauseplay, x102
        GuiControl,, pauseplay, %pausedstring%
        SetTimer, ChangePause, -0
    }
    else
    {
        Send, {Media_Play_Pause}
        GuiControl, Move, pauseplay, x107
        GuiControl,, pauseplay, %playingstring%
        SetTimer, ChangePause, -0
        playing_status := 1
    }
}
return

*Numpad6::
{
    Send, {Media_Next}
    if playing_status = 0
    {
        playing_status := 1
    }
    GuiControl,, pauseplay, %playingstring%
    SetTimer, ChangeNext, -0
    if (Found)
    {
        GoSub, CheckSongName
    }
}
return

*Numpad8::
{
    if (volume <= 1)
    {
        volume += %volume_increment%
        Run, %nircmd_dir% setappvolume Spotify.exe %volume%
        SetTimer, ChangeVolUp, -0
    }
    else
    {
        SetTimer, ChangeVolUpMaxed, -0
    }
}
return

*Numpad2::
{
    if (volume >= 0)
    {
        volume -= %volume_increment%
        Run, %nircmd_dir% setappvolume Spotify.exe %volume%
        SetTimer, ChangeVolDown, -0
    }
    else
    {
        SetTimer, ChangeVolDownMaxed, -0
    }
}
return

*Numpad3::
{
    WinGet window_state, MinMax, ahk_id %spotify%
    IfEqual, window_state,-1, WinRestore, ahk_id %spotify%
    Sleep, 100
    ControlClick, x16 y639, ahk_id %spotify%,, Right
    Sleep, %control_send_sleep%
    ControlSend,, {UP}, ahk_id %spotify%
    Sleep, %control_send_sleep%
    ControlSend,, {UP}, ahk_id %spotify%
    Sleep, %control_send_sleep%
    ControlSend,, {RIGHT}, ahk_id %spotify%
    Sleep, %control_send_sleep%
    ControlSend,, {DOWN}, ahk_id %spotify%
    Sleep, %control_send_sleep%
    ControlSend,, {ENTER}, ahk_id %spotify%
    Sleep, %control_send_sleep%
    ControlSend,, {UP}, ahk_id %spotify%
    Sleep, %control_send_sleep%
    SetTimer, ChangeAdded, -0
}
return

F3::
{
    Reload
}
return
;##################################################################################
;                                       Subs                                       
;##################################################################################
CheckSongName:
{
    Sleep, 200
    WinGetTitle, SongName, ahk_id %spotify%
    if (SongName != prev_SongName) and (SongName != "Spotify")
    {
        GuiControl,, songtitle, %SongName%
        GuiControl, Move, pauseplay, x107
        GuiControl,, pauseplay, %playingstring%
        SetTimer, ChangeAddedOff, -0
        prev_SongName  := SongName
        playing_status := 1
    }
    else if (playing_status != flag_last) and (playing_status = 0)  ;avoid repeats using flag_last
    {
        GuiControl,, pauseplay, %pausedstring%
        playing_status := 0
        flag_last      := playing_status
    }
}
return

Ini_Playing:  ;pending playing_status "animation"
{
    Ini_Playing_Mod := "On"
    runnum := 1
    Gui, Font, cFF69B4 s60 q4 bold
    GuiControl, Font, pauseplay
    Gui, Show, NoActivate
    While (playing_status = -1)
    {
        if runnum = 1
        {
            initial_playing_status := "|"
            runnum += 1
        }
        else if runnum = 2
        {
            initial_playing_status := "/"
            runnum += 1
        }
        else if runnum = 3
        {
            initial_playing_status := "-"
            runnum += 1
        }
        else
        {
            initial_playing_status := "\"
            runnum := 1 ;return to start
        }
        GuiControl,, pauseplay, %initial_playing_status%
        Sleep, 200
    }
    Gui, Font, cwhite s60 q4 bold
    GuiControl, Font, pauseplay
    SetTimer, Ini_Playing, OFF
}
return

;
;
;

ChangePrev:
{
    Gui, Font, cFF69B4 s60 q4 bold
    GuiControl, Font, prev
    Gui, Show, NoActivate

    Sleep, %colour_change_delay%
    
    Gui, Font, cwhite s60 q4 bold
    GuiControl, Font, prev
    Gui, Show, NoActivate
}
return

ChangePause:
{
    Gui, Font, cFF69B4 s60 q4 bold
    GuiControl, Font, pauseplay
    Gui, Show, NoActivate

    Sleep, %colour_change_delay%
    
    Gui, Font, cwhite s60 q4 bold
    GuiControl, Font, pauseplay
    Gui, Show, NoActivate
}
return

;Skip colour label
ChangeNext:
{    
    Gui, Font, cFF69B4 s60 q4 bold
    GuiControl, Font, next
    Gui, Show, NoActivate

    Sleep, %colour_change_delay%
    
    Gui, Font, cwhite s60 q4 bold
    GuiControl, Font, next
    Gui, Show, NoActivate
}
return

;Volume up colour labels
ChangeVolUp:
{
    Gui, Font, cFF69B4 s14 q4 bold
    GuiControl, Font, vol_up
    Gui, Show, NoActivate

    if (volume_min = True)
    {
        Gui, Font, cwhite s14 q4 bold
        GuiControl, Font, vol_down
        volume_min := False
        Gui, Show, NoActivate
    }

    Sleep, %colour_change_delay%
    
    Gui, Font, cwhite s14 q4 bold
    GuiControl, Font, vol_up
    Gui, Show, NoActivate
    Gui, Font, cwhite s60 q4 bold ;incase changes other items
}
return

ChangeVolUpMaxed:
{
    Gui, Font, c808080 s14 q4 bold
    GuiControl, Font, vol_up
    Gui, Show, NoActivate
    volume_maxed := True
}
return

;Volume down colour labels
ChangeVolDown:
{
    Gui, Font, cFF69B4 s14 q4 bold
    GuiControl, Font, vol_down
    Gui, Show, NoActivate

    if (volume_maxed = True)
    {
        Gui, Font, cwhite s14 q4 bold
        GuiControl, Font, vol_up
        volume_maxed := False
        Gui, Show, NoActivate
    }

    Sleep, %colour_change_delay%
    
    Gui, Font, cwhite s14 q4 bold
    GuiControl, Font, vol_down
    Gui, Show, NoActivate
    Gui, Font, cwhite s60 q4 bold ;incase changes other items
}
return

ChangeVolDownMaxed:
{
    Gui, Font, c808080 s14 q4 bold
    GuiControl, Font, vol_down
    Gui, Show, NoActivate
    volume_min := True
}
return

;Add to playlist colour labels
ChangeAdded:
{
    Gui, Font, cFF69B4 s10 q4 bold
    GuiControl, Move, added, x245
    GuiControl,, added, [Added]
    GuiControl, Font, added
    Gui, Show, NoActivate
}
return

ChangeAddedOff:
{
    Gui, Font, cwhite s10 q4 bold
    GuiControl, Move, added, x220
    GuiControl,, added, [Not Added]
    GuiControl, Font, added
    Gui, Show, NoActivate
}
return
;##################################################################################
;                                End of script
;##################################################################################





;##################################################################################
;                                  Notices
;##################################################################################
/* 
Notices:
                    Made by:
|Discord:           Lukegotjellyfish#0473|
|MPGH.net:          BLURREDDOGE          |
|Unkowncheats.me:   JELLYMAN123          |
|Twitter:           @The_Blurred_Dog     |
https://github.com/lukegotjellyfish/Media-Keys

Copyright (C) 2019  Luke Roper
*/
