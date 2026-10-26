class_name SaveLoadSlot
extends Control

@onready var save_load_name: Label = %SaveLoadName
@onready var game_ss: TextureRect = %GameSS
@onready var save_load_date: Label = %SaveLoadDate
@onready var slot_button: Button = %SlotButton
@onready var hover_style: StyleBox = slot_button.get_theme_stylebox("hover")

signal save_load_slot_clicked(slot: SaveLoadSlot)

var is_enabled := true
var filename: String


func _ready() -> void:
	slot_button.pressed.connect(_on_slot_button_pressed)
	focus_entered.connect(slot_button.grab_focus)
	_forward_focus_neighbors()


func setup(slot_name: String, filename_inp: String, ss_texture: Texture2D = null, slot_date: String = "") -> void:
	save_load_name.text = slot_name
	filename = filename_inp
	if ss_texture:
		game_ss.texture = ss_texture
	save_load_date.text = slot_date


func set_enabled(is_enabled_inp := true) -> void:
	is_enabled = is_enabled_inp
	if is_enabled:
		slot_button.remove_theme_stylebox_override("pressed")
	else:
		slot_button.add_theme_stylebox_override("pressed", hover_style)


# Neighbors are set on this slot in the parent scene, but the inner button is
# what holds focus, so re-resolve each path relative to the button.
func _forward_focus_neighbors() -> void:
	for property in [&"focus_neighbor_left", &"focus_neighbor_top", &"focus_neighbor_right",
			&"focus_neighbor_bottom", &"focus_next", &"focus_previous"]:
		var path: NodePath = get(property)
		if not path.is_empty():
			slot_button.set(property, slot_button.get_path_to(get_node(path)))


func _on_slot_button_pressed() -> void:
	if is_enabled:
		save_load_slot_clicked.emit(self)