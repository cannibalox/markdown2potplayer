#Requires AutoHotkey v2.0

; Modify seconds and return new time format
ReduceTime(originalTime, secondsToModify) {
  seconds := TimeToSeconds(originalTime)

  newSeconds := seconds - secondsToModify

  if (newSeconds < 0){
    newSeconds := 0
  }

  result := SecondsToTimeFormat(newSeconds)
  return result GetMilliseconds(originalTime)
}

GetMilliseconds(originalTime) {
  ms := ""
  if (InStr(originalTime,".")){
    ms := SubStr(originalTime, InStr(originalTime,"."))
  }
  return ms
}

; Convert time string to seconds
TimeToSeconds(timeStr) {
  RegExMatch(timeStr, "^((?<hours>\d+):)?((?<minutes>[0-5][0-9]):)?(?<seconds>[0-5][0-9])(\.(?<ms>\d+))?$", &matches)
  h := matches.hours ? matches.hours : 0
  m := matches.minutes ? matches.minutes : 0
  s := matches.seconds ? matches.seconds : 0
  ms := matches.seconds

; Fixed regular expression bug: when the incoming data is "16:34", h=16, m=0, s=34 will appear.
  if (CountCharOccurrences(timeStr, ":") = 1) {
    if (h > 0 && m = 0 && s >= 0) {
      m := h
      h := 0
    }
  }
  
  result := (h * 3600) + (m * 60) + s
  return result
}

; Find the total number of `char` characters in a string
CountCharOccurrences(string, char) {
  parts := StrSplit(string, char)
  if parts.Length > 1 {
    return parts.Length - 1
  }
  return parts.Length
}

; Convert seconds back to original format
SecondsToTimeFormat(duration) {
  if (duration < 60){
    if (duration < 10){
      duration := "00:0" duration
    }
    return "00:" duration
  }

  seconds := Mod(duration , 60)
  minutes := Mod(duration // 60,60)
  hours := duration // 3600
  
  ModifyTimeFormat(&hours, &minutes, &seconds)

  if (hours > 0){
    return hours ":" minutes ":" seconds
  }
  else{
    return minutes ":" seconds
  }
}

; Correct display format of seconds and minutes
ModifyTimeFormat(&hours, &minutes, &seconds) {
  if (hours = 0){
    hours := "00"
  } else if (hours < 10){
    hours := "0" hours
  }

  if (minutes = 0){
    minutes := "00"
  }else if (minutes < 10){
    minutes := "0" minutes
  }
  
  if (seconds = 0){
    seconds := "00"
  } else if (seconds < 10){
    seconds := "0" seconds
  }
}

; Example
; originalTime2 := "00:00:59"
; MsgBox TimeToSeconds(originalTime2)
; newTime2 := ReduceTime(originalTime2, 3)
; MsgBox newTime2
