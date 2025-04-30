extends Control
class_name OpponentHand
var opponent_hand = []

func _ready() -> void:
	Global.opponent_hand = self

func add_card_to_hand(card):
	opponent_hand.insert(opponent_hand.size(),card)
	await animate_card_to_position(card)
	card.get_parent().remove_child(card)
	add_child(card)
	card.scale = Vector2(Global.DEFAULT_CARD_SCALE,Global.DEFAULT_CARD_SCALE)
	update_hand_position()

func update_hand_position():
	for i in range(opponent_hand.size()):
		var card = opponent_hand[i]
		card.hand_array_position = i

func animate_card_to_position(card):
	await get_tree().process_frame
	var target_position = Vector2(self.global_position.x+self.size.x,self.global_position.y+self.size.y/4)
	var tween = get_tree().create_tween()
	tween.tween_property(card,"global_position",target_position,0.1)
	await tween.finished

func remove_card_from_hand(card):
	if card in opponent_hand:
		opponent_hand.erase(card)
