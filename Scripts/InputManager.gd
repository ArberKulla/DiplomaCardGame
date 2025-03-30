extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_DECK = 4
const COLLISION_MASK_OPPONENT_CARD = 8
var card_manager_reference
var deck_reference


func _ready() -> void:
	card_manager_reference=$"../CardManager"
	deck_reference= $"../Deck"

func _input(event):
	if event is InputEventMouseButton:
		if Input.is_action_pressed("left_click"):
			left_mouse_button_clicked.emit()
			raycast_at_cursor()
		elif Input.is_action_pressed("right_click") or Input.is_action_just_released("left_click"):
			left_mouse_button_released.emit()

func raycast_at_cursor():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size()>0:
		var result_collision_mask = result[0].collider.collision_mask
		var result_card = result[0].collider.get_parent()
		#Card Clicked
		if result_collision_mask == COLLISION_MASK_CARD:
			if result_card:
				card_manager_reference.card_clicked(result_card)
		elif result_collision_mask == COLLISION_MASK_OPPONENT_CARD:
			if result_card:
				$"../BattleManager".enemy_card_select(result_card)
