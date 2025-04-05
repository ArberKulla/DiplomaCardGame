extends Node2D
class_name Multiplayer

var peer = ENetMultiplayerPeer.new()
const PORT = 200
const SERVER_ADDRESS = "localhost"
var player_deck = ["Demon","Knight","Demon","TestSpell","Demon","Knight","Demon","TestSpell"]
var opponent_deck  = ["Archer","Archer","Archer","Archer","Archer","Archer","Archer","Archer","Archer","Archer","Archer","Archer"]
var turn_player




@export var player_field_scene : PackedScene
@export var opponent_field_scene : PackedScene


func _on_host_button_pressed() -> void:
	disable_buttons()
	
	peer.create_server(PORT)
	
	multiplayer.multiplayer_peer = peer
		
	multiplayer.peer_connected.connect(_on_peer_connected)
	
	var player_scene = player_field_scene.instantiate()
	var opponent_scene = opponent_field_scene.instantiate()
	
	add_child(opponent_scene)
	add_child(player_scene)


func _on_join_button_pressed() -> void:
	disable_buttons()
	
	peer.create_client(SERVER_ADDRESS,PORT)
	
	multiplayer.multiplayer_peer = peer
	
	var player_scene = player_field_scene.instantiate()
	add_child(player_scene)
	
	var opponent_scene = opponent_field_scene.instantiate()
	add_child(opponent_scene)
	
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


func _ready() -> void:
	turn_player = randi() % 2

func host_set_up():
	var player_id = multiplayer.get_unique_id
	flip_coin_start_turn(player_id,turn_player)
	rpc("flip_coin_start_turn",player_id,turn_player)
	
	Global.battle_manager.update_health(Global.STARTING_HEALTH,"Player")
	Global.player_deck.player_deck = player_deck
	Global.opponent_deck.opponent_deck = opponent_deck
	Global.player_deck.draw_mutliplayer(5)

func client_set_up():
	Global.battle_manager.update_health(Global.STARTING_HEALTH,"Player")
	Global.player_deck.player_deck = opponent_deck
	Global.opponent_deck.opponent_deck = player_deck
	Global.player_deck.draw_mutliplayer(5)

@rpc("any_peer")
func flip_coin_start_turn(player_id,turn_player):
	if player_id!=multiplayer.get_unique_id:
		turn_player ^= 1
	
	if turn_player==0:
		Global.battle_manager.current_turn_player = "Player"
		Global.battle_manager.turn_on_end_turn_button()
	else:
		Global.battle_manager.current_turn_player = "Opponent"
