extends Node2D
class_name OpponentField

var turn_player = false
@onready var opponent_health = $Health
@onready var opponent_deck = $OpponentDeck
@onready var opponent_hand = $OpponentHand
@onready var graveyard = $Graveyard

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.opponent_field = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
