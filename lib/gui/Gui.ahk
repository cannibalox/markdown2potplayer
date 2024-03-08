
#Requires Autohotkey v2
;AutoGUI 2.5.8 
;Auto-GUI-v2 credit to Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter credit to github.com/mmikeww/AHK-v2-script-converter

myGui := Gui()
Tab := myGui.Add("Tab3", "x0 y0 w510 h650", ["Backlinks settings", "Potplayer control"])
Tab.UseTab(1)

myGui.Add("Text", "x52 y34 w116 h23", "Potplayer player path")
Edit_potplayer := myGui.Add("Edit", "x160 y32 w215 h25", "C:\Program Files\DAUM\PotPlayer\PotPlayerMini64.exe")
Button_potplayer := myGui.Add("Button", "x384 y32 w103 h23", "Select potplayer")

myGui.Add("Text", "x91 y58 w63 h23", "reduced time")
Edit_reduce_time := myGui.Add("Edit", "x160 y58 w120 h21", "0")

myGui.Add("Text", "x55 y90 w109 h23", "Note-taking program")
Edit_note_app_name := myGui.Add("Edit", "x160 y90 w162 h63 +Multi", "Obsidian.exe`nTypora.exe")
myGui.Add("Text", "x160 y162 w153 h23", "Multiple programs - one per line")

myGui.Add("Text", "x116 y194 w63 h23", "link title")
Edit_title := myGui.Add("Edit", "x160 y194 w148 h21", "{name} | {time}")

myGui.Add("Text", "x68 y226 w84 h23", "Backlink template")
Edit_markdown_template := myGui.Add("Edit", "x160 y226 w149 h60 +Multi", "`nvideo：{title}`n")

myGui.Add("Text", "x53 y298 w117 h23", "Picture link template")
Edit_image_template := myGui.Add("Edit", "x160 y298 w151 h79 +Multi", "`nPicture:{image}`nVideo:{title}`n")

CheckBox_is_stop := myGui.Add("CheckBox", "x160 y378 w69 h23", "pause")
CheckBox_remove_suffix_of_video_file := myGui.Add("CheckBox", "x160 y398 w150 h23", "Remove extension of local video")
CheckBox_path_is_encode := myGui.Add("CheckBox", "x160 y426 w120 h23", "url encoding")
CheckBox_bootup := myGui.Add("CheckBox", "x160 y450 w120 h23", "boot")

myGui.Add("Text", "x72 y479 w90 h36", "Modify deeplink`n!need to restart !")
Edit_url_protocol := myGui.Add("Edit", "x160 y480 w146 h21", "jv://open")

myGui.Add("Text", "x73 y516 w83 h23", "add link shortcut")
hk_backlink := myGui.Add("Hotkey", "x160 y514 w155 h21", "!g")

myGui.Add("Text", "x25 y548 w190 h23", "add Picture + Link shortcut")
hk_image_backlink := myGui.Add("Hotkey", "x160 y546 w156 h21", "^!g")

myGui.Add("Text", "x50 y576 w110 h16", "A B segment shortcut")
hk_ab_fragment := myGui.Add("Hotkey", "x160 y572 w156 h21","F1")
CheckBox_loop_ab_fragment := myGui.Add("CheckBox", "x160 y594 w120 h23", "Loop clip")

myGui.Add("Text", "x64 y620 w99 h16", "A-B Cycle shortcut")
hk_ab_circulation := myGui.Add("Hotkey", "x160 y619 w156 h21")

Tab.UseTab(2)
myGui.Add("Text", "x72 y34 w90 h23", "Previous frame")
hk_previous_frame := myGui.Add("Hotkey", "x152 y34 w120 h21")
myGui.Add("Text", "x92 y58 w80 h23", "Next frame")
hk_next_frame := myGui.Add("Hotkey", "x152 y58 w120 h21")
myGui.Add("Text", "x104 y90 w50 h23", "Forward")
hk_forward := myGui.Add("Hotkey", "x152 y90 w120 h21")
Edit_forward_seconds := myGui.Add("Edit", "x280 y90 w37 h21")
myGui.Add("Text", "x322 y90 w17 h19 +0x200", "sec")
myGui.Add("Text", "x120 y114 w25 h23", "Back")
hk_backward := myGui.Add("Hotkey", "x152 y114 w120 h21")
Edit_backward_seconds := myGui.Add("Edit", "x281 y114 w36 h21")
myGui.Add("Text", "x322 y112 w16 h23 +0x200", "sec")
myGui.Add("Text", "x89 y143 w56 h14", "Play/Pause")
hk_play_or_pause := myGui.Add("Hotkey", "x152 y139 w120 h21")
myGui.Add("Text", "x121 y163 w24 h21", "Stop")
hk_stop := myGui.Add("Hotkey", "x152 y163 w120 h21")

Tab.UseTab()
myGui.Add("Link", "x436 y650 w74 h17", "<a href=`"https://github.com/cannibalox/markdown2potplayer/releases/latest`">homepage</a>")
