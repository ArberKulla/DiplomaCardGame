extends Control

@onready var singleplayer_level_path = preload(Global.SINGLEPLAYER_LEVEL_SCENE_PATH)

func _on_level_1_pressed() -> void:
	load_level(1)


func _on_level_2_pressed() -> void:
	pass # Replace with function body.

func load_level(level_id):
	Global.level_id = level_id
	get_tree().change_scene_to_packed(singleplayer_level_path)
