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
@onready var profile_photo		: TextureRect = %ProfilePic
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

# ── Back labels ────────────────────────────────────────────────────────
@onready var lbl_address		: Label = %LblAddress
@onready var lbl_sss			: Label = %LblSSS
@onready var lbl_tin			: Label = %LblTIN
@onready var lbl_philhealth		: Label = %LblPhilHealth
@onready var lbl_pagibig		: Label = %LblPagIbig
@onready var lbl_ec_name		: Label = %LblECname
@onready var lbl_ec_num			: Label = %LblECnum

# ── Flip button ────────────────────────────────────────────────────────
@onready var flip_btn			: Button = %FlipBtn

# ── ID Card container & viewport (used for export capture) ─────────────
# CHANGED: Added references to IDContainer (SubViewportContainer) and IDviewport (SubViewport)
# WHY: We need direct access to temporarily adjust the viewport resolution to full 1284x1980 during export
@onready var profile_card		: SubViewport			= %Profile
@onready var profile_container	: SubViewportContainer	= %ProfileContainer
@onready var id_card			: PanelContainer		= %IDCard
@onready var id_container		: SubViewportContainer	= %IDContainer
@onready var id_viewport		: SubViewport			= %IDviewport

# CHANGED: Added native ID card resolution constant
# WHY: Matches the original asset resolution (1284x1980) so exported PNGs are full high-res print quality
const NATIVE_ID_SIZE	 	: Vector2i = Vector2i(1284, 1980)
const NATIVE_PROFILE_SIZE	: Vector2i = Vector2i(1200, 1200)


# ── State ──────────────────────────────────────────────────────────────
var _photo_texture		: ImageTexture = null
var _showing_back		: bool = false
var _current_company	: int  = 0

# ──────────────────────────────────────────────────────────────────────
func _ready() -> void:
	front_side.visible = not _showing_back
	back_side.visible = _showing_back
	for main_panel in [ id_card, profile_container ]:
		main_panel.visible = true
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
	input_name.item_rect_changed.connect(font_len)
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


const max_f_size: int = 75
const min_f_size: int = 35

func font_len() -> void:
	var cur_font_size = max_f_size
	lbl_name.add_theme_font_size_override("font_size",cur_font_size)
	while lbl_name.get_theme_font("font").get_string_size(lbl_name.text, HORIZONTAL_ALIGNMENT_CENTER,-1,cur_font_size).x + 50 > lbl_name.custom_maximum_size.x - 100:
		cur_font_size -= 1
		if cur_font_size <= min_f_size:
			cur_font_size = min_f_size
			break
		lbl_name.add_theme_font_size_override("font_size",cur_font_size)


func _update_preview() -> void:
	font_len()
	# Front labels
	lbl_name.text       = input_name.text
	lbl_nick_name.text  = input_nick_name.text
	lbl_role.text       = input_role.text
	lbl_number.text     = input_number.text
	lbl_department.text = input_department.text
	
	if input_nick_name.text.length() >= 1:
		lbl_nick_name.text[0] = lbl_nick_name.text[0].to_upper()
	
	# Emergency contact (shown on both sides)
	var ec_person := input_ec_person.text
	var ec_number := input_ec_number.text

	lbl_ec_name.text    = ec_person
	lbl_ec_num.text 	= ec_number

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
			id_photo.texture		= _photo_texture
			profile_photo.texture	= _photo_texture
		"signature":
			es_photo.texture		= _photo_texture
		"qrcode":
			qr_photo.texture		= _photo_texture
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
	dir_dialog.current_file = base_name + ".png"
	dir_dialog.min_size  = Vector2i(700, 500)
	add_child(dir_dialog)
	dir_dialog.popup_centered()
	dir_dialog.file_selected.connect(_do_export.bind(dir_dialog))
	dir_dialog.canceled.connect(dir_dialog.queue_free)

