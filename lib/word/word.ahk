#Requires AutoHotkey v2.0
#SingleInstance force

AppMain()
AppMain(){
    text := ReceivParameter()

    result := DllCall("user32.dll\OpenClipboard")
    If(result = 0){
        MsgBox "OpenClipboard failed"
        return
    }
    DllCall("user32.dll\EmptyClipboard")

    html_code := DllCall("user32.dll\RegisterClipboardFormat", "Ptr", StrBuf("HTML Format","UTF-16"))

    DllCall("user32.dll\SetClipboardData", "UInt", html_code, "Ptr", StrBuf(text,"UTF-8"))
    DllCall("user32.dll\CloseClipboard")

    Send "{LCtrl down}"
    Send "{v}"
    Send "{LCtrl up}"

 ; Copy or convert a string.
    StrBuf(str, encoding) {
        ; Calculate required size and allocate buffer.
        buf := Buffer(StrPut(str, encoding))
        ; Copy or convert a string.
        StrPut(str, buf, encoding)
        return buf
    }
}
ReceivParameter(){
 ; if no parameters
  if (A_Args.Length = 0) {
      return false
  }

  params := ""
  ; Loop through the parameters and display them on the console
  for n, param in A_Args{
    params .= param " "
  }
  return Trim(params)
}

