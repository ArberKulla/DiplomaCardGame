extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2

var card_being_dragged
var screen_size
var is_hovering_on_card
var player_hand_reference
var default_scale
var normal_summoned_this_turn = false
var selected_card

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_scale = $"..".DEFAULT_CARD_SCALE
	screen_size =  get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_button_released",on_left_click_released)

func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x,0,screen_size.x),clamp(mouse_pos.y,0,screen_size.y))

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size()>0:
		return get_card_with_highest_z_index(result)
	return null
	
func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size()>0:
		return get_card_with_highest_z_index(result)
	return null

func connect_card_signals(card):
	card.connect("hovered",on_hovered_over_card)
	card.connect("hovered_off",on_hovered_off_card)
	
func on_left_click_released():
	if card_being_dragged:
		finish_drag()

func on_hovered_over_card(card):
	if card.card_slot_card_is_in:
		return
	if !is_hovering_on_card:
		is_hovering_on_card=true
		highlight_card(card,true)

func on_hovered_off_card(card):
	if card in $"../PlayerGraveyard".cards_inside:
		return
	
	if !card.card_slot_card_is_in:
		if !card_being_dragged:
			highlight_card(card,false)
			var new_card_hovered = raycast_check_for_card()
			if new_card_hovered:
				highlight_card(new_card_hovered,true)
			else:
				is_hovering_on_card = false

func highlight_card(card,hovered):
	if hovered:
		card.scale = Vector2(default_scale*1.1,default_scale*1.1)
		card.z_index = 2
	else:
		card.scale = Vector2(default_scale,default_scale)
		card.z_index = 1

func card_clicked(card):
	if card.card_slot_card_is_in:
		if card.attack_count==0 || $"../BattleManager".current_turn_player=="Opponent":
			return
		
		if $"../BattleManager".opponent_card_on_battlefield.size()==0:
			$"../BattleManager".direct_attack(card,"Player")
		else:
			select_card_for_battle(card)
		
		return
	else:
		start_drag(card)

func select_card_for_battle(card):
	if selected_card:
		if selected_card==card:
			unselect_card(selected_card)
		else:
			unselect_card(selected_card)
			select_card(card)
	else:
		select_card(card)

func unselect_card(card):
	if card:
		card.position.y+=20
		selected_card=null

func select_card(card):
	if card:
		card.position.y-=20
		selected_card=card

func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(default_scale,default_scale)

func finish_drag():
	card_being_dragged.scale = Vector2(default_scale*1.1,default_scale*1.1)
	var card_slot_found = raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_in_slot:
		if card_being_dragged.card_type == card_slot_found.card_slot_type:
			if card_being_dragged.card_type == "Monster" and normal_summoned_this_turn or $"../BattleManager".current_turn_player!="Player":
				player_hand_reference.add_card_to_hand(card_being_dragged,$"..".DEFAULT_CARD_MOVE_SPEED)
				card_being_dragged = null
				return
			card_being_dragged.scale = card_slot_found.scale
			card_being_dragged.z_index = -1
			card_being_dragged.card_slot_card_is_in = card_slot_found
			player_hand_reference.remove_card_from_hand(card_being_dragged)
			card_being_dragged.position = card_slot_found.position
			card_slot_found.card_in_slot=true
			card_slot_found.get_node("Area2D/CollisionShape2D").disabled=true
			normal_summoned_this_turn=true
			$"../BattleManager".player_cards_on_battlefield.append(card_being_dragged)

			card_being_dragged = null
			is_hovering_on_card=false
			return
	player_hand_reference.add_card_to_hand(card_being_dragged,$"..".DEFAULT_CARD_MOVE_SPEED)
	card_being_dragged = null


func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1,cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	
	return highest_z_card

func reset_normal_summon():
	normal_summoned_this_turn=false
