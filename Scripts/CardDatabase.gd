class_name CardDatabase

var CARDS = {}

func _init():
	CARDS = {
		"Knight": {
			"attack": 300,
			"defense": 2,
			"image": "res://Assets/pbptw9.png",
			"type": Global.CARD_TYPE_ENUM.MONSTER,
			"effect": "None"
		},
		"Archer": {
			"attack": 500,
			"defense": 2,
			"image": "res://Assets/pbptw9.png",
			"type": Global.CARD_TYPE_ENUM.MONSTER,
			"effect": "None"
		},
		"Demon": {
			"attack": 1000,
			"defense": 2,
			"image": "res://Assets/pbptw9.png",
			"type": Global.CARD_TYPE_ENUM.MONSTER,
			"effect": "None"
		},
		"TestSpell": {
			"attack": null,
			"defense": null,
			"image": "res://Assets/Raigeki.png",
			"type": Global.CARD_TYPE_ENUM.SPELL,
			"effect": "On Play: Destroy all opponent monster cards."
		}
	}


const player_deck = ["Demon","Knight","Demon","TestSpell","Demon","Knight","Demon","TestSpell"]
const opponent_deck  = ["Archer","Archer","Archer","Archer","Archer","Archer","Archer","Archer","Archer","Archer","Archer","Archer"]
const level1  = ["Archer","Archer","Archer","Archer","Archer","Archer","Archer","Archer","Archer","Archer","Archer","Archer"]
