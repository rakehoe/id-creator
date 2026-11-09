extends Node

var db: SQLite
const DB_NAME := "employeeSheet"
const SAVE_FOLDER := "user://db"

func _ensure_folder():
	if not DirAccess.dir_exists_absolute(SAVE_FOLDER):
		var err = DirAccess.make_dir_recursive_absolute(SAVE_FOLDER)
		if err != OK:
			push_error("Could not create folder, error code: %d" % err)
			
func _ready():
	_ensure_folder()
	db = SQLite.new()
	db.path = ProjectSettings.globalize_path("%s /Employee_Data.db" % SAVE_FOLDER)
	db.open_db()
	db.query("""
        CREATE TABLE IF NOT EXISTS %s (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            nickname TEXT,
            role TEXT,
            idnumber INTEGER,
            department TEXT,
            address TEXT,
            sss TEXT,
            tin TEXT,
            philhealth TEXT,
            pagibig TEXT,
            emergency_contact_person TEXT,
            emergency_contact_number INTEGER
        );
	""" % DB_NAME )

func add_data(
	e_name: String, empid: int, nickname: String, role: String, department: String, address: String, sss: String, tin: String, philhealth: String, pagibig: String, emergency_contact_person: String, emergency_contact_number: int ):
	db.insert_row(DB_NAME,{
		"name": e_name,
		"nickname": nickname,
		"role": role,
		"idnumber": empid,
		"department": department,
		"address": address,
		"sss": sss,
		"tin": tin,
		"philhealth": philhealth,
		"pagibig": pagibig,
		"emergency_contact_person": emergency_contact_person,
		"emergency_contact_number": emergency_contact_number,
	})

func load_all() -> Array:
	db.query("SELECT * FROM %s;"% DB_NAME)
	return db.query_result

func update_data(empid: int, toupdates: String):
	db.update_rows(DB_NAME, "id = %d" % empid, {"toupdatesss": toupdates})

func delete_data(empid: int):
	db.delete_rows(DB_NAME,"id = %d" % empid)
