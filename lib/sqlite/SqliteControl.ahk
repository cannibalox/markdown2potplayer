#Requires AutoHotkey v2.0.0
#Include "Class_SQLiteDB.ahk"

; Database file path
db_file_path := "config.db"
table_name := "config"

InitSqlite() {
  if !TableExist(table_name) {
    DB := OpenLocalDB()
    ; Create config table
    SQL_CreateTable := 
    "CREATE TABLE IF NOT EXISTS " table_name " ("
    . " key TEXT PRIMARY KEY,"
    . " value TEXT"
    . " );"
  
    if !DB.Exec(SQL_CreateTable) {
      MsgBox("Unable to create table " table_name "`nError message: " DB.ErrorMsg)
      DB.CloseDB()
      ExitApp
    }
    DB.CloseDB()
  }

  ; Initialize insert data
  config_data := {
    path: "C:\Program Files\DAUM\PotPlayer\PotPlayerMini64.exe",
    is_stop: "0",
    reduce_time: "0",
    app_name: "Obsidian.exe",
    url_protocol: "jv://open",
    path_is_encode: "0",
    remove_suffix_of_video_file: "1",
    title: "{name} | {time}",
    template: 
      "`n"
      . "video:{title}"
      . "`n",
    image_template:
      "`n"
      . "Picture:{image}"
      . "`n"
      . "Video:{title}"
      . "`n",
    ; Link back shortcut keys related
    hotkey_backlink: "!g",
    hotkey_iamge_backlink: "^!g",
    hotkey_ab_fragment: "F1",
    hotkey_ab_circulation: "F2",
    loop_ab_fragment: "0",
    ; Mapping potplayer shortcut keys related
    hotkey_previous_frame: "",
    hotkey_next_frame: "",
    hotkey_forward: "",
    forward_seconds: "",
    hotkey_backward: "",
    backward_seconds: "",
    hotkey_play_or_pause: "",
    hotkey_stop: ""
  }

  DB := OpenLocalDB()
  ; Insert data
  for key, value in config_data.OwnProps() {
    if CheckKeyExist(key) {
      continue
    }

    UpdateOrIntert(key, value)
  }
}

OpenLocalDB(){
  ; Create SQLiteDB instance
  DB := SQLiteDB()
  
  ; Open or create a database
  if !DB.OpenDB(db_file_path) {
    MsgBox("Unable to open or create database: " db_file_path "`nError message: " DB.ErrorMsg)
    ExitApp
  }
  return DB
}

TableExist(table_name){
  DB := OpenLocalDB()

  ; Check if config table exists
  SQL_CheckTable := "SELECT name FROM sqlite_master WHERE type='table' AND name='" table_name "';"
  Result := ""
  if !DB.GetTable(SQL_CheckTable, &Result) {
    MsgBox("Unable to check table " table_name " Is there any`nerror message?: " . DB.ErrorMsg)
    DB.CloseDB()
    ExitApp
  }

  DB.CloseDB()
  ; Determine whether the table exists
  if Result.RowCount > 0 {
    ; MsgBox("Table " table_name " exists。")
    return true
  } else {
    ; MsgBox("Table " table_name " does not exist。")
    return false
  }
}

CheckKeyExist(key){
  DB := OpenLocalDB()

  SQL_Check_Key := "SELECT COUNT(*) FROM " table_name " WHERE key = '" key "'"
  Result := ""
  If !DB.GetTable(SQL_Check_Key, &Result){
    MsgBox "Failed to open data table " table_name "！"
    ExitApp
  }

  DB.CloseDB()

  ; if key does not exist
  If Result.RowCount = 0 || Result.Rows[1][1] = 0{
    return false
  } else {
    return true
  }
}

GetKey(key){
  DB := OpenLocalDB()

  ; Read the value with key 'app_name'
  SQL_SelectValue := "SELECT value FROM " table_name " WHERE key = '" key "';"
  Result := ""
  if !DB.GetTable(SQL_SelectValue, &Result) {
      MsgBox("Unable to read configuration item '" key "'`nError message: " . DB.ErrorMsg)
      DB.CloseDB()
      ExitApp
  }

  ; Show results
  if Result.RowCount > 0 {
      ; MsgBox("Configuration items '" key "' The value is: " . Result.Rows[1][1]) ; Get the value of the first row and column
      return Result.Rows[1][1]
  } else {
      ; MsgBox("Configuration items '" key "' does not exist。")
      return false
  }

  DB.CloseDB()
}

UpdateOrIntert(key, value){
  DB := OpenLocalDB()

  ; Insert or update configuration items
  SQL_InsertOrUpdate := "INSERT OR REPLACE INTO " table_name " (key, value) VALUES ('" key "', '" value "');"
  if !DB.Exec(SQL_InsertOrUpdate) {
      MsgBox("Unable to insert or update configuration item '" table_name "'`nerror message: " . DB.ErrorMsg)
      DB.CloseDB()
      ExitApp
  }
  DB.CloseDB()
}