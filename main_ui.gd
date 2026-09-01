extends Control

# ── Company / header data ──────────────────────────────────────────────
const COMPANIES : Array[String] = ["Corporation", "Pharmacy", "Aqueheart", "Enterprise"]
const HEADER_PATHS : Array[String] = [
	"res://assets/headers/jmc-header.png",
	"res://assets/headers/jpi-header.png",
	"res://assets/headers/aque-header.png",
	"res://assets/headers/enter-header.png",
]

# ── Form inputs ────────────────────────────────────────────────────────
@onready var company_dropdown	: OptionButton	= %CompanyDropdown
@onready var input_name			: LineEdit		= %InputName
@onready var input_nick_name	: LineEdit		= %InputNickName
@onready var input_role			: LineEdit		= %InputRole
@onready var input_number		: LineEdit		= %InputNumber
@onready var input_department	: LineEdit		= %InputDepartment
@onready var input_address		: LineEdit		= %InputAddress
@onready var input_sss			: LineEdit		= %InputSSS
@onready var input_tin			: LineEdit		= %InputTIN
@onready var input_philhealth	: LineEdit		= %InputPhilHealth
@onready var input_pagibig		: LineEdit		= %InputPagIbig
@onready var input_ec_person	: LineEdit		= %InputECPerson
@onready var input_ec_number	: LineEdit		= %InputECNumber
@onready var browse_photo_btn	: Button		= %BrowsePhotoBtn
@onready var browse_esig_btn	: Button		= %BrowseSigBtn
@onready var browse_qr_btn	: Button		= %BrowseQrBtn

# ── Preview sides ──────────────────────────────────────────────────────
@onready var front_side			: Control     = %FrontSide
@onready var back_side			: Control     = %BackSide

# ── Front layers ──────────────────────────────────────────────────────
@onready var id_background		: TextureRect = %Background
@onready var id_photo			: TextureRect = %Photo
@onready var es_photo			: TextureRect = %Signature
@onready var qr_photo			: TextureRect = %QR
@onready var id_header			: TextureRect = %Header
@onready var id_overlay			: TextureRect = %Overlay

# ── Back layers ────────────────────────────────────────────────────────
@onready var back_background 	: TextureRect = %BackBackground

# ── Front labels ──────────────────────────────────────────────────────
@onready var lbl_name			: Label = %LblName
@onready var lbl_nick_name		: Label = %LblNickName
@onready var lbl_role			: Label = %LblRole
@onready var lbl_number			: Label = %LblNumber
@onready var lbl_department		: Label = %LblDepartment
@onready var lbl_ec				: Label = %LblEC

# ── Back labels ────────────────────────────────────────────────────────
@onready var lbl_address		: Label = %LblAddress
@onready var lbl_sss			: Label = %LblSSS
@onready var lbl_tin			: Label = %LblTIN
@onready var lbl_philhealth		: Label = %LblPhilHealth
@onready var lbl_pagibig		: Label = %LblPagIbig
@onready var lbl_ec_back		: Label = %LblECBack

# ── Flip button ────────────────────────────────────────────────────────
@onready var flip_btn			: Button = %FlipBtn

# ── ID Card container (used for export capture) ────────────────────────
@onready var id_card			: PanelContainer = %IDCard


# ── State ──────────────────────────────────────────────────────────────
var _photo_texture		: ImageTexture = null
var _showing_back		: bool = false
var _current_company	: int  = 0

# ──────────────────────────────────────────────────────────────────────
func _ready() -> void:
	# Populate company dropdown
	for i in COMPANIES:
		company_dropdown.add_item(i)
	company_dropdown.select(0)
	_apply_header(0)

	# Connect live-update signals
	for field: LineEdit in [
		input_name, input_nick_name, input_role, input_number, input_department,
		input_address, input_sss, input_tin, input_philhealth,
		input_pagibig, input_ec_person, input_ec_number
	]:
		field.text_changed.connect(_on_field_changed)

# ──────────────────────────────────────────────────────────────────────
func _on_company_selected(index: int) -> void:
	_current_company = index
	_apply_header(index)

func _apply_header(index: int) -> void:
	var tex := load(HEADER_PATHS[index]) as Texture2D
	id_header.texture = tex

# ──────────────────────────────────────────────────────────────────────
func _on_field_changed(_new_text: String = "") -> void:
	_update_preview()

func _update_preview() -> void:
	# Front labels
	lbl_name.text       = input_name.text
	lbl_nick_name.text       = input_nick_name.text
	lbl_role.text       = input_role.text
	lbl_number.text     = input_number.text
	lbl_department.text = input_department.text

	# Emergency contact (shown on both sides)
	var ec_person := input_ec_person.text
	var ec_number := input_ec_number.text
	var ec_text   := ""
	if not ec_person.is_empty() and not ec_number.is_empty():
		ec_text = ec_person + "\n" + ec_number
	elif not ec_person.is_empty():
		ec_text = ec_person
	elif not ec_number.is_empty():
		ec_text = ec_number

	lbl_ec.text      = ec_text
	lbl_ec_back.text = ec_text

	# Back labels
	lbl_address.text    = input_address.text
	lbl_sss.text        = input_sss.text
	lbl_tin.text        = input_tin.text
	lbl_philhealth.text = input_philhealth.text
	lbl_pagibig.text    = input_pagibig.text

# ──────────────────────────────────────────────────────────────────────
func _on_flip_toggled(pressed: bool) -> void:
	_showing_back = pressed
	front_side.visible = not pressed
	back_side.visible  = pressed
	flip_btn.text = "Flip ↪" if pressed else "Flip ↩"

