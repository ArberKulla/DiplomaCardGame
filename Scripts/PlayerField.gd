extends Node2D
class_name PlayerField

@onready var graveyard = $Graveyard
@onready var health = $Health
@onready var battle_timer = $BattleTimer
@onready var end_turn_button = $EndTurnButton
@onready var turn_counter = $TurnCounter


func _ready() -> void:
	Global.player_field = self
