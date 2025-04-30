extends Control
class_name OpponentField

var turn_player = false
@onready var opponent_health = $LifePoints/Health
@onready var opponent_hand = $"../OpponentHand"
@onready var graveyard = $CardSlots/Monster/Graveyard
@onready var monster_card_slots = [$CardSlots/Monster/M1,$CardSlots/Monster/M2,$CardSlots/Monster/M3,$CardSlots/Monster/M4,$CardSlots/Monster/M5]
@onready var M1 =$CardSlots/Monster/M1
@onready var M2 = $CardSlots/Monster/M2
@onready var M3 = $CardSlots/Monster/M3
@onready var M4 = $CardSlots/Monster/M4
@onready var M5 =$CardSlots/Monster/M5
@onready var S1 = $CardSlots/Magic/S1
@onready var S2 =$CardSlots/Magic/S2
@onready var S3 =$CardSlots/Magic/S3
@onready var S4 =$CardSlots/Magic/S4
@onready var S5 =$CardSlots/Magic/S5
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
	
