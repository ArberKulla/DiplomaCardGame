extends Node2D

signal hovered
signal hovered_off

var hand_position
var card_slot_card_is_in
var card_type
var attack
var defense
var attack_count = 1
var max_attack_count = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().connect_card_signals(self) # Replace with function body.

func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	hovered_off.emit(self)
