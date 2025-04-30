extends Node2D
class_name CardManager

var card_being_dragged
var screen_size
var is_hovering_on_card
var normal_summoned_this_turn = false
var selected_card
var selected_card_in_hand


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.card_manager=self
	screen_size =  get_viewport_rect().size
	Global.input_manager.connect("left_mouse_button_released",on_left_click_released)

func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		var target_pos = mouse_pos - card_being_dragged.get_node("CardImage").texture.get_size()/2
		var window_size = DisplayServer.window_get_size()
		var card_size = card_being_dragged.size  # This works if your card is a Control node

		card_being_dragged.global_position = Vector2(
			clamp(target_pos.x, 0, window_size.x - card_size.x),
			clamp(target_pos.y, 0, window_size.y - card_size.y)
		)
		
		card_being_dragged.z_index = 10

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = Global.COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size()>0:
		return get_card_with_highest_z_index(result)
	return null

func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = Global.COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size()>0:
		return get_card_with_highest_z_index(result)
	return null

func connect_card_signals(card):
	card.connect("hovered",on_hovered_over_card)
	card.connect("hovered_off",on_hovered_off_card)


func connect_panel_signals(panel):
	panel.connect("normal_summon",normal_summon_card)
	panel.connect("play",play_spell_card)
	#panel.connect("tribute_summon",tribute_summon_card)
	#panel.connect("special_summon",special_summon_card)
	#panel.connect("set_play",set_card)


func on_left_click_released():
	if card_being_dragged:
		finish_drag()

func on_hovered_over_card(card):
	if selected_card_in_hand:
		return
	
	if card.card_slot_card_is_in || card in Global.player_field.graveyard.cards_inside:
		return
	
	highlight_card(card)

func on_hovered_off_card(card):
	if selected_card_in_hand:
		return
	
	if card in Global.player_field.graveyard.cards_inside:
		return
	
	if !card.card_slot_card_is_in:
		if !card_being_dragged:
			var new_card_hovered = raycast_check_for_card()
			if new_card_hovered:
				if new_card_hovered!=card:
					highlight_card(new_card_hovered)
				else:
					unhighlight_old_cards(null)
			else:
				unhighlight_old_cards(null)

func highlight_card(card):
	if card.card_slot_card_is_in:
		return;
	
	card.highlight()
	unhighlight_old_cards(card)


func unhighlight_old_cards(card):
	for card_in_hand in Global.player_hand.player_hand:
		if card_in_hand!=card:
			card_in_hand.unhighlight()

func card_clicked(card):
	if card.card_slot_card_is_in:
		if card.attack_count==0 || Global.battle_manager.current_turn_player==Global.ENTITY_ENUM.OPPONENT:
			return
		
		
		if Global.battle_manager.get_attackable_cards(Global.battle_manager.opponent_cards_on_battlefield).size()==0 && card.card_type==Global.CARD_TYPE_ENUM.MONSTER:
			Global.battle_manager.direct_attack(card,Global.ENTITY_ENUM.PLAYER)
		else:
			select_card_for_battle(card)
		
		return
	else:
		select_card_in_hand(card)


func select_card_in_hand(card):
	selected_card_in_hand = card
	highlight_card(card)
	card.selected.visible = true

func unselect_card_in_hand(card):
	selected_card_in_hand = null
	unhighlight_old_cards(null)
	card.selected.visible = false


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
	var old_pos = card.global_position
	card_being_dragged = card
	card.get_parent().remove_child(card)
	get_tree().get_root().add_child(card)
	card.global_position = old_pos
	Global.player_hand.remove_card_from_hand(card)

func finish_drag():
	card_being_dragged.z_index = 1
	var card_slot_found = raycast_check_for_card_slot()
	attempt_to_play_card(card_being_dragged,card_slot_found)

func attempt_to_play_card(card,card_slot):
	unselect_card_in_hand(card)
	
	if card_being_dragged:
		if !card_slot:
			await Global.player_hand.add_card_to_hand(card,Global.player_hand.calculate_drag_card_position(card))
		else:
			await Global.player_hand.add_card_to_hand(card,card.hand_array_position)
		card_being_dragged=null
	
	if !card_slot:
		return
	
	if card_slot and not card_slot.card_in_slot and Global.battle_manager.current_turn_player==Global.ENTITY_ENUM.PLAYER:
		if card_slot.card_slot_type.has(card.card_type):
			if (card.card_type == Global.CARD_TYPE_ENUM.MONSTER and normal_summoned_this_turn):
				return
		else:
			return
	
	show_summon_panel(card,card_slot)

func normal_summon_card(card,card_slot):
	normal_summoned_this_turn = true
	await play_card(card,card_slot)

func play_spell_card(card,card_slot):
	await play_card(card,card_slot)

func show_summon_panel(card,card_slot):
	var panel
	
	if card.card_type == Global.CARD_TYPE_ENUM.MONSTER:
		if !normal_summoned_this_turn:
			panel = preload(Global.SUMMON_PANEL_SCENE_PATH).instantiate()
			card_slot.add_child(panel)
			panel.normal_visible()
	elif card.card_type == Global.CARD_TYPE_ENUM.SPELL:
		panel = preload(Global.SUMMON_PANEL_SCENE_PATH).instantiate()
		card_slot.add_child(panel)
		panel.spell_visible()
	
	if panel:
		panel.card = card
		panel.card_slot = card_slot
		panel.global_position = Vector2(card_slot.global_position.x,card_slot.global_position.y-5)


func play_card(card,card_slot):
	var player_id = multiplayer.get_unique_id
	await play_card_here_and_for_opponent(player_id,card,card.hand_array_position,card_slot.get_path())
	if Global.battle_manager.is_multiplayer_game:
		rpc("play_card_here_and_for_opponent",player_id,card,card.hand_array_position,card_slot.get_path())


@rpc("any_peer")
func play_card_here_and_for_opponent(player_id,card,card_position,card_slot_found):
	var card_slot = get_node(str(card_slot_found))
	if multiplayer.get_unique_id == player_id:
		await play_card_on_field(card,card_slot,Global.ENTITY_ENUM.PLAYER)
	else:
		card = Global.opponent_hand.opponent_hand[card_position]
		card_slot = Global.opponent_field.get(str(card_slot.name))
		await play_card_on_field(card,card_slot,Global.ENTITY_ENUM.OPPONENT)


func play_card_on_field(card,card_slot,player):
	var hand
	var field
	var old_pos = card.global_position
	
	if player==Global.ENTITY_ENUM.PLAYER:
		hand = Global.player_hand
		field = Global.battle_manager.player_cards_on_battlefield
	else:
		hand = Global.opponent_hand
		field = Global.battle_manager.opponent_cards_on_battlefield
		card.flip_animation.play("flip")
		
	card.get_parent().remove_child(card)
	hand.remove_card_from_hand(card)
	get_parent().add_child(card)
	card.global_position = old_pos
	var tween = get_tree().create_tween()
	tween.tween_property(card,"global_position",card_slot.global_position,Global.DEFAULT_CARD_MOVE_SPEED)
	card.scale = Vector2(Global.CARD_IN_SLOT_SCALE,Global.CARD_IN_SLOT_SCALE)
	await tween.finished
	
	card.get_parent().remove_child(card)
	card_slot.add_child(card)
	card.global_position = card_slot.global_position
	card_slot.get_node("Area2D/CollisionShape2D").disabled=true
	card.card_slot_card_is_in = card_slot
	card_slot.card_in_slot = card
	field.append(card)
	card.z_index = 1
	
	await Global.battle_manager.on_card_play(card,player)



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
