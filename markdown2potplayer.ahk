#Requires AutoHotkey v2.0
#SingleInstance force
#Include "lib\note2potplayer\RegisterUrlProtocol.ahk"
#Include "lib\MyTool.ahk"
#Include "lib\ReduceTime.ahk"
#Include "lib\TemplateParser.ahk"
#Include "lib\sqlite\SqliteControl.ahk"
#Include lib\socket\Socket.ahk

#Include lib\entity\Config.ahk
#Include lib\PotplayerControl.ahk
#Include lib\gui\GuiControl.ahk

main()

main(){
    global
    TraySetIcon("lib/icon.png", 1, false)
    
    InitSqlite()

    app_config := Config()
    potplayer_control := PotplayerControl(app_config.PotplayerProcessName)

    InitGui(app_config, potplayer_control)

    InitServer()

    RegisterUrlProtocol(app_config.UrlProtocol)

    RegisterHotKey()
}

InitServer() {
    sock := winsock("server", callback, "IPV4")
    sock.Bind("0.0.0.0", 33660)
    sock.Listen()

    callback(sock, event, err) {
        if (sock.name = "server") || instr(sock.name, "serving-") {
            if (event = "accept") {
                sock.Accept(&addr, &newsock) ; pass &addr param to extract addr of connected machine
            } else if (event = "close") {
            } else if (event = "read") {
                If !(buf := sock.Recv()).size
                    return

                ; returnhtml
                html_body := '<h1>open potplayer...</h1>'
                httpResponse := "HTTP/1.1 200 0K`r`n"
                    . "Content-Type: text/html; charset=UTF-8`r`n"
                    . "Content-Length: " StrLen(html_body) "`r`n"
                    . "`r`n"
                httpResponse := httpResponse html_body
                strbuf := Buffer(StrPut(httpResponse, "UTF-8"))
                StrPut(httpResponse, strbuf, "UTF-8")
                sock.Send(strbuf)
                sock.ConnectFinish()

                ; Get backlink
                request := strget(buf, "UTF-8")
                RegExMatch(request, "GET /(.+?) HTTP/1.1", &match)
                if (match == "") {
                    return
                }
                backlink := match[1]
                if (!InStr(backlink, "path=")) {
                    return
                }

                ; Openpotplayer
                cmd := A_ScriptDir "\lib\note2potplayer\note2potplayer.exe " backlink
                Run(cmd,,"Hide",,)
                Send "^w"

                ; silently，RunThe command will block socket Library，autohotkey ，Only this method can be used，letsocket 
                Run(A_ScriptDir "\markdown2potplayer.exe")
                ExitApp
            }
        }
    }
}

RegisterHotKey(){
    HotIf CheckCurrentProgram
    Hotkey app_config.HotkeyBacklink " Up", Potplayer2Obsidian
    Hotkey app_config.HotkeyIamgeBacklink " Up", Potplayer2ObsidianImage
    Hotkey app_config.HotkeyAbFragment " Up", Potplayer2ObsidianFragment
    Hotkey app_config.HotkeyAbCirculation " Up", Potplayer2ObsidianFragment
    Hotkey app_config.HotkeyPreviousFrame " Up", (*) => potplayer_control.PreviousFrame()
    Hotkey app_config.HotkeyNextFrame " Up", (*) => potplayer_control.NextFrame()
    Hotkey app_config.HotkeyForward " Up", (*) => Forward(app_config, potplayer_control)
    Hotkey app_config.HotkeyBackward " Up", (*) => Backward(app_config, potplayer_control)
    Hotkey app_config.HotkeyPlayOrPause " Up", (*) => potplayer_control.PlayOrPause()
    Hotkey app_config.HotkeyStop " Up", (*) => potplayer_control.Stop()
}

RefreshHotkey(old_hotkey,new_hotkey,callback){
    try{
        ; Scenario 1: User deletes hotkey
        if new_hotkey == ""{
            if(old_hotkey != ""){
                Hotkey old_hotkey " Up", "off"
            }
        } else{
            ; Scenario 2: User resets hotkeys
            if(old_hotkey != ""){
                Hotkey old_hotkey " Up", "off"
            }
            HotIf CheckCurrentProgram
            Hotkey new_hotkey " Up", callback
        }
    }
    catch Error as err{
        ; Hotkey setting is invalid
        ; Prevent invalid shortcut keys from generating errors and interrupting the program
        Exit
    }
}

CheckCurrentProgram(*){
    programs := app_config.PotplayerProcessName "`n" app_config.NoteAppName
    Loop Parse programs, "`n"{
        program := A_LoopField
        if program{
            if WinActive("ahk_exe " program){
                return true
            }
        }
    }
    return false
}

; 【main logic】Potplayer Paste the play link into Obsidian
Potplayer2Obsidian(*){
    ReleaseCommonUseKeyboard()

    media_path := GetMediaPath()
    media_time := GetMediaTime()
    
    markdown_link := RenderMarkdownTemplate(app_config.MarkdownTemplate, media_path, media_time)
    PauseMedia()

    if(IsWordProgram()){
        SendText2wordApp(markdown_link)
    }else{
        SendText2NoteApp(markdown_link)
    }
}

