extends Node
class_name BattleManager

var opponent_cards_on_battlefield = []
var player_cards_on_battlefield = []
var player_health = 0
var opponent_health = 0
var current_turn_player
var turn_counter = 1
var is_multiplayer_game = false

signal opponent_animation_finished

@rpc("any_peer")
func notify_animation_done(player_id):
	if player_id != multiplayer.get_unique_id:
		opponent_animation_finished.emit() 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.battle_manager = self

func end_player_turn():
	var player_id = multiplayer.get_unique_id
	end_player_turn_here_and_client_opponent(player_id)
	if is_multiplayer_game:
		rpc("end_player_turn_here_and_client_opponent",player_id)

@rpc("any_peer")
func end_player_turn_here_and_client_opponent(player_id):
	if player_id==multiplayer.get_unique_id:
		Global.card_manager.unselect_card(Global.card_manager.selected_card)
		current_turn_player=Global.ENTITY_ENUM.OPPONENT
		Global.player_field.end_turn_button.disabled=true
		Global.player_field.end_turn_button.visible=false
		Global.card_manager.reset_normal_summon()
		
		for card in player_cards_on_battlefield:
			card.attack_count = card.max_attack_count
	else:
		start_player_turn()

func start_player_turn():
	current_turn_player=Global.ENTITY_ENUM.PLAYER
	Global.input_manager.inputs_allowed = true
	Global.player_field.end_turn_button.disabled=false
	Global.player_field.end_turn_button.visible=true
	Global.card_manager.reset_normal_summon()
	Global.player_deck.draw_mutliplayer(1)


func opponent_turn() -> void:
	Global.input_manager.inputs_allowed = false
	
	if turn_counter>1:
		Global.opponent_deck.draw_card(1)
		await wait(1)
	
	if Global.opponent_field.get_empty_monster_card_slots().size()!=0:
		try_play_best_monster()
		await wait(1)
	
	if get_attackable_cards(opponent_cards_on_battlefield).size()!=0:
		var highest_attack_opponent_cards = sort_cards_highest_attack(get_attackable_cards(opponent_cards_on_battlefield))
		
		for card in highest_attack_opponent_cards:
			var player_cards_to_attack = get_attackable_cards(player_cards_on_battlefield).duplicate()
			
			if player_cards_to_attack.size() == 0:
				await direct_attack(card,Global.ENTITY_ENUM.OPPONENT)
			else:
				var attacked_card = get_highest_attack_under(player_cards_to_attack,card.attack)
				await attack(card,attacked_card,Global.ENTITY_ENUM.OPPONENT)
		
	
	end_opponent_turn();

func attack(attacking_card,defending_card,attacker):
	if !defending_card:
		return
	
	var player_id = multiplayer.get_unique_id
	var attacking_card_slot = attacking_card.card_slot_card_is_in.name
	var defending_card_slot = defending_card.card_slot_card_is_in.name
	await attack_here_and_for_client_opponent(player_id,attacking_card,defending_card,attacker)
	if is_multiplayer_game:
		rpc("attack_here_and_for_client_opponent",player_id,attacking_card_slot,defending_card_slot,attacker)
		await opponent_animation_finished
	
		
	if attacking_card.attack_count==0:
		return;
	attacking_card.attack_count-=1
	
	attacking_card.z_index=5
	var defender = Global.ENTITY_ENUM.PLAYER
	if attacker != Global.ENTITY_ENUM.OPPONENT:
		defender = Global.ENTITY_ENUM.OPPONENT
		
	if attacker==Global.ENTITY_ENUM.PLAYER:
		Global.card_manager.unselect_card(Global.card_manager.selected_card)
	
	var attack_difference = min(defending_card.attack,attacking_card.attack)-max(defending_card.attack,attacking_card.attack)
	if defending_card.attack<attacking_card.attack:
		if attacker==Global.ENTITY_ENUM.OPPONENT:
			await destroy_card(defending_card,Global.ENTITY_ENUM.PLAYER)
			await update_health(attack_difference,Global.ENTITY_ENUM.PLAYER)
		else:
			await destroy_card(defending_card,Global.ENTITY_ENUM.OPPONENT)
			await update_health(attack_difference,Global.ENTITY_ENUM.OPPONENT)
	elif defending_card.attack>attacking_card.attack:
		if attacker==Global.ENTITY_ENUM.OPPONENT:
			await destroy_card(attacking_card,Global.ENTITY_ENUM.OPPONENT)
			await update_health(attack_difference,Global.ENTITY_ENUM.OPPONENT)
		else:
			await destroy_card(attacking_card,Global.ENTITY_ENUM.PLAYER)
			await update_health(attack_difference,Global.ENTITY_ENUM.PLAYER)
	else:
		destroy_card(defending_card,defender)
		await destroy_card(attacking_card,attacker)

