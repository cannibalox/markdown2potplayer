#Requires AutoHotkey v2.0
#SingleInstance force
#Include ..\MyTool.ahk
#Include sqlite\SqliteControl.ahk
#Include ..\PotplayerControl.ahk
#Include ..\ReduceTime.ahk

; 1. init
potplayer_path := GetKeyName("path")
open_window_parameter := InitOpenWindowParameter(potplayer_path)
potplayer := PotplayerControl(GetNameForPath(potplayer_path))

InitOpenWindowParameter(potplayer_path){
  if (IsPotplayerRunning(potplayer_path)) {
    return "/current"
  } else {
    return "/new"
  }
}
; 2. Main logic
AppMain()
AppMain(){
  CallbackPotplayer()
}

; [Main logic] Potplayer's callback function (back link)
CallbackPotplayer(){
  url := ReceivParameter()
  if url{
    ParseUrl(url)
  }else{
    MsgBox "Pass at least 1 parameter"
  }
  ExitApp
}

ReceivParameter(){
  ; Get the number of command line parameters
  paramCount := A_Args.Length

  ; If there are no parameters, display a prompt message
  if (paramCount = 0) {
      return false
  }

  params := ""
  ; Loop through the parameters and display them on the console
  for n, param in A_Args{
    params .= param " "
  }
  return Trim(params)
}

ParseUrl(url){
  ;url := "jv://open?path=https://www.bilibili.com/video/123456/?spm_id_from=..search-card.all.click&time=00:01:53.824"
  ; MsgBox url
  url := UrlDecode(url)
  index_of := InStr(url, "?")
  parameters_of_url := SubStr(url, index_of + 1)

  ; 1. Parse key-value pairs
  parameters := StrSplit(parameters_of_url, "&")
  parameters_map := Map()

  ; 1.1 Ordinary analysis
  for index, pair in parameters {
    index_of := InStr(pair, "=")
    if (index_of > 0) {
      key := SubStr(pair, 1, index_of - 1)
      value := SubStr(pair, index_of + 1)
      parameters_map[key] := value
    }
  }
  
  ; 1.2 Special treatment for the path parameter, because the path may be a URL
  path := SubStr(parameters_of_url,1, InStr(parameters_of_url, "&time=") -1)
  path := StrReplace(path, "path=", "")
  parameters_map["path"] := path

  ; 2. Jump to Potplayer
  ; D:\PotPlayer64\PotPlayerMini64.exe "D:\123.mp4" /seek=00:01:53.824 /new
  media_path := parameters_map["path"]
  media_time := parameters_map["time"]

 ; Case 0: The same video is being jumped. The AB loop may have been set before, so cancel the A-B loop here first.
  if(IsPotplayerRunning(potplayer_path)){
    if(IsSameVideo(media_path)){
      potplayer.CancelTheABCycle()
    }
  }

  ; Case 1: Single timestamp 00:01:53
  if(IsSingleTimestamp(media_time)){
    if(IsPotplayerRunning(potplayer_path)){
      if(IsSameVideo(media_path)){
        potplayer.SetCurrentSecondsTime(TimeToSeconds(media_time))
        potplayer.Play()
        return
      }
    }
    OpenPotplayerAndJumpToTimestamp(media_path, media_time)
  ; Case 2: timestamp fragment 00:01:53-00:02:53
  } else if(IsAbFragment(media_time)){
    if(GetKeyName("loop_ab_fragment")){
      JumpToAbCirculation(media_path, media_time)
    }else{
      JumpToAbFragment(media_path, media_time)
    }
; Case 3: timestamp loop 00:01:53∞00:02:53
  } else if(IsAbCirculation(media_time)){
    JumpToAbCirculation(media_path, media_time)
  }
  ExitApp()
}

; Parse time segment string
ParseTimeFragmentString(media_time){
  ; 1. Parse timestamp
  time_separator := ["∞", "-"]

  index_of := ""
  Loop time_separator.Length{
    index_of := InStr(media_time, time_separator[A_Index])
    if(index_of > 0){
      break
    }
  }
  Assert(index_of == "", "Timestamp format error")

  time := {}
  time.start := SubStr(media_time, 1, index_of - 1)
  time.end := SubStr(media_time, index_of + 1)
  return time
}

; Determine whether the currently playing video is a jump video
IsSameVideo(media_path){
    ; Judge online videos
    if(InStr(media_path,"http")){
      potplayer_media_path := GetPotplayerMediaPath()
      if(InStr(media_path,potplayer_media_path)){
        return true
      }

      GetPotplayerMediaPath(){
        A_Clipboard := ""
        potplayer.GetMediaPathToClipboard()
        ClipWait 1,0
        media_path := A_Clipboard
        return media_path
      }
    }
    
   ; Determine local video
    potplayer_title := WinGetTitle("ahk_id " potplayer.GetPotplayerHwnd())
    if (InStr(potplayer_title, GetNameForPath(media_path))) {
      return true
    }
}

