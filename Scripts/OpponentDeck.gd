extends Node2D
class_name OpponentDeck

var opponent_deck

@onready var card_count = $CardCount
@onready var image = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.opponent_deck = self

func draw_card(count):
	for i in range(count):
		if opponent_deck.size()==0:
			return
		var card_drawn_name = opponent_deck[0]
		opponent_deck.erase(card_drawn_name)
		card_count.text = str(opponent_deck.size())
		var card_scene = preload(Global.CARD_SCENE_PATH_OPPONENT)
		var new_card = card_scene.instantiate()
		Global.card_manager.add_child(new_card)
		new_card.name="Card"
		
		new_card.hand_array_position = i
		new_card.card_type = Global.card_database.CARDS[card_drawn_name]["type"]
		if new_card.card_type==Global.CARD_TYPE_ENUM.MONSTER:
			new_card.get_node("Attack").text = str(Global.card_database.CARDS[card_drawn_name]["attack"])
			new_card.attack = Global.card_database.CARDS[card_drawn_name]["attack"]
			new_card.get_node("Defense").text = str(Global.card_database.CARDS[card_drawn_name]["defense"])
			new_card.defense = Global.card_database.CARDS[card_drawn_name]["defense"]
		
		new_card.get_node("Effect").text = str(Global.card_database.CARDS[card_drawn_name]["effect"])
		var card_image_path = str(Global.card_database.CARDS[card_drawn_name]["image"])
		var card_texture = load(card_image_path)
		var card_image = card_texture.get_image()
		card_image.resize(Global.CARD_WIDTH, Global.CARD_HEIGHT)
		new_card.get_node("CardImage").texture = ImageTexture.create_from_image(card_image)
		

		Global.opponent_hand.add_card_to_hand(new_card, Global.CARD_DRAW_SPEED)
		
		if opponent_deck.size()==0:
			image.visible=false
			card_count.visible=false
			break