@rpc("any_peer", "call_remote")
func attack_here_and_for_client_opponent(player_id,attacking_card,defending_card,attacker):
	Global.input_manager.inputs_allowed = false
	if player_id!=multiplayer.get_unique_id:
		if attacker == Global.ENTITY_ENUM.PLAYER:
			attacker = Global.ENTITY_ENUM.OPPONENT
		else:
			attacker = Global.ENTITY_ENUM.PLAYER
		attacking_card = Global.opponent_field.get(str(attacking_card)).card_in_slot
		defending_card = Global.player_field.get(str(defending_card)).card_in_slot
	
	var old_pos = attacking_card.global_position
	var new_pos = Vector2(defending_card.global_position.x,defending_card.global_position.y+Global.BATTLE_POS_OFFSET)
	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card,"global_position",new_pos,Global.DEFAULT_CARD_MOVE_SPEED)
	await tween.finished
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacking_card,"global_position",attacking_card.card_slot_card_is_in.global_position,Global.DEFAULT_CARD_MOVE_SPEED)
	attacking_card.z_index=0
	
	if is_multiplayer_game:
		rpc("notify_animation_done",player_id)
	Global.input_manager.inputs_allowed = true

func direct_attack(attacking_card,attacker):
	if turn_counter==1:
		return
	
	Global.input_manager.inputs_allowed=false
	var player_id = multiplayer.get_unique_id
	var attacking_card_slot = attacking_card.card_slot_card_is_in.name
	await direct_attack_here_and_for_client_opponent(player_id,attacking_card,attacker)
	if is_multiplayer_game:
		rpc("direct_attack_here_and_for_client_opponent",player_id,attacking_card_slot,attacker)
	
	if attacker==Global.ENTITY_ENUM.OPPONENT:
		await update_health(-attacking_card.attack,Global.ENTITY_ENUM.PLAYER)
	else:
		await update_health(-attacking_card.attack,Global.ENTITY_ENUM.OPPONENT)
	
	Global.input_manager.inputs_allowed=true

@rpc("any_peer")
func direct_attack_here_and_for_client_opponent(player_id,attacking_card,attacker):
	if player_id!=multiplayer.get_unique_id:
		if attacker == Global.ENTITY_ENUM.PLAYER:
			attacker = Global.ENTITY_ENUM.OPPONENT
		else:
			attacker = Global.ENTITY_ENUM.PLAYER
		
		attacking_card = Global.opponent_field.get(str(attacking_card)).card_in_slot
	
	if attacking_card.attack_count==0:
		return;
	attacking_card.attack_count-=1
	
	var new_pos_y
	if attacker==Global.ENTITY_ENUM.OPPONENT:
		new_pos_y=1050
	else:
		new_pos_y = 100
	
	attacking_card.z_index=5
	var new_pos = Vector2(attacking_card.global_position.x,new_pos_y)
	
	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card,"global_position",new_pos,Global.DEFAULT_CARD_MOVE_SPEED)
	await wait(0.15)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacking_card,"global_position",attacking_card.card_slot_card_is_in.global_position,Global.DEFAULT_CARD_MOVE_SPEED)
	attacking_card.z_index=0

func enemy_card_select(card):
	var defending_card = card;
	var attacking_card = Global.card_manager.selected_card;
	
	if !attacking_card:
		return;
	
	if turn_counter==1:
		return
	
	if attacking_card.card_type == Global.CARD_TYPE_ENUM.MONSTER:
		if defending_card in opponent_cards_on_battlefield:
			Global.card_manager.selected_card=null
			attack(attacking_card,defending_card,Global.ENTITY_ENUM.PLAYER)


func destroy_card(card,card_owner):
	var player_id = multiplayer.get_unique_id
	var card_slot = card.card_slot_card_is_in.name
	destroy_card_here_and_for_client_opponent(player_id,card,card_owner)
	if is_multiplayer_game:
		rpc("destroy_card_here_and_for_client_opponent",player_id,card_slot,card_owner)

