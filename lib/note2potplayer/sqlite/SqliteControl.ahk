#Requires AutoHotkey v2.0.0
#Include "Class_SQLiteDB.ahk"

; Database file path
db_file_path := SubStr(A_ScriptDir, 1,InStr(A_ScriptDir,"\lib",,1) -1 ) "\config.db"
table_name := "config"

OpenLocalDB(){
  ;Create SQLiteDB instance
  DB := SQLiteDB()
  
  ; Open or create database
  if !DB.OpenDB(db_file_path) {
    MsgBox("Unable to open or create database: " db_file_path "`nError message: " DB.ErrorMsg)
    ExitApp
  }
  return DB
}

GetKeyName(key){
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
      ; MsgBox("The value of configuration item '" key "' is: " . Result.Rows[1][1]) ; Get the value of the first row and first column
      return Result.Rows[1][1]
  } else {
      ; MsgBox("Configuration item '" key "' does not exist.")
      return false
  }

  DB.CloseDB()
}