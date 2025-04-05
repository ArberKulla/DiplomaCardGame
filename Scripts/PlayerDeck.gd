extends Node2D
class_name PlayerDeck

var player_deck
var card_database_reference

@onready var card_count = $CardCount
@onready var collision = $Area2D/CollisionShape2D
@onready var sprite = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.player_deck = self
	card_database_reference= CardDatabase.new()

func draw_mutliplayer(count):
	var player_id = multiplayer.get_unique_id
	draw_here_and_for_clients_opponent(player_id,count)
	rpc("draw_here_and_for_clients_opponent",player_id,count)

@rpc("any_peer")
func draw_here_and_for_clients_opponent(player_id,count):
	if multiplayer.get_unique_id == player_id:
		draw_card(count)
	else:
		get_parent().get_parent().get_node("OpponentField/OpponentDeck").draw_card(count)

func draw_card(count):
	for i in range(count):
		if player_deck.size()==0:
			return
		var card_drawn_name = player_deck[0]
		player_deck.erase(card_drawn_name)
		card_count.text = str(player_deck.size())
		
		var new_card = create_card(card_drawn_name)
		
		new_card.hand_array_position = i
		if player_deck.size()==0:
			collision.disabled=true
			sprite.visible=false
			card_count.visible=false
			break
			
		Global.player_hand.add_card_to_hand(new_card, Global.CARD_DRAW_SPEED)
		new_card.flip_animation.play("flip")


func create_card(card_drawn_name):
	var card_scene = preload(Global.CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	Global.card_manager.add_child(new_card)
	new_card.name="Card"
	
	new_card.card_name = card_drawn_name
	new_card.card_type = str(card_database_reference.CARDS[card_drawn_name]["type"])
	if new_card.card_type=="Monster" || new_card.card_type=="Ace":
		new_card.get_node("Attack").text = str(card_database_reference.CARDS[card_drawn_name]["attack"])
		new_card.attack = card_database_reference.CARDS[card_drawn_name]["attack"]
		new_card.get_node("Defense").text = str(card_database_reference.CARDS[card_drawn_name]["defense"])
		new_card.defense = card_database_reference.CARDS[card_drawn_name]["defense"]
	else:
		new_card.get_node("Defense").visible = false
		new_card.get_node("Attack").visible = false
	
	new_card.get_node("Effect").text = str(card_database_reference.CARDS[card_drawn_name]["effect"])
	var card_image_path = str(card_database_reference.CARDS[card_drawn_name]["image"])
	var card_texture = load(card_image_path)
	var card_image = card_texture.get_image()
	card_image.resize(Global.CARD_WIDTH, Global.CARD_HEIGHT)
	new_card.card_image.texture = ImageTexture.create_from_image(card_image)
	

	
	return new_card