@rpc("any_peer")
func destroy_card_here_and_for_client_opponent(player_id,card,card_owner):
	var graveyard
	Global.input_manager.inputs_allowed = false
	if player_id!=multiplayer.get_unique_id:
		if card_owner == Global.ENTITY_ENUM.PLAYER:
			card_owner = Global.ENTITY_ENUM.OPPONENT
			card = Global.opponent_field.get(str(card)).card_in_slot
		else:
			card_owner = Global.ENTITY_ENUM.PLAYER
			card = Global.player_field.get(str(card)).card_in_slot
	
	var new_pos
	if card_owner == Global.ENTITY_ENUM.PLAYER:
		Global.card_manager.unselect_card(card)
		card.get_node("Area2D/CollisionShape2D").disabled=true
		graveyard = Global.player_field.graveyard
		if card in player_cards_on_battlefield:
			player_cards_on_battlefield.erase(card)
			card.card_slot_card_is_in.get_node("Area2D/CollisionShape2D").disabled=false
	else:
		graveyard = Global.opponent_field.graveyard
		if card in opponent_cards_on_battlefield:
			opponent_cards_on_battlefield.erase(card)
	
	
	new_pos = graveyard.global_position
	var tween = get_tree().create_tween()
	tween.tween_property(card,"global_position",new_pos,Global.DEFAULT_CARD_MOVE_SPEED)
	if card.field_state == Global.FIELD_STATE_ENUM.SET:
		var tween2 = get_tree().create_tween()
		tween2.tween_property(card,"rotation",deg_to_rad(0),Global.DEFAULT_CARD_MOVE_SPEED)
		card.flip_animation.play("flip")
	await tween.finished
	
	graveyard.cards_inside.append(card)
	card.get_parent().remove_child(card)
	graveyard.add_child(card)
	card.global_position = new_pos
	card.card_slot_card_is_in.card_in_slot = false
	card.card_slot_card_is_in = null
	card.z_index=5

	Global.input_manager.inputs_allowed = true


func try_play_best_monster() -> void:
	var opponent_hand = Global.opponent_hand.opponent_hand
	if opponent_hand.size()==0:
		end_opponent_turn()
		return
	
	var random_empty_monster_card_zone = Global.opponent_field.get_empty_monster_card_slots().pick_random()
	var best_monster_card = opponent_hand[0]
	
	for card in opponent_hand:
		if card.attack > best_monster_card.attack:
			best_monster_card=card
	
	await Global.card_manager.play_card_on_field(best_monster_card,random_empty_monster_card_zone,Global.ENTITY_ENUM.OPPONENT)

func end_opponent_turn() -> void:
	for card in opponent_cards_on_battlefield:
		card.attack_count = card.max_attack_count
	turn_counter_up()
	start_player_turn()

func turn_on_end_turn_button():
	Global.player_field.end_turn_button.disabled=false
	Global.player_field.end_turn_button.visible=true

func update_health(ammount,reciever):
	var player_id = multiplayer.get_unique_id
	update_health_here_and_client(player_id,ammount,reciever)
	if is_multiplayer_game:
		rpc("update_health_here_and_client",player_id,ammount,reciever)

func set_starting_health(health):
	var player_id = multiplayer.get_unique_id
	update_health_here_and_client(player_id,health,Global.ENTITY_ENUM.PLAYER)
	await update_health_here_and_client(player_id,health,Global.ENTITY_ENUM.OPPONENT)

@rpc("any_peer")
func update_health_here_and_client(player_id,ammount,reciever):
	if player_id!=multiplayer.get_unique_id:
		if reciever == Global.ENTITY_ENUM.PLAYER:
			reciever = Global.ENTITY_ENUM.OPPONENT
		else:
			reciever = Global.ENTITY_ENUM.PLAYER
	
	for i in range(10):
		if reciever == Global.ENTITY_ENUM.PLAYER:
			player_health+=ammount/10
			if player_health<=0:
				player_health=0
				Global.player_field.health.text=str(player_health)
				game_won(Global.ENTITY_ENUM.OPPONENT)
				return
			
			Global.player_field.health.text=str(player_health)
		else:
			opponent_health+=ammount/10
			if opponent_health<=0:
				opponent_health=0
				Global.opponent_field.opponent_health.text=str(opponent_health)
				game_won(Global.ENTITY_ENUM.PLAYER)
				return
			
			Global.opponent_field.opponent_health.text=str(opponent_health)
		
		await wait(0.02)
	
	
	if reciever == Global.ENTITY_ENUM.PLAYER:
		player_health+=ammount%10
		if player_health<=0:
			player_health=0
			Global.player_field.health.text=str(player_health)
			game_won(Global.ENTITY_ENUM.OPPONENT)
			return
		
		Global.player_field.health.text=str(player_health)
	else:
		opponent_health+=ammount%10
		if opponent_health<=0:
			opponent_health=0
			Global.opponent_field.opponent_health.text.text=str(opponent_health)
			game_won(Global.ENTITY_ENUM.PLAYER)
			return
		

