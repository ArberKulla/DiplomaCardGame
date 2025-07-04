extends Control

var card
var card_slot
var mouse_in_panel = false
signal normal_summon
signal tribute_summon
signal special_summon
signal play
signal set_play

@onready var special_button = $PanelContainer/MarginContainer/VBoxContainer/Special
@onready var tribute_button = $PanelContainer/MarginContainer/VBoxContainer/Tribute
@onready var normal_button = $PanelContainer/MarginContainer/VBoxContainer/Normal
@onready var play_button = $PanelContainer/MarginContainer/VBoxContainer/Play
@onready var set_button = $PanelContainer/MarginContainer/VBoxContainer/Set
@onready var attack_position = $PanelContainer/MarginContainer/VBoxContainer/Attack
@onready var defense_position = $PanelContainer/MarginContainer/VBoxContainer/Defense

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.card_manager.connect_panel_signals(self) # Replace with function body.

func spell_visible():
	play_button.visible = true

func normal_visible():
	normal_button.visible = true
	set_button.visible = true

func _on_special_pressed() -> void:
	special_summon.emit(card,card_slot)	
	queue_free()


func _on_tribute_pressed() -> void:
	tribute_summon.emit(card,card_slot)
	queue_free()


func _on_normal_pressed() -> void:
	normal_summon.emit(card,card_slot)
	queue_free()


func _on_play_pressed() -> void:
	play.emit(card,card_slot)
	queue_free()

func _on_set_pressed() -> void:
	set_play.emit(card,card_slot)
	queue_free()

func _input(event: InputEvent):
	if mouse_in_panel:
		return
	
	if Input.is_action_just_pressed("left_click") or Input.is_action_just_pressed("right_click"):
		queue_free()


func _on_attack_pressed() -> void:
	pass # Replace with function body.


func _on_defense_pressed() -> void:
	pass # Replace with function body.
	

func _on_panel_container_mouse_entered() -> void:
	mouse_in_panel = true

func _on_panel_container_mouse_exited() -> void:
	mouse_in_panel = false
