extends Node2D
class_name OpponentHand

var opponent_hand = []


func _ready() -> void:
	Global.opponent_hand=self

func add_card_to_hand(card,speed):
	if card not in opponent_hand:
		var default_scale = Global.DEFAULT_CARD_SCALE
		card.scale = Vector2(default_scale,default_scale)
		opponent_hand.insert(opponent_hand.size(),card)
		update_hand_position(speed)
	else:
		animate_card_to_position(card,card.hand_position,Global.DEFAULT_CARD_MOVE_SPEED)

func update_hand_position(speed):
	for i in range(opponent_hand.size()):
		var new_postion = Vector2(calculate_card_position(i),Global.HAND_Y_POSITION_OPPONENT)
		var card = opponent_hand[i]
		card.hand_position = new_postion
		card.hand_array_position = i
		animate_card_to_position(card,new_postion,speed)

func calculate_card_position(index):
	var total_width = (opponent_hand.size()-1)*Global.CARD_HAND_WIDTH
	var x_offset = (get_viewport().size.x / 2) + index * Global.CARD_HAND_WIDTH - total_width / 2  
	return x_offset

func animate_card_to_position(card, new_position,speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card,"position",new_position,speed)

func remove_card_from_hand(card):
	if card in opponent_hand:
		opponent_hand.erase(card)
		update_hand_position(Global.DEFAULT_CARD_MOVE_SPEED)
