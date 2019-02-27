#NoEnv
#SingleInstance, Force
#Persistent
#MaxThreadsPerHotkey, 2
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
traytip, MediaKeys, Running in background!, 0.1, 16

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
    SetTimer, Ini_Playing, 1
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
    volume_increment := 0.02
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
;                           Dual option GUI variables
;##################################################################################
counter_A := 0
counter_B := 0
recoil_status := "Disabled"
auto_fire_status := "Disabled"
;##################################################################################
;                              First part of GUI                                                                 
;##################################################################################
Gui, +AlwaysOnTop -Caption +Owner +LastFound +E0x20
Gui, Margin, 0, 0
Gui, Color, Grey
;##################################################################################
;                          Second part of GUI (Media)                              
;##################################################################################
Gui, Font, cWhite s60 q4 bold, Arial
Gui, Add, Text, x034 y00 w54 h80 vprev, %prev%
Gui, Add, Text, x120 y00 w54 h100 vpauseplay, %initial_playing_status%
Gui, Add, Text, x170 y00 w54 h80 vnext, %next%

Gui, Font, cWhite s14 q4 bold, Arial
Gui, Add, Text, x236 y29 vvol_up, + %volume_increment%
Gui, Add, Text, x236 y58 vvol_down, -  %volume_increment%

Gui, Font, s10 q4 bold, Arial
if Found
{
    Gui, Add, Text, x005 y95, Now Playing:
    Gui, Font, cFF69B4
    Gui, Add, Text, x005 y111 w288 h50 vsongtitle, pending
    WinSet, Transparent, 200
    Gui, Show, x0 y600 h160 w300 NA NoActivate
}
else
{
    WinSet, Transparent, 200
    Gui, Show, x0 y600 h110 w300 NA NoActivate
}
;##################################################################################
;                                  Media keys                                      
;##################################################################################
*Numpad4::
{
    Send, {Media_Prev}
    SetTimer, ChangePrev, -0
    playing_status := 1
    GuiControl,, pauseplay, %playingstring%
    Sleep, 300
    if (Found)
    {
        SetTimer, CheckSongName, -0
    }
}
return

*Numpad5::
{
    if (playing_status = 1)
    {
        Send, {Media_Play_Pause}
        if playing_status = 1
        {
            playing_status := 0
        }
        GuiControl, Move, pauseplay, x102
        GuiControl,, pauseplay, %pausedstring%
        SetTimer, ChangePause, -0
        Sleep, 200
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
    Sleep, 300
    if (Found)
    {
        SetTimer, CheckSongName, -0
    }

}
return

*Numpad8::
{
    if (volume != 1)
    {
        volume += %volume_increment%
        Run, %nircmd_dir% setappvolume Spotify.exe %volume%
        SetTimer, ChangeVolUp, -0
    }
    
}
return

*Numpad2::
{
    if (volume != 0)
    {
        volume -= %volume_increment%
        Run, %nircmd_dir% setappvolume Spotify.exe %volume%
        SetTimer, ChangeVolDown, -0
    }
}
return

;##################################################################################
;                                       Subs                                       
;##################################################################################
CheckSongName:
{
    WinGetTitle, SongName, ahk_id %spotify%
    if (SongName != prev_SongName) and (SongName != "Spotify")
    {
        GuiControl,, songtitle, %SongName%
        GuiControl, Move, pauseplay, x107
        GuiControl,, pauseplay, %playingstring%
        prev_SongName := SongName
        playing_status  := 1
    }
    ;for first run: if no song playing, set to paused
    else if (playing_status != flag_last) and (playing_status = 0)  ;avoid repeats using flag_last
    {
        GuiControl,, pauseplay, %pausedstring%
        playing_status := 0
        flag_last    := playing_status
    }
}
return

Ini_Playing:  ;pending playing_status "animation"
{
    Ini_Playing_Mod := "On"
    runnum := 1
    Gui, Font, cFF69B4 s60 q4 bold
    GuiControl, Font, pauseplay
    Gui, Show, NA NoActivate
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
    Gui, Font, cwhite
    GuiControl, Font, pauseplay
    SetTimer, Ini_Playing, OFF
}
return

ChangePrev:
{
    Gui, Font, cFF69B4 s60 q4 bold
    GuiControl, Font, prev
    Gui, Show, NA NoActivate

    Sleep, 300
    
    Gui, Font, cwhite s60 q4 bold
    GuiControl, Font, prev
    Gui, Show, NA NoActivate
}
return

ChangePause:
{
    Gui, Font, cFF69B4 s60 q4 bold
    GuiControl, Font, pauseplay
    Gui, Show, NA NoActivate

    Sleep, 300
    
    Gui, Font, cwhite s60 q4 bold
    GuiControl, Font, pauseplay
    Gui, Show, NA NoActivate
}
return

ChangeNext:
{    
    Gui, Font, cFF69B4 s60 q4 bold
    GuiControl, Font, next
    Gui, Show, NA NoActivate

    Sleep, 300
    
    Gui, Font, cwhite s60 q4 bold
    GuiControl, Font, next
    Gui, Show, NA NoActivate
}
return

ChangeVolUp:
{
    Gui, Font, cFF69B4 s14 q4 bold
    GuiControl, Font, vol_up
    Gui, Show, NA NoActivate

    Sleep, 300
    
    Gui, Font, cwhite s14 q4 bold
    GuiControl, Font, vol_up
    Gui, Show, NA NoActivate
    Gui, Font, cwhite s60 q4 bold ;incase changes other items
}
return

ChangeVolDown:
{
    Gui, Font, cFF69B4 s14 q4 bold
    GuiControl, Font, vol_down
    Gui, Show, NA NoActivate

    Sleep, 300
    
    Gui, Font, cwhite s14 q4 bold
    GuiControl, Font, vol_down
    Gui, Show, NA NoActivate
    Gui, Font, cwhite s60 q4 bold ;incase changes other items
}
return
;##################################################################################
F3::
{
    Reload
}
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