func _do_export(chosen_path: String, dialog: FileDialog) -> void:
	dialog.queue_free()
	var f_letter := input_name.text.strip_edges().split(" ",false)[0][0]
	var lname := input_name.text.strip_edges().split(" ", false)[-1].to_upper()
	var short := f_letter + "_" + lname
	# Derive the save directory from the chosen path
	var save_dir := chosen_path.get_base_dir()
	
	# Personalizing folders for each export 
	var psnl_dir := save_dir + "/" + short.to_upper()
	var save_folder = DirAccess.open(save_dir)
	if not save_folder.dir_exists(psnl_dir):
		save_folder.make_dir(psnl_dir)
	

	_export_side(front_side, back_side, psnl_dir)

func _export_side(front: Control, back: Control, save_dir: String) -> void:
	var lname := input_name.text.strip_edges().split(" ", false)[-1].to_upper()
	
	# CHANGED: 1. Save original container stretch mode and viewport size
	# WHY: During regular UI preview, stretch=true keeps the viewport scaled to the UI window (~400x674)
	var orig_stretch : bool     = id_container.stretch
	var orig_vp_size : Vector2i = id_viewport.size
	var orig_profile_stretch : bool = profile_container.stretch
	var orig_profile_size : Vector2i = profile_card.size

	# CHANGED: 2. Temporarily switch SubViewport to full native resolution (1284x1980)
	# WHY: Disabling container stretch allows the SubViewport to render at its true 1284x1980 asset resolution
	id_container.stretch = false
	id_viewport.size = NATIVE_ID_SIZE
	profile_container.stretch = false
	profile_card.size = NATIVE_PROFILE_SIZE

	# ── Export FRONT ──────────────────────────────────────────────────
	front.visible = true
	back.visible  = false
	profile_container.visible = false
	await RenderingServer.frame_post_draw

	# CHANGED: 3. Capture directly from id_viewport texture without get_region()
	# WHY: id_viewport is now rendering at exactly 1284x1980, so get_image() is already the full card image
	var front_img := id_viewport.get_texture().get_image()
	front_img.save_png(save_dir.path_join(lname + "_front.png")) 

	# ── Export BACK ───────────────────────────────────────────────────
	front.visible = false
	back.visible  = true
	profile_container.visible = false
	await RenderingServer.frame_post_draw

	# CHANGED: 4. Capture back image directly at full 1284x1980 resolution
	var back_img := id_viewport.get_texture().get_image()
	back_img.save_png(save_dir.path_join(lname + "_back.png"))


	# ── Export PROFILE ───────────────────────────────────────────────────


	profile_container.visible = true
	await RenderingServer.frame_post_draw
	var profile_img := profile_card.get_texture().get_image()
	profile_img.save_png(save_dir.path_join(lname + "_profile.jpg"))


	# ── Restore preview state ─────────────────────────────────────────
	# CHANGED: 5. Restore original UI viewport size and stretch mode
	# WHY: Returns the on-screen preview back to normal responsive UI scaling
	profile_card.size 			= orig_profile_size
	id_viewport.size 			= orig_vp_size
	front.visible 				= not _showing_back
	back.visible  				= _showing_back
	profile_container.stretch 	= orig_profile_stretch
	id_container.stretch 		= orig_stretch

	print("Exported: ", save_dir.path_join(lname + "_front.png"))
	print("Exported: ", save_dir.path_join(lname + "_back.png"))

# ──────────────────────────────────────────────────────────────────────
func _on_clear_pressed() -> void:
	for field: LineEdit in [
		input_name, input_nick_name , input_role, input_number, input_department,
		input_address, input_sss, input_tin, input_philhealth,
		input_pagibig, input_ec_person, input_ec_number
	]:
		field.text = ""
	for picture: TextureRect in [ id_photo, profile_photo, es_photo, qr_photo ]:
		picture.texture = null
	_photo_texture        	= null
	
	for btn: Button in [ browse_photo_btn, browse_esig_btn, browse_qr_btn ]:
		btn.text = "Browse File..."

	company_dropdown.select(0)
	_apply_header(0)
	_update_preview()
