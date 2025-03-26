extends Node2D

const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
var player_deck = ["Demon","Knight","Demon"]
var card_database_reference

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_deck.shuffle()
	$RichTextLabel.text = str(player_deck.size())
	card_database_reference= preload("res://Scripts/CardDatabase.gd")
	draw_card(5)

func draw_card(count):
	for i in range(count):
		if player_deck.size()==0:
			return
		var card_drawn_name = player_deck[0]
		player_deck.erase(card_drawn_name)
		$RichTextLabel.text = str(player_deck.size())
		var card_scene = preload(CARD_SCENE_PATH)
		var new_card = card_scene.instantiate()

		new_card.get_node("Attack").text = str(card_database_reference.CARDS[card_drawn_name][0])
		new_card.attack = card_database_reference.CARDS[card_drawn_name][0]
		new_card.get_node("Defense").text = str(card_database_reference.CARDS[card_drawn_name][1])
		new_card.defense = card_database_reference.CARDS[card_drawn_name][1]
		var card_image_path = str(card_database_reference.CARDS[card_drawn_name][2])
		new_card.get_node("CardImage").texture = load(card_image_path)
		new_card.card_type = str(card_database_reference.CARDS[card_drawn_name][3])

		$"../CardManager".add_child(new_card)
		new_card.name="Card"
		$"../PlayerHand".add_card_to_hand(new_card, $"..".CARD_DRAW_SPEED)
		new_card.get_node("Flip").play("flip")
		
		if player_deck.size()==0:
			$Area2D/CollisionShape2D.disabled=true
			$Sprite2D.visible=false
			$RichTextLabel.visible=false
			break

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