RenderMarkdownTemplate(markdown_template, media_path, media_time){
    if (InStr(markdown_template, "{title}") != 0){
        markdown_template := RenderTitle(markdown_template, app_config.MarkdownTitle, media_path, media_time)
    }
    return markdown_template
}

; [Main logic] Paste image
Potplayer2ObsidianImage(*){
    ReleaseCommonUseKeyboard()

    media_path := GetMediaPath()
    media_time := GetMediaTime()
    image := SaveImage()

    PauseMedia()

    RenderImage(app_config.MarkdownImageTemplate, media_path, media_time, image)
}

GetMediaPath(){
    return PressDownHotkey(potplayer_control.GetMediaPathToClipboard)
}
GetMediaTime(){
    time := PressDownHotkey(potplayer_control.GetMediaTimestampToClipboard)

    if (app_config.ReduceTime != "0") {
        time := ReduceTime(time, app_config.ReduceTime)
    }
    return time
}
PressDownHotkey(operate_potplayer){
    ;Make the clipboard empty first so you can use ClipWait . Detect when text is copied to the clipboard.
    A_Clipboard := ""
    ; Calling the function will lose this, pass the object in so that it will not be los tthis => https://wyagd001.github.io/v2/docs/Objects.htm#Custom_Classes_method
    operate_potplayer(potplayer_control)
    ClipWait 1,0
    result := A_Clipboard
    ; MyLog "The value of the clipboard is：" . result

    ; Solution: Once potplayer A prompt appears in the upper left corner and the shortcut keys do not work.
    if (result == "") {
        SafeRecursion()
        ; Infinite retries!
        result := PressDownHotkey(operate_potplayer)
    }
    running_count := 0
    return result
}

PauseMedia(){
    if (app_config.IsStop != "0") {
        potplayer_control.PlayPause()
    }
}

RenderTitle(markdown_template, markdown_title, media_path, media_time){
    markdown_link_data := GenerateMarkdownLinkData(markdown_title, media_path, media_time)
    ; Generate word link
    if(IsWordProgram()){
        word_link := "<a href='http://127.0.0.1:33660/" markdown_link_data.link "'>"  markdown_link_data.title "</a>"
        result := StrReplace(markdown_template, "{title}",word_link)
        result := StrReplace(result, "`n","<br/>")
    }else{
        ; Generate mark down link
        markdown_link := GenerateMarkdownLink(markdown_link_data.title, markdown_link_data.link)
        result := StrReplace(markdown_template, "{title}",markdown_link)
    }
    return result
}

IsWordProgram(){
    target_program := SelectedNoteProgram(app_config.NoteAppName)
    return target_program == "wps.exe" || target_program == "winword.exe"
}
IsNotionProgram(){
    target_program := StrLower(SelectedNoteProgram(app_config.NoteAppName))
    return  target_program == "msedge.exe" 
    || target_program == "chrome.exe"
    || target_program == "360chrome.exe"
    || target_program == "firefox.exe"
}

; // [Title format desired by user](mk-potplayer://open?path=1&aaa=123&time=456)
GenerateMarkdownLinkData(markdown_title, media_path, media_time){
    ; Video of station B
    if (InStr(media_path,"https://www.bilibili.com/video/")){
        ; Normal playback situation
        name := StrReplace(GetPotplayerTitle(app_config.PotplayerProcessName), " - PotPlayer", "")
        
        ; When the video is not playing and has stopped, it is not paused but stopped.
        if name == "PotPlayer"{
            name := GetFileNameInPath(media_path)
        }
    } else{
        ;local video
        name := GetFileNameInPath(media_path)
    }
    markdown_title := StrReplace(markdown_title, "{name}",name)
    markdown_title := StrReplace(markdown_title, "{time}",media_time)

    markdown_link := app_config.UrlProtocol "?path=" ProcessUrl(media_path) "&time=" media_time
    
    result := {}
    result.title := markdown_title
    result.link := markdown_link
    return result
}

GenerateMarkdownLink(markdown_title, markdown_link){
    if(IsNotionProgram()){
        result := "[" markdown_title "](http://127.0.0.1:33660/" markdown_link ")"
    }else{
        result := "[" markdown_title "](" markdown_link ")"
    }
    return result
}

GetFileNameInPath(path){
    name := GetNameForPath(path)
    if (app_config.MarkdownRemoveSuffixOfVideoFile != "0"){
        name := RemoveSuffix(name)
    }
    return name
}

RenderImage(markdown_image_template, media_path, media_time, image){
    identifier := "{image}"
    image_templates := TemplateConvertedToTemplates(markdown_image_template, identifier)
    For index, image_template in image_templates{
        if (image_template == identifier){
            SendImage2NoteApp(image)
        } else {
            rendered_template := RenderMarkdownTemplate(image_template, media_path, media_time)
            if(IsWordProgram() && InStr(image_template,"{title}")){
                SendText2wordApp(rendered_template)
            }else{
                SendText2NoteApp(rendered_template)
            }
        }
    }
}

