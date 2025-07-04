extends Control
class_name Card

signal hovered
signal hovered_off

var card_name
var hand_array_position
var hand_position
var field_state
var card_slot_card_is_in
var card_type
var attack
var defense
var attack_count = 1
var max_attack_count = 1
var highlighted = false

@onready var card_image = $CardImage
@onready var card_back_image = $CardBackImage
@onready var selected = $Selected
@onready var flip_animation = $Flip

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var card_image = card_back_image.texture.get_image()
	card_image.resize(size.x,size.y)
	card_back_image.texture = ImageTexture.create_from_image(card_image)
	Global.card_manager.connect_card_signals(self)

func highlight():
	if !highlighted:
		highlighted = true
		global_position.y=Global.player_hand.global_position.y-10
		z_index = 2

func unhighlight():
	if highlighted:
		highlighted = false
		global_position.y=Global.player_hand.global_position.y
		z_index = 1

func serialize() -> Dictionary:
	var data = {
		"card_slot_card_is_in": card_slot_card_is_in,
		"card_type": card_type,
		"attack": attack,
		"defense": defense,
		"attack_count": attack_count,
		"max_attack_count": max_attack_count
	}
	
	# Handle image serialization
	if card_image and card_image.texture:
		var img = card_image.texture.get_image()
		var img_data = img.save_png_to_buffer()  # Convert image to binary
		data["card_image"] = img_data  # Store binary image data
	
	return data

func unserialize(data: Dictionary):
	if "card_slot_card_is_in" in data: card_slot_card_is_in = data["card_slot_card_is_in"]
	if "card_type" in data: card_type = data["card_type"]
	if "attack" in data: attack = data["attack"]
	if "defense" in data: defense = data["defense"]
	if "attack_count" in data: attack_count = data["attack_count"]
	if "max_attack_count" in data: max_attack_count = data["max_attack_count"]
	
	# Handle image deserialization
	if "card_image" in data:
		var img = Image.new()
		img.load_png_from_buffer(data["card_image"])  # Load from binary
		var tex = ImageTexture.create_from_image(img)
		get_node(card_image).texture = tex  # Assign texture

func _on_mouse_entered() -> void:
	hovered.emit(self)


func _on_mouse_exited() -> void:
	hovered_off.emit(self)
