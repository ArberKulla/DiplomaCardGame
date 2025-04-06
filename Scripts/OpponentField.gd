extends Node2D
class_name OpponentField

var turn_player = false
@onready var opponent_health = $Health
@onready var opponent_deck = $OpponentDeck
@onready var opponent_hand = $OpponentHand
@onready var graveyard = $Graveyard
@onready var monster_card_slots = [$M1,$M2,$M3,$M4,$M5]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.opponent_field = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_empty_monster_card_slots():
	var empty_card_slots = []
	
	for card_slot in monster_card_slots:
		if !card_slot.card_in_slot:
			empty_card_slots.append(card_slot)
	
	return empty_card_slots
	
