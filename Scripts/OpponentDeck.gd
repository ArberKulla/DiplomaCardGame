extends Node2D


const CARD_WIDTH = 135.0
const CARD_HEIGHT = 192.0
const CARD_SCENE_PATH = "res://Scenes/OpponentCard.tscn"
var opponent_deck = ["Archer","Archer","Archer","Archer","Archer","Archer","Archer","Archer","Archer","Archer","Archer","Archer"]
var card_database_reference

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	opponent_deck.shuffle()
	$RichTextLabel.text = str(opponent_deck.size())
	card_database_reference= preload("res://Scripts/CardDatabase.gd")
	draw_card(5)

func draw_card(count):
	for i in range(count):
		if opponent_deck.size()==0:
			return
		var card_drawn_name = opponent_deck[0]
		opponent_deck.erase(card_drawn_name)
		$RichTextLabel.text = str(opponent_deck.size())
		var card_scene = preload(CARD_SCENE_PATH)
		var new_card = card_scene.instantiate()
		
		new_card.card_type = str(card_database_reference.CARDS[card_drawn_name]["type"])
		if new_card.card_type=="Monster":
			new_card.get_node("Attack").text = str(card_database_reference.CARDS[card_drawn_name]["attack"])
			new_card.attack = card_database_reference.CARDS[card_drawn_name]["attack"]
			new_card.get_node("Defense").text = str(card_database_reference.CARDS[card_drawn_name]["defense"])
			new_card.defense = card_database_reference.CARDS[card_drawn_name]["defense"]
		
		new_card.get_node("Effect").text = str(card_database_reference.CARDS[card_drawn_name]["effect"])
		var card_image_path = str(card_database_reference.CARDS[card_drawn_name]["image"])
		var card_texture = load(card_image_path)
		var card_image = card_texture.get_image()
		card_image.resize(CARD_WIDTH, CARD_HEIGHT)
		new_card.get_node("CardImage").texture = ImageTexture.create_from_image(card_image)
		
		$"../CardManager".add_child(new_card)
		new_card.name="Card"
		$"../OpponentHand".add_card_to_hand(new_card, $"..".CARD_DRAW_SPEED)
		
		if opponent_deck.size()==0:
			$Sprite2D.visible=false
			$RichTextLabel.visible=false
			break
