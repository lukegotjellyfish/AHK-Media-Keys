﻿#NoEnv
#SingleInstance, Force
#Persistent
#MaxThreadsPerHotkey, 1
Process, Priority,, High
SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Client
traytip, MediaKeys, Running in background!, 0.1, 16

;//ANCHOR Vars
colour_change_delay := 100
control_send_sleep  := 50
song_check_timer    := 200
song_time_passed    := 0
playingstring       := "||"
pausedstring        := "▶️"
prev                := "⏮"
next                := "⏭"
nircmd_dir          := "C:\Users\Luke\Desktop\AHK\nircmd\nircmd.exe"  ;Get: http://www.nirsoft.net/utils/nircmd.html
paused_delay        := 35  ;[PAUSED] animation delay

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
    SetTimer, CheckSongName, %song_check_timer%
}
;##################################################################################
;                               Setup
;##################################################################################
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

if (playing_status != -1)
{
    playing_status := 0
}
prev_SongName := ""
;##################################################################################
;                                    GUI                              ;//ANCHOR GUI                                   
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
        Gui, Font, cFF69B4 s10 q4 bold, Arial
        Gui, Add, Text, x210 y10 w90 vvolume, Volume: 20`%
        Gui, Font, cWhite s8 q4 bold, Arial
        Gui, Add, Text, x236 y80 w64 vtimer, Time: 0
    }
    Gui, Font, s10 q4 cWhite bold, Arial
    Gui, Add, Text, x005 y105, Now Playing:
    Gui, Add, Text, x220 y105 vadded, [Not Added]
    Gui, Font, cFF69B4
    Gui, Add, Text, x005 y121 w288 h50 vsongtitle, pending
    WinSet, Transparent, 200
    Gui, Show, x0 y600 h170 w300 NoActivate
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
*NumpadLeft::
*Numpad4::  ;//ANCHOR Numpad4
{
    Send, {Media_Prev}
    SetTimer, ChangePrev, -0
    playing_status := 1
    GuiControl,, pauseplay, %playingstring%
    if (Found)
    {
        GoSub, CheckSongName
    }
    song_time_passed := 0
}
return

*NumpadClear::
*Numpad5::  ;//ANCHOR Numpad5
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
    Sleep, 10  ;prevents the wrong symbol being displayed
}
return

*NumpadRight::
*Numpad6::  ;//ANCHOR Numpad6
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
    song_time_passed := 0
}
return

*NumpadUp::
*Numpad8::  ;//ANCHOR Numpad8
{
    favolume := RegExReplace(RegExReplace(volume,"(\.\d*?)0*$","$1"),"\.$")
    if (favolume = 0.95)
    {
        volume = 1
        SetTimer, SetVolume, -0
        Run, %nircmd_dir% setappvolume Spotify.exe %volume%
        SetTimer, ChangeVolUpMaxed, -0
        
    }
    else if !(favolume = 1)
    {   
        volume += %volume_increment%
        SetTimer, SetVolume, -0
        Run, %nircmd_dir% setappvolume Spotify.exe %volume%
        SetTimer, ChangeVolUp, -0
    }
    Sleep, 50
}
return

*NumpadDown::
*Numpad2::  ;//ANCHOR Numpad2
{
    favolume := RegExReplace(RegExReplace(volume,"(\.\d*?)0*$","$1"),"\.$")
    if (favolume = 0.05)
    {
        volume = 0
        SetTimer, SetVolume, -0
        Run, %nircmd_dir% setappvolume Spotify.exe %volume%
        SetTimer, ChangeVolDownMaxed, -0
    }
    else if !(favolume = 0)
    {
        volume -= %volume_increment%
        SetTimer, SetVolume, -0
        Run, %nircmd_dir% setappvolume Spotify.exe %volume%
        SetTimer, ChangeVolDown, -0
    }
    Sleep, 50  ;avoid overflow or conflict in font
}
return

*NumpadPGDN::
*Numpad3::  ;//ANCHOR Numpad3
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

F3::  ;//ANCHOR F3
{
    Reload
}
return
;##################################################################################
;                                       Subs                                       
;##################################################################################
;//SECTION Labels/Subs, Functions 
Ini_Playing:  ;//ANCHOR Ini_Playing
{
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
            runnum = 1 ;return to start
        }
        GuiControl,, pauseplay, %initial_playing_status%
        Sleep, 125
    }
    Gui, Font, cwhite s60 q4 bold
    GuiControl, Font, pauseplay
    SetTimer, Ini_Playing, OFF
}
return

CheckSongName:  ;//ANCHOR CheckSongName
{
    WinGetTitle, SongName, ahk_id %spotify%
    if InStr(SongName, "&")
    {
        SongName := RegExReplace(SongName, "&", "and")
    }
    if (SongName != prev_SongName) and (SongName = "Spotify")
    {
        playing_status := 0
        GuiControl, Move, pauseplay, x102
        GuiControl,, pauseplay, %pausedstring%
        SetTimer, toggle_paused, -0
        Sleep, 10
        prev_SongName  := SongName
        SetTimer, ChangePause, -0
    }
    else if (SongName != prev_SongName) and (SongName != "Spotify")
    {
        GuiControl,, songtitle, %SongName%
        GuiControl, Move, pauseplay, x107
        GuiControl,, pauseplay, %playingstring%
        if (was_paused = 1)
        {
            SetTimer, toggle_paused_off, -0
            Sleep, 10
            was_paused = 0
        }
        SetTimer, ChangeAddedOff, -0
        SetTimer, ChangePause, -0
        prev_SongName  := SongName
        playing_status := 1

        if (last_song != SongName)
        {
            song_time_passed := 0
            GuiControl,, timer, Time: %song_time_passed%
        }
    }
    else if (SongName = prev_SongName) and (SongName != "Spotify")
    {
        if (Mod(song_time_passed, 5) = 0)
        {
            song_time_passed_t := RegExReplace(RegExReplace(song_time_passed / 5,"(\.\d*?)0*$","$1"),"\.$")
        }
        last_song      := SongName
        song_time_passed += 1
        GuiControl,, timer, Time: %song_time_passed_t%
    }
}
return

toggle_paused:  ;//ANCHOR toggle_paused
{
    GuiControl,, songtitle, %prev_SongName% [
    Sleep, %paused_delay%
    GuiControl,, songtitle, %prev_SongName% [P
    Sleep, %paused_delay%
    GuiControl,, songtitle, %prev_SongName% [PA
    Sleep, %paused_delay%
    GuiControl,, songtitle, %prev_SongName% [PAU
    Sleep, %paused_delay%
    GuiControl,, songtitle, %prev_SongName% [PAUS
    Sleep, %paused_delay%
    GuiControl,, songtitle, %prev_SongName% [PAUSE
    Sleep, %paused_delay%
    GuiControl,, songtitle, %prev_SongName% [PAUSED
    Sleep, %paused_delay%
    GuiControl,, songtitle, %prev_SongName% [PAUSED]
    was_paused := 1
}
return

toggle_paused_off:  ;//ANCHOR toggle_paused_off
{
    GuiControl,, songtitle, %SongName% [PAUSED
    Sleep, %paused_delay%
    GuiControl,, songtitle, %SongName% [PAUSE
    Sleep, %paused_delay%
    GuiControl,, songtitle, %SongName% [PAUS
    Sleep, %paused_delay%
    GuiControl,, songtitle, %SongName% [PAU
    Sleep, %paused_delay%
    GuiControl,, songtitle, %SongName% [PA
    Sleep, %paused_delay%
    GuiControl,, songtitle, %SongName% [P
    Sleep, %paused_delay%
    GuiControl,, songtitle, %SongName% [
    Sleep, %paused_delay%
    GuiControl,, songtitle, %SongName%
}
return

ChangePrev:  ;//ANCHOR ChangePrev
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

ChangePause:  ;//ANCHOR ChangePause
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
ChangeNext:  ;//ANCHOR ChangeNext
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
ChangeVolUp:  ;//ANCHOR ChangeVolUp
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
    ResetVol("vol_up")
}
return

ChangeVolUpMaxed:  ;//ANCHOR ChangeVolUpMaxed
{
    SetTimer, ChangeVolUp, Off
    Gui, Font, c808080 s14 q4 bold
    GuiControl, Font, vol_up
    Gui, Show, NoActivate
    volume_maxed := True
}
return

;Volume down colour labels
ChangeVolDown:  ;//ANCHOR ChangeVolDown
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
    ResetVol("vol_down")
}
return

ChangeVolDownMaxed:  ;//ANCHOR ChangeVolDownMaxed
{
    SetTimer, ChangeVolDown, Off
    Gui, Font, c808080 s14 q4 bold
    GuiControl, Font, vol_down
    Gui, Show, NoActivate
    volume_min := True
}
return

SetVolume:  ;//ANCHOR SetVolume
{
    num := (volume) * 100
    num := RegExReplace(RegExReplace(num,"(\.\d*?)0*$","$1"),"\.$")
    GuiControl,, volume, Volume: %num%`%
}
return

