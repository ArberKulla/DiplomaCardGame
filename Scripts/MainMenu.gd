extends Control
class_name MainMenu

@onready var singleplayer_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/Singleplayer
@onready var multiplayer_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/Multiplayer
@onready var settings_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/Settings
@onready var exit_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/Exit
@onready var multiplayer_menu = preload(Global.MUTLIPLAYER_MENU_SCENE_PATH)
@onready var singleplayer_menu = preload(Global.SINGLEPLAYER_MENU_SCENE_PATH)
@onready var card_maker_menu = preload(Global.CARD_MAKER_SCENE_PATH)


func _on_singleplayer_pressed() -> void:
	get_tree().change_scene_to_packed(singleplayer_menu)

func _on_multiplayer_pressed() -> void:
	get_tree().change_scene_to_packed(multiplayer_menu)


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_card_maker_pressed() -> void:
	get_tree().change_scene_to_packed(card_maker_menu)