# ──────────────────────────────────────────────────────────────────────
func _on_browse_photo_pressed(button_src,variant) -> void:
	
	var dialog := FileDialog.new()
	
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access    = FileDialog.ACCESS_FILESYSTEM
	dialog.filters   = PackedStringArray(["*.png ; PNG Images"])
	dialog.min_size  = Vector2i(700, 500)
	match variant:
		"profile":
			dialog.title		= "Select Profile Photo (PNG)"
			dialog.current_dir	= "D:/RJ files/ID_pictures"
		"signature":
			dialog.title		= "Select Signature (PNG)"
			dialog.current_dir = "D:/RJ files/ID_pictures/2x2 Pictures/Signature"
		"qrcode":
			dialog.title		= "Select QR Code (PNG)"
			dialog.current_dir = "D:/RJ files/ID_pictures/QR"
	# dialog.current_dir = "D:/RJ files/ID_pictures"
	add_child(dialog)
	dialog.popup_centered()
	dialog.file_selected.connect(_on_photo_selected.bind(dialog, variant, button_src))
	dialog.canceled.connect(dialog.queue_free)

func _on_photo_selected(path: String, dialog: FileDialog, variant, button_src) -> void:
	dialog.queue_free()
	var img := Image.new()
	if img.load(path) != OK:
		push_error("Could not load image: " + path)
		return
	
	_photo_texture        = ImageTexture.create_from_image(img)
	match variant:
		"profile":
			id_photo.texture      = _photo_texture
		"signature":
			es_photo.texture      = _photo_texture
		"qrcode":
			qr_photo.texture      = _photo_texture
	button_src.text = path.get_file()

# ──────────────────────────────────────────────────────────────────────
func _on_export_pressed() -> void:
	var base_name := input_name.text.strip_edges()
	if base_name.is_empty():
		base_name = "id"

	# Sanitize: replace spaces with underscores, strip special chars
	base_name = base_name.replace(" ", "_")

	# Ask save folder via dialog
	var dir_dialog := FileDialog.new()
	dir_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dir_dialog.access    = FileDialog.ACCESS_FILESYSTEM
	dir_dialog.filters   = PackedStringArray(["*.png ; PNG Images"])
	dir_dialog.current_dir = "D:/RJ files/RFIDS"
	dir_dialog.title     = "Export ID – choose save location"
	dir_dialog.current_file = base_name + "_front.png"
	dir_dialog.min_size  = Vector2i(700, 500)
	add_child(dir_dialog)
	dir_dialog.popup_centered()
	dir_dialog.file_selected.connect(_do_export.bind(dir_dialog, base_name))
	dir_dialog.canceled.connect(dir_dialog.queue_free)

func _do_export(chosen_path: String, dialog: FileDialog, base_name: String) -> void:
	dialog.queue_free()

	# Derive the save directory from the chosen path
	var save_dir := chosen_path.get_base_dir()

	_export_side(front_side, back_side, save_dir, base_name)

func _export_side( front: Control, back: Control, save_dir: String, base_name: String) -> void:
	var card_size := id_card.size

	# ── Export FRONT ──────────────────────────────────────────────────
	front.visible = true
	back.visible  = false
	await RenderingServer.frame_post_draw

	var front_vp   := front.get_viewport()
	var front_img  := front_vp.get_texture().get_image()
	var card_rect  := _get_card_screen_rect()
	front_img      = front_img.get_region(card_rect)
	front_img.resize(card_size.x, card_size.y, Image.INTERPOLATE_LANCZOS)
	front_img.save_png(save_dir.path_join(base_name + "_front.png"))

	# ── Export BACK ───────────────────────────────────────────────────
	front.visible = false
	back.visible  = true
	await RenderingServer.frame_post_draw

	var back_vp   := back.get_viewport()
	var back_img  := back_vp.get_texture().get_image()
	back_img       = back_img.get_region(card_rect)
	back_img.resize(card_size.x, card_size.y, Image.INTERPOLATE_LANCZOS)
	back_img.save_png(save_dir.path_join(base_name + "_back.png"))

	# ── Restore preview state ─────────────────────────────────────────
	front.visible = not _showing_back
	back.visible  = _showing_back

	print("Exported: ", save_dir.path_join(base_name + "_front.png"))
	print("Exported: ", save_dir.path_join(base_name + "_back.png"))

func _get_card_screen_rect() -> Rect2i:
	var vp_size  := get_viewport().get_visible_rect().size
	var card_pos = id_card.get_global_rect().position
	var card_sz  = id_card.get_global_rect().size
	return Rect2i(
		int(card_pos.x), int(card_pos.y),
		int(card_sz.x),  int(card_sz.y)
	)

# ──────────────────────────────────────────────────────────────────────
func _on_clear_pressed() -> void:
	var default_btn_label = "Browse File 📂"
	for field: LineEdit in [
		input_name, input_nick_name , input_role, input_number, input_department,
		input_address, input_sss, input_tin, input_philhealth,
		input_pagibig, input_ec_person, input_ec_number
	]:
		field.text = ""
	_photo_texture        	= null
	id_photo.texture      	= null
	es_photo.texture      	= null
	qr_photo.texture      	= null
	browse_photo_btn.text 	= default_btn_label
	browse_esig_btn.text 	= default_btn_label
	browse_qr_btn.text 		= default_btn_label
	company_dropdown.select(0)
	_apply_header(0)
	_update_preview()