ResetVol(x)  ;//ANCHOR ResetVol(x)
{
    Gui, Font, cwhite s14 q4 bold
    GuiControl, Font, %x%
    Gui, Show, NoActivate
    Gui, Font, cwhite s60 q4 bold ;incase changes other items
}
return

;Add to playlist colour labels
ChangeAdded:  ;//ANCHOR ChangeAdded
{
    Gui, Font, cFF69B4 s10 q4 bold
    GuiControl, Move, added, x245
    GuiControl,, added, [Added]
    GuiControl, Font, added
    Gui, Show, NoActivate
}
return

ChangeAddedOff:  ;//ANCHOR ChangeAddedOff
{
    Gui, Font, cwhite s10 q4 bold
    GuiControl, Move, added, x220
    GuiControl,, added, [Not Added]
    GuiControl, Font, added
    Gui, Show, NoActivate
}
return


/* //NOTE Notices
╔════════════════════════════════════════════════════════════════════════════════╗
║╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳║
╠════════════════════════════════════════════════════════════════════════════════╣
║    My Discord: Lukegotjellyfish#0473                                           ║
║    GitHub rep: https://github.com/lukegotjellyfish/Media-Keys                  ║
║    Copyright (C) 2019  Luke Roper                                              ║
╚════════════════════════════════════════════════════════════════════════════════╝
*/