func on_card_play(card,card_owner):
	var effects = card.get_node("Effect").text.split(".")
	await wait(0.2)
	
	for effect in effects:
		if effect.contains("On Play"):
			card_effect_handle(card,card_owner,effect.split(": ")[1])
			await wait(0.5)
	
	if card.card_type == Global.CARD_TYPE_ENUM.SPELL:
		destroy_card(card,card_owner)

func card_effect_handle(card,card_owner,effect):
	var number_regex = RegEx.new()
	number_regex.compile("^\\d+$")
	
	if effect.contains("Destroy"):
		var target = effect.split(" ")[2]
		var target_name = Global.ENTITY_ENUM.PLAYER
		var target_cards = player_cards_on_battlefield
		if target.contains("opponent"):
			target_name = Global.ENTITY_ENUM.OPPONENT
			target_cards = opponent_cards_on_battlefield
		
		var query_term = ""
		for i in range(3,effect.split(" ").size()):
			query_term+=effect.split(" ")[i]+" "
		
		var found_cards = find_cards_with_query(target_cards,query_term)
		
		if number_regex.search(effect.split(" ")[1]):
			var number_of_targets = effect.split(" ")[1].to_int()
			print(number_of_targets)
		elif effect.split(" ")[1].contains("all"):
			for target_card in found_cards:
				destroy_card(target_card,target_name)

func find_cards_with_query(cards,query_term):
	var cards_found = []
	var query = {
	"card_type" = "",
	"type" = "",
	"attack" = "",
	"defense" = "",
	"effect" = "",
	"category" = ""
	}
	
	if query_term.contains("monster"):
		query.card_type=Global.CARD_TYPE_ENUM.MONSTER
	elif query_term.contains("spell"):
		query.card_type=Global.CARD_TYPE_ENUM.SPELL
	elif query_term.contains("trap"):
		query.card_type=Global.CARD_TYPE_ENUM.TRAP
	
	for card in cards:
		for key in query.keys():
			if str(query[key]) != "":
				if card.get(key) == query[key]:
					cards_found.append(card)
	
	return cards_found


func game_won(reciever):
	if reciever==Global.ENTITY_ENUM.PLAYER:
		print("You Win")
	else:
		print("You Lose")

func start_game():
	await wait(1)
	if current_turn_player == Global.ENTITY_ENUM.OPPONENT:
		opponent_turn()

func get_attackable_cards(field):
	var attackable_cards = []
	for card in field:
		if card.card_type == Global.CARD_TYPE_ENUM.MONSTER || card.card_type == Global.CARD_TYPE_ENUM.ACE:
			attackable_cards.append(card)
	return attackable_cards
	
func get_magic_cards(field):
	var magic_cards = []
	for card in field:
		if card.card_type == Global.CARD_TYPE_ENUM.SPELL || card.card_type == Global.CARD_TYPE_ENUM.TRAP:
			magic_cards.append(card)
	return magic_cards

func sort_cards_highest_attack(cards):
	var sorted_array = cards.duplicate()  # Create a copy to avoid modifying the original array
	
	for i in range(sorted_array.size() - 1, 0, -1):  
		for j in range(i):  
			if sorted_array[j].attack < sorted_array[j + 1].attack:  # Compare attack values
				var temp = sorted_array[j]
				sorted_array[j] = sorted_array[j + 1]
				sorted_array[j + 1] = temp
	
	return sorted_array  

func get_highest_attack_under(cards,ammount):
	var attacking_card
	var highest_attacking_card
	
	for card in cards:
		if card.attack<ammount:
			attacking_card = card
			if highest_attacking_card:
				if highest_attacking_card.attack<card.attack:
					highest_attacking_card=card
			else:
				highest_attacking_card=card
	
	return highest_attacking_card

func wait(wait_time):
	Global.player_field.battle_timer.wait_time=wait_time
	Global.player_field.battle_timer.start()
	await Global.player_field.battle_timer.timeout


func _on_end_turn_button_pressed() -> void:
	turn_counter_up()
	if is_multiplayer_game:
		rpc("turn_counter_up")
	else:
		opponent_turn()
	end_player_turn()


@rpc("any_peer")
func turn_counter_up():
	turn_counter+=1
	Global.player_field.turn_counter.text = "Turn: "+str(turn_counter)