RemoveSuffix(name){
    index_of := InStr(name, ".",,-1)
    if (index_of = 0){
        return name
    }
    result := SubStr(name, 1,index_of-1)
    return result
}

; Path address processing
ProcessUrl(media_path){
    ; perform url encoding
    if (app_config.MarkdownPathIsEncode != "0"){
        media_path := UrlEncode(media_path)
    }else{
        ; Bug in all urlencode systems: If "\[" exists in the path, in [ob's preview mode] (return links will be automatically urlencoded by ob), "\" will disappear strangely and become, "["; for example: G :\BaiduSyncdisk\123\[456] changes to: G:\BaiduSyncdisk\123[456] under bugs <= "\" is missing
        ; So first replace "\[" with "%5 c[" (\'s urlencode encoding %5 c). become：G:\BaiduSyncdisk\123%5C[456]
        media_path := StrReplace(media_path, "\[", "%5C[")
        media_path := StrReplace(media_path, "\!", "%5C!")
        ; However, there are spaces in the potplayer link path in obidian. In the preview mode of obidian, [cannot be rendered], so the spaces are URL-encoded.
        media_path := StrReplace(media_path, " ", "%20")
    }

    return media_path
}

SendText2NoteApp(text){
    selected_note_program := SelectedNoteProgram(app_config.NoteAppName)
    ActivateProgram(selected_note_program)

    A_Clipboard := ""
    A_Clipboard := text
    ClipWait 2,0
    Send "{LCtrl down}"
    Send "{v}"
    Send "{LCtrl up}"
    ; You need to wait for a while when pasting text. Obsidian has a delay, otherwise the pasted text will appear [disappear].
    Sleep 300
}
SendText2wordApp(text){
    selected_note_program := SelectedNoteProgram(app_config.NoteAppName)
    ActivateProgram(selected_note_program)
    Run(A_ScriptDir "\lib\word\word.exe " text,,"Hide",,)
}

SaveImage(){
    Assert(potplayer_control.GetPlayStatus() == "Stopped" , "The video has not been played yet and screenshots cannot be taken.！")

    A_Clipboard := ""
    potplayer_control.SaveImageToClipboard()
    if !ClipWait(2,1){
        SafeRecursion()
    }
    running_count := 0
    return ClipboardAll()
}
SendImage2NoteApp(image){
    selected_note_program := SelectedNoteProgram(app_config.NoteAppName)
    ActivateProgram(selected_note_program)
    A_Clipboard := ""
    A_Clipboard := ClipboardAll(image)
    ClipWait 2,1
    Send "{LCtrl down}"
    Send "{v}"
    Send "{LCtrl up}"
    ; Give the obsidian picture plug-in time to process the picture
    Sleep 1000
}

; 【A b fragment, loop]
PressHotkeyCount := 0
Potplayer2ObsidianFragment(HotkeyName){
    global
    ReleaseCommonUseKeyboard()

    PressHotkeyCount += 1

    if (PressHotkeyCount == 1){
        ; The first time you press the shortcut key, record the time
        fragment_start_time := GetMediaTime()
        ;Notify user
        ToolTip("The starting time has been recorded！Please press the shortcut key again，Record the end time. Press esc to cancel")
        SetTimer () => ToolTip(), -2000
        
        HotIf CheckCurrentProgram
        Hotkey("Escape Up",cancel,"On")
        cancel(*){
            ; reset counter
            PressHotkeyCount := 0
            Hotkey("Escape Up", "off")
        }
    } else if (PressHotkeyCount == 2){
        Assert(fragment_start_time == "", "The starting time is not set and the link to this segment cannot be generated.！")
        ;reset counter
        PressHotkeyCount := 0
        Hotkey("Escape Up", "off")

        ; Press the shortcut key a second time to record the time
        fragment_end_time := GetMediaTime()

        ; If the end time is less than the start time, swap the two times.
        if (TimeToSeconds(fragment_end_time) < TimeToSeconds(fragment_start_time)){
            temp := fragment_start_time
            fragment_start_time := fragment_end_time
            fragment_end_time := temp
            ;free memory
            temp := ""
        }

        media_path := GetMediaPath()
        
        if fragment_start_time == fragment_end_time{
            fragment_time := fragment_start_time
        }else if HotkeyName == app_config.HotkeyAbFragment " Up"{
            fragment_time := fragment_start_time "-" fragment_end_time
        }else if HotkeyName == app_config.HotkeyAbCirculation " Up"{
            fragment_time := fragment_start_time "∞" fragment_end_time
        }
        
        ; Generate fragment link
        markdown_link := RenderMarkdownTemplate(app_config.MarkdownTemplate, media_path, fragment_time)
        PauseMedia()

        ; Send to note-taking software
        if(IsWordProgram()){
            SendText2wordApp(markdown_link)
        }else{
            SendText2NoteApp(markdown_link)
        }
    }
}