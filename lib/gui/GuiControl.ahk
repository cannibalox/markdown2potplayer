#Requires Autohotkey v2
#Include Gui.ahk ; Load Gui
#Include ..\BootUp.ahk
#Include ..\..\markdown2potplayer.ahk

InitGui(app_config, potplayer_control){
  ; Echo: Potplayer path
  Edit_potplayer.Value := app_config.PotplayerPath
  ; Click to select potplayer path
  Button_potplayer.OnEvent("Click",SelectPotplayerProgram)
  SelectPotplayerProgram(*){
    SelectedFile := FileSelect(1, , "Open a file", "Text Documents (*.exe)")
    if SelectedFile{
      edit_potplayer.Value := SelectedFile
    }
  }
  Button_potplayer.OnEvent("LoseFocus",(*) => app_config.PotplayerPath := edit_potplayer.Value)
  
 ; echo: reduced time
  Edit_reduce_time.Value := app_config.ReduceTime
  Edit_reduce_time.OnEvent("LoseFocus",(*) => app_config.ReduceTime := Edit_reduce_time.Value)
  
  ; Echo: Note-taking software name
  Edit_note_app_name.Value := app_config.NoteAppName
  Edit_note_app_name.OnEvent("LoseFocus",(*) => app_config.NoteAppName := Edit_note_app_name.Value)
  
  ; Echo: return link title
  Edit_title.Value := app_config.MarkdownTitle
  Edit_title.OnEvent("LoseFocus",(*) => app_config.MarkdownTitle := Edit_title.Value)
  
  ; Echo: return link template
  Edit_markdown_template.Value := app_config.MarkdownTemplate
  Edit_markdown_template.OnEvent("LoseFocus",(*) => app_config.MarkdownTemplate := Edit_markdown_template.Value)
  
  ; Echo: image link template
  Edit_image_template.Value := app_config.MarkdownImageTemplate
  Edit_image_template.OnEvent("LoseFocus",(*) => app_config.MarkdownImageTemplate := Edit_image_template.Value)
  
  ; Echo: whether to pause or not
  CheckBox_is_stop.Value := app_config.IsStop
  CheckBox_is_stop.OnEvent("Click", (*) => app_config.IsStop := CheckBox_is_stop.Value)
  
  CheckBox_remove_suffix_of_video_file.Value := app_config.MarkdownRemoveSuffixOfVideoFile
  CheckBox_remove_suffix_of_video_file.OnEvent("Click", (*) => app_config.MarkdownRemoveSuffixOfVideoFile := CheckBox_remove_suffix_of_video_file.Value)
  
  ; Echo: whether the path is encoded
  CheckBox_path_is_encode.Value := app_config.MarkdownPathIsEncode
  checkBox_path_is_encode.OnEvent("Click", (*) => app_config.MarkdownPathIsEncode := checkBox_path_is_encode.Value)
  
  ; Echo: Whether to start at boot
  CheckBox_bootup.Value := get_boot_up()
  CheckBox_bootup.OnEvent("Click", (*) => adaptive_bootup())
  
  ; Echo: Url protocol
  Edit_url_protocol.Value := app_config.UrlProtocol
  Edit_url_protocol.OnEvent("LoseFocus",(*) => app_config.UrlProtocol := Edit_url_protocol.Value)
  
  ; Echo: Link back shortcut key
  hk_backlink.Value := app_config.HotkeyBacklink
  hk_backlink.OnEvent("Change", Update_Hk_Backlink)
  Update_Hk_Backlink(GuiCtrlObj, Info){
    RefreshHotkey(app_config.HotkeyBacklink, GuiCtrlObj.Value, Potplayer2Obsidian)
    app_config.HotkeyBacklink := GuiCtrlObj.Value
  }
  
  ; Echo: picture + link shortcut key
  hk_image_backlink.Value := app_config.HotkeyIamgeBacklink
  hk_image_backlink.OnEvent("Change", Update_Hk_Image_Backlink)
  Update_Hk_Image_Backlink(GuiCtrlObj, Info){
    RefreshHotkey(app_config.HotkeyIamgeBacklink, GuiCtrlObj.Value, Potplayer2ObsidianImage)
    app_config.HotkeyIamgeBacklink := GuiCtrlObj.Value
  }
  
  ; Echo: ab fragment shortcut key
  hk_ab_fragment.Value := app_config.HotkeyAbFragment
  hk_ab_fragment.OnEvent("Change", Update_Hk_Ab_Fragment)
  Update_Hk_Ab_Fragment(GuiCtrlObj, Info){
    RefreshHotkey(app_config.HotkeyAbFragment, GuiCtrlObj.Value, Potplayer2ObsidianFragment)
    app_config.HotkeyAbFragment := GuiCtrlObj.Value
  }

 ; Echo: whether to loop ab fragment
  CheckBox_loop_ab_fragment.Value := app_config.LoopAbFragment
  CheckBox_loop_ab_fragment.OnEvent("Click", (*) => app_config.LoopAbFragment := CheckBox_loop_ab_fragment.Value)

  ; Echo: ab loop shortcut key
  hk_ab_circulation.Value := app_config.HotkeyAbCirculation
  hk_ab_circulation.OnEvent("Change", Update_Hk_Ab_Circulation)
  Update_Hk_Ab_Circulation(GuiCtrlObj, Info){
    RefreshHotkey(app_config.HotkeyAbCirculation, GuiCtrlObj.Value, Potplayer2ObsidianFragment)
    app_config.HotkeyAbCirculation := GuiCtrlObj.Value
  }

 ; ===========Map Potplayer shortcut keys ===========
  ; Echo: shortcut key previous frame
  hk_previous_frame.Value := app_config.HotkeyPreviousFrame
  hk_previous_frame.OnEvent("Change", Update_Hk_Previous_Frame)
  Update_Hk_Previous_Frame(GuiCtrlObj, Info){
    RefreshHotkey(app_config.HotkeyPreviousFrame, GuiCtrlObj.Value, (*) => potplayer_control.PreviousFrame())
    app_config.HotkeyPreviousFrame := GuiCtrlObj.Value
  }

 ; Echo: shortcut key next frame
  hk_next_frame.Value := app_config.HotkeyNextFrame
  hk_next_frame.OnEvent("Change", Update_Hk_Next_Frame)
  Update_Hk_Next_Frame(GuiCtrlObj, Info){
    RefreshHotkey(app_config.HotkeyNextFrame, GuiCtrlObj.Value, (*) => potplayer_control.NextFrame())
    app_config.HotkeyNextFrame := GuiCtrlObj.Value
  }

  ; Echo: shortcut key forward
  Edit_forward_seconds.Value := app_config.ForwardSeconds
  Edit_forward_seconds.OnEvent("Change",(*) => app_config.ForwardSeconds := Edit_forward_seconds.Value)
  hk_forward.Value := app_config.HotkeyForward
  hk_forward.OnEvent("Change", Update_Hk_Forward)
  Update_Hk_Forward(GuiCtrlObj, Info){
    RefreshHotkey(app_config.HotkeyForward, GuiCtrlObj.Value, (*) => forward(app_config, potplayer_control))
    app_config.HotkeyForward := GuiCtrlObj.Value
  }

; Echo: shortcut key back
  Edit_backward_seconds.Value := app_config.BackwardSeconds
  Edit_backward_seconds.OnEvent("Change", (*) => app_config.BackwardSeconds := Edit_backward_seconds.Value)
  hk_backward.Value := app_config.HotkeyBackward
  hk_backward.OnEvent("Change", Update_Hk_Backward)
  Update_Hk_Backward(GuiCtrlObj, Info){
    RefreshHotkey(app_config.HotkeyBackward, GuiCtrlObj.Value, (*) => backward(app_config, potplayer_control))
    app_config.HotkeyBackward := GuiCtrlObj.Value
  }
; Echo: shortcut key play/pause
  hk_play_or_pause.Value := app_config.HotkeyPlayOrPause
  hk_play_or_pause.OnEvent("Change", Update_Hk_Play_Or_Pause)
  Update_Hk_Play_Or_Pause(GuiCtrlObj, Info){
    RefreshHotkey(app_config.HotkeyPlayOrPause, GuiCtrlObj.Value, (*) => potplayer_control.PlayOrPause())
    app_config.HotkeyPlayOrPause := GuiCtrlObj.Value
  }

; Echo: shortcut key stop
  hk_stop.Value := app_config.HotkeyStop
  hk_stop.OnEvent("Change", Update_Hk_Stop)
  Update_Hk_Stop(GuiCtrlObj, Info){
    RefreshHotkey(app_config.HotkeyStop, GuiCtrlObj.Value, (*) => potplayer_control.Stop())
    app_config.HotkeyStop := GuiCtrlObj.Value
  }

  ; =======界面设置=========
  myGui.OnEvent('Close', (*) => myGui.Hide())
  myGui.OnEvent('Escape', (*) => myGui.Hide())
  myGui.Title := "markdown2potpalyer - 0.1.9"
  
  ; =======托盘菜单=========
  myMenu := A_TrayMenu
  
  myMenu.Add("&Open", (*) => myGui.Show("w498 h670"))
  myMenu.Default := "&Open"
  myMenu.ClickCount := 2
  
myMenu.Rename("&Open" , "Open")
  myMenu.Rename("E&xit" , "Exit")
  myMenu.Rename("&Pause Script" , "pause script")
  myMenu.Rename("&Suspend Hotkeys" , "Suspend Hotkeys")
}

Forward(app_config, potplayer_control){
  if(app_config.ForwardSeconds != "" || app_config.ForwardSeconds != 0){
    potplayer_control.SetMediaTimeMilliseconds(Integer(potplayer_control.GetMediaTimeMilliseconds() + (app_config.ForwardSeconds * 1000)))
  }else{
    potplayer_control.Forward()
  }
}

Backward(app_config, potplayer_control){
  if(app_config.BackwardSeconds != "" || app_config.BackwardSeconds != 0){
    potplayer_control.SetMediaTimeMilliseconds(Integer(potplayer_control.GetMediaTimeMilliseconds() - (app_config.BackwardSeconds * 1000)))
  }else{
    potplayer_control.Backward()
  }
}