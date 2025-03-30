extends Node2D

const CARD_WIDTH = 110
const HAND_Y_POSITION = 75

var opponent_hand = []

func add_card_to_hand(card,speed):
	if card not in opponent_hand:
		var default_scale = $"..".DEFAULT_CARD_SCALE
		card.scale = Vector2(default_scale,default_scale)
		opponent_hand.insert(0,card)
		update_hand_position(speed)
	else:
		animate_card_to_position(card,card.hand_position,$"..".DEFAULT_CARD_MOVE_SPEED)

func update_hand_position(speed):
	for i in range(opponent_hand.size()):
		var new_postion = Vector2(calculate_card_position(i),HAND_Y_POSITION)
		var card = opponent_hand[i]
		card.hand_position = new_postion
		animate_card_to_position(card,new_postion,speed)

func calculate_card_position(index):
	var total_width = (opponent_hand.size()-1)*CARD_WIDTH
	var x_offset = (get_viewport().size.x / 2) + index * CARD_WIDTH - total_width / 2  
	return x_offset

func animate_card_to_position(card, new_position,speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card,"position",new_position,speed)

func remove_card_from_hand(card):
	if card in opponent_hand:
		opponent_hand.erase(card)
		update_hand_position($"..".DEFAULT_CARD_MOVE_SPEED)
