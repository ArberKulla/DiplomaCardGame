extends Control
class_name Multiplayer

var peer = ENetMultiplayerPeer.new()
const PORT = 200
const SERVER_ADDRESS = "localhost"
var turn_player

@onready var field = preload(Global.FIELD_SCENE_PATH)


func _on_host_button_pressed() -> void:
	disable_buttons()
	
	peer.create_server(PORT)
	
	multiplayer.multiplayer_peer = peer
		
	multiplayer.peer_connected.connect(_on_peer_connected)

	add_child(field.instantiate())


func _on_join_button_pressed() -> void:
	disable_buttons()
	
	peer.create_client(SERVER_ADDRESS,PORT)
	
	multiplayer.multiplayer_peer = peer
	
	add_child(field.instantiate())
	
	multiplayer.peer_connected.connect(_on_client_connected)

func _on_peer_connected(peer_id):
	host_set_up()

func _on_client_connected(peer_id):
	client_set_up()

func disable_buttons():
	$HostButton.visible = false
	$HostButton.disabled = true
	$JoinButton.visible = false
	$HostButton.disabled = true


func host_set_up():
	var player_id = multiplayer.get_unique_id
	turn_player = randi() % 2
	flip_coin_start_turn(player_id,turn_player)
	rpc("flip_coin_start_turn",player_id,turn_player)
	
	Global.battle_manager.is_multiplayer_game = true
	Global.battle_manager.update_health(Global.STARTING_HEALTH,Global.ENTITY_ENUM.PLAYER)
	Global.player_deck.player_deck = Global.card_database.player_deck.duplicate()
	Global.opponent_deck.opponent_deck = Global.card_database.opponent_deck.duplicate()
	Global.player_deck.draw_mutliplayer(5)

func client_set_up():
	Global.battle_manager.is_multiplayer_game = true
	Global.battle_manager.update_health(Global.STARTING_HEALTH,Global.ENTITY_ENUM.PLAYER)
	Global.player_deck.player_deck = Global.card_database.opponent_deck.duplicate()
	Global.opponent_deck.opponent_deck = Global.card_database.player_deck.duplicate()
	Global.player_deck.draw_mutliplayer(5)

@rpc("any_peer")
func flip_coin_start_turn(player_id,turn_player):
	if player_id!=multiplayer.get_unique_id:
		turn_player ^= 1
	
	if turn_player==0:
		Global.battle_manager.current_turn_player = Global.ENTITY_ENUM.PLAYER
		Global.battle_manager.turn_on_end_turn_button()
	else:
		Global.battle_manager.current_turn_player = Global.ENTITY_ENUM.OPPONENT
