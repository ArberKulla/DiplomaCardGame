extends Control
class_name PlayerHand
var player_hand = []

func _ready() -> void:
	Global.player_hand = self

func add_card_to_hand(card,hand_position):
	if hand_position==-1:
		hand_position = player_hand.size()
	
	player_hand.insert(hand_position,card)
	await animate_card_to_position(card,hand_position)
	card.get_parent().remove_child(card)
	add_child(card)
	move_child(card,hand_position)
	update_hand_position()
	card.scale = Vector2(Global.DEFAULT_CARD_SCALE,Global.DEFAULT_CARD_SCALE)
	
	if Global.card_manager.selected_card_in_hand:
		Global.card_manager.unselect_card_in_hand(Global.card_manager.selected_card_in_hand)

func update_hand_position():
	for i in range(player_hand.size()):
		var card = player_hand[i]
		card.hand_array_position = i

func animate_card_to_position(card,hand_position):
	await get_tree().process_frame
	var target_position = Vector2(self.global_position.x+(hand_position)*(self.size.x/player_hand.size()),self.global_position.y+self.size.y/4)
	var tween = get_tree().create_tween()
	var animation_speed = Global.DEFAULT_CARD_MOVE_SPEED
	if card.global_position.distance_to(target_position)<100:
		animation_speed = 0
	tween.tween_property(card,"global_position",target_position,animation_speed)
	await tween.finished

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)

func calculate_drag_card_position(card):
	var card_position_x = card.global_position.x
	
	
	for i in range(player_hand.size()-1):
		var card_1_x = player_hand[i].global_position.x
		var card_2_x = player_hand[i+1].global_position.x
		
		if card_position_x<=card_1_x  and card_position_x<=card_2_x:
			return 0;
		
		if card_position_x>=card_1_x and card_position_x<=card_2_x:
			return i+1;
	
	return -1;
