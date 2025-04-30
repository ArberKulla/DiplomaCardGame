extends Node2D
class_name InputManager

signal left_mouse_button_clicked
signal left_mouse_button_released
var inputs_allowed = true
var last_clicked_card
var clicking_card
var minimum_drag_time_elapsed = false



func _ready() -> void:
	Global.input_manager = self


func _input(event: InputEvent):
	if Input.is_action_just_pressed("left_click"):
		left_mouse_button_clicked.emit()
		raycast_at_cursor()
	elif Input.is_action_pressed("right_click"):
		if Global.card_manager.selected_card_in_hand:
			Global.card_manager.unselect_card_in_hand(Global.card_manager.selected_card_in_hand)
			last_clicked_card=null
		if Global.card_manager.selected_card:
			Global.card_manager.unselect_card(Global.card_manager.selected_card)
		clicking_card = false
		left_mouse_button_released.emit()
	elif Input.is_action_just_released("left_click"):
		left_mouse_button_released.emit()
		clicking_card = false



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
				if last_clicked_card && last_clicked_card!=result_card:
					Global.card_manager.unselect_card_in_hand(last_clicked_card)
				
				Global.card_manager.card_clicked(result_card)
				
				if result_card.card_slot_card_is_in:
					last_clicked_card=null
					return
				
				last_clicked_card = result_card
				clicking_card = true
				minimum_drag_time_elapsed = false
				var threshold_timer := get_tree().create_timer(Global.DRAG_MINIMUM_THRESHOLD, false)
				threshold_timer.timeout.connect(func(): 
					if clicking_card && last_clicked_card==result_card && last_clicked_card:
						Global.card_manager.start_drag(result_card)
						)
		elif result_collision_mask == Global.COLLISION_MASK_CARD_SLOT:
			if result_card && Global.card_manager.selected_card_in_hand:
				Global.card_manager.attempt_to_play_card(Global.card_manager.selected_card_in_hand,result_card)
		elif result_collision_mask == Global.COLLISION_MASK_OPPONENT_CARD:
			if result_card:
				Global.battle_manager.enemy_card_select(result_card)
		else:
			if last_clicked_card:
				Global.card_manager.unselect_card_in_hand(last_clicked_card)
				last_clicked_card=null
