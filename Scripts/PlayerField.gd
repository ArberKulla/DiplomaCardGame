extends Control
class_name PlayerField

@onready var graveyard = $CardSlots/Monster/Graveyard
@onready var health = $LifePoints/Health
@onready var battle_timer = $"../../BattleTimer"
@onready var end_turn_button = $LifePoints/EndTurnButton
@onready var turn_counter = $"../LinkZone/TurnCounter"
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

func _ready() -> void:
	Global.player_field = self
