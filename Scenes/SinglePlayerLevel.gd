extends Node2D

@onready var player_field_scene = preload(Global.PLAYER_FIELD_SCENE_PATH)
@onready var opponent_field_scene = preload(Global.OPPONENT_FIELD_SCENE_PATH)
@onready var level_id = Global.level_id

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(player_field_scene.instantiate())
	add_child(opponent_field_scene.instantiate())
	Global.battle_manager.is_multiplayer_game=false
	var turn_player = randi() % 2
	
	if turn_player==0:
		Global.battle_manager.current_turn_player = Global.ENTITY_ENUM.PLAYER
		Global.battle_manager.turn_on_end_turn_button()
	else:
		Global.battle_manager.current_turn_player = Global.ENTITY_ENUM.OPPONENT	
	
	Global.player_deck.player_deck = CardDatabase.player_deck.duplicate()
	Global.opponent_deck.opponent_deck = Global.card_database.get("level"+str(level_id)).duplicate()
	Global.player_deck.draw_card(5)
	Global.opponent_deck.draw_card(5)
	await Global.battle_manager.set_starting_health(Global.STARTING_HEALTH)
	await Global.battle_manager.start_game()
