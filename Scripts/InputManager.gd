extends Node2D
class_name InputManager

signal left_mouse_button_clicked
signal left_mouse_button_released
var inputs_allowed = true


func _ready() -> void:
	Global.input_manager = self

func _input(event):
	if event is InputEventMouseButton:
		if Input.is_action_pressed("left_click"):
			left_mouse_button_clicked.emit()
			raycast_at_cursor()
		elif Input.is_action_pressed("right_click") or Input.is_action_just_released("left_click"):
			left_mouse_button_released.emit()

func raycast_at_cursor():
	if !inputs_allowed:
		return
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size()>0:
		var result_collision_mask = result[0].collider.collision_mask
		var result_card = result[0].collider.get_parent()
		#Card Clicked
		if result_collision_mask == Global.COLLISION_MASK_CARD:
			if result_card:
				Global.card_manager.card_clicked(result_card)
		elif result_collision_mask == Global.COLLISION_MASK_OPPONENT_CARD:
			if result_card:
				Global.battle_manager.enemy_card_select(result_card)
