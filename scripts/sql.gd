extends Node

var db: SQLite

func _ready():
    db = SQLite.new()

    db.path = ProjectSettings.globalize_path("user://Employee_Data.db")
    db.open_db()
    db.query("""
        CREATE TABLE IF NOT EXISTS employeeSheet (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
        )
    """)