; If the string does not contain "-, ∞", it is a single timestamp.
IsSingleTimestamp(media_time){
  if(InStr(media_time, "-") > 0 || InStr(media_time, "∞") > 0)
    return false
  else
    return true
}
; Jump using timestamp
OpenPotplayerAndJumpToTimestamp(media_path, media_time){
  run_command := potplayer_path . " `"" . media_path . "`" /seek=" . media_time . " " . open_window_parameter
  try{
    Run run_command
  } catch Error as err
    if err.Extra{
      MsgBox "mistake：" err.Extra
      MsgBox run_command
    } else {
      throw err
    }
}

IsAbFragment(media_time){
  if(InStr(media_time, "-") > 0)
    return true
  else
    return false
}
JumpToAbFragment(media_path, media_time){
  ; 1. parse timestamp
  time := ParseTimeFragmentString(media_time)

  call_data := {}
  call_data.potplayer_path := potplayer_path
  call_data.media_path := media_path
  call_data.time := time
  
  ; 2. Jump
  CallPotplayer(call_data)
  Sleep 500

  flag_ab_fragment := true

  Hotkey "Esc", CancelAbFragment
  CancelAbFragment(*){
    flag_ab_fragment := false
    Hotkey "Esc", "off"
  }

; 3. Check end time
  while (flag_ab_fragment) {
    ; Exception: User closes Potplayer
    if (!IsPotplayerRunning(potplayer_path)) {
      break
      ; Exception: user stops playing the video
    } else if (potplayer.GetPlayStatus() != "Running") {
      break
      ; Abnormal situation: Not the same video --> When playing the video of station B, you can load the video list, so that the user will switch videos, and the loop will end at this time
    } else if (!IsSameVideo(media_path)) {
      break
    }

; Normal situation: the current playback time exceeds the end time, the user manually adjusts the time, and exceeds the end time.
    current_time := potplayer.GetCurrentSecondsTime()
    if (current_time >= TimeToSeconds(time.end)) {
      potplayer.PlayPause()
      Hotkey "Esc", "off"
      break
    }
    Sleep 1000
  }
}

IsAbCirculation(media_time){
  if(InStr(media_time, "∞") > 0)
    return true
  else
    return false
}
JumpToAbCirculation(media_path, media_time){
  time := ParseTimeFragmentString(media_time)

  call_data := {}
  call_data.potplayer_path := potplayer_path
  call_data.media_path := media_path
  call_data.time := time
  
; 2. Jump
  CallPotplayer(call_data)

  ; 3. Set the starting point of A-B loop
  potplayer.SetStartPointOfTheABCycle()

  ; 4. Set the end point of the A-B cycle
  potplayer.SetCurrentSecondsTime(TimeToSeconds(time.end))
  potplayer.SetEndPointOfTheABCycle()
}

CallPotplayer(call_data){
  if(IsPotplayerRunning(call_data.potplayer_path)){
    if(IsSameVideo(call_data.media_path)){
      potplayer.SetCurrentSecondsTime(TimeToSeconds(call_data.time.start))
      potplayer.Play()
    }else{
 ; Play the specified video
      PlayVideo(call_data.media_path, call_data.time.start)
    }
  }else{
    PlayVideo(call_data.media_path, call_data.time.start)
  }
}
PlayVideo(media_path, time_start){
  OpenPotplayerAndJumpToTimestamp(media_path, time_start)
  WaitForPotplayerToFinishLoadingTheVideo(GetNameForPath(media_path))
  potplayer.Play()
}
WaitForPotplayerToFinishLoadingTheVideo(video_name){
  WinWait("ahk_exe " GetNameForPath(potplayer_path))

  hwnd := potplayer.GetPotplayerHwnd()
 ; Determine the status of the current potplayer player
  potplayer_is_open := IsPotplayerOpen(hwnd)
  if(potplayer_is_open){
    ; Wait for Potplayer to load the video, jump from the previous video to the next video, the name of the window will change => PotPlayer -123.mp4 => Potplayer => PotPlayer -456.mp4
    while (true) {
      if(WinGetTitle("ahk_id " hwnd) == "PotPlayer"){
        break
      }
      Sleep 100
    }
    
    ; Jump to the next video, wait for the video to load, and check whether the player has started playing
    ; Newly opened Potplayer, already opened Potplayer jumps to the next video, waits for the video to be loaded, and checks whether the player has started playing.
    while (potplayer.GetPlayStatus() != "Running") {
      Sleep 1000
    }
  }else{
   ; Open Potplayer to jump to the next video, wait for the video to load, and check whether the player has started playing.
    while (true) {
      if(InStr(WinGetTitle("ahk_id " hwnd),video_name)
        && (potplayer.GetPlayStatus() == "Running")){
        break
      }
      Sleep 1000
    }
  }
}
IsPotplayerOpen(hwnd){
  return WinGetTitle("ahk_id " hwnd) != "PotPlayer"
}