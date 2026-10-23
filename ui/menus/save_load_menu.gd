class_name SaveLoadMenu
extends Control

@onready var save_load_label: Label = %SaveLoadLabel


@onready var save_slots = {
	"save_1" = {"title": "Save 1", "slot": %SaveSlot1},
	"save_2" = {"title": "Save 2", "slot": %SaveSlot2},
	"save_3" = {"title": "Save 3", "slot": %SaveSlot3},
	"auto_save" = {"title": "Auto Save", "slot": %AutosaveSlot},
	"quick_save" = {"title": "Quick Save", "slot": %QuicksaveSlot},
}

@onready var cancel_button: Button = %CancelButton

signal save_load_canceled()


func _ready() -> void:
	setup_slots()
	save_slots.save_1.slot.grab_focus()
	cancel_button.pressed.connect(save_load_canceled.emit)


func setup_slots(is_load_screen = false) -> void:
	var save_infos: Dictionary = SaveManager.get_save_infos()
	print("Save infos: ", JSON.stringify(save_infos, "  "))

	save_load_label.text = "Load Game" if is_load_screen else "Save Game"
	for filename in save_slots:
		var is_save_exists = SaveManager.is_save_exists(filename)
		var title: String = save_slots[filename].title
		var slot: SaveLoadSlot = save_slots[filename].slot
		
		if is_save_exists and save_infos.has(filename):
			var image := SaveManager.load_image(filename)
			var image_texture := ImageTexture.create_from_image(image)
			var date = save_infos[filename].date
			var time = save_infos[filename].time
			var date_str = "%s/%s/%s, %2d:%2d" % [date["day"], date["month"], date["year"], time["hour"], time["minute"]]
			slot.setup(title, image_texture, date_str)
		else:
			slot.setup(title)
			slot.set_enabled(not is_load_screen) # If save doesn't exist and it's load screen
