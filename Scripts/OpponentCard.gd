extends Node2D

@onready var card_image = $CardImage
@onready var flip_animation = $Flip

var card_type
var starting_position
var hand_array_position
var hand_position
var attack
var defense
var card_slot_card_is_in
var attack_count = 1
var max_attack_count = 1
