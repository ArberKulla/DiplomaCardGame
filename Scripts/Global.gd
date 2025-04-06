extends Node

const CARD_DRAW_SPEED = 0.2
const DEFAULT_CARD_MOVE_SPEED = 0.1
const DEFAULT_CARD_SCALE = 0.7
const SMALL_CARD_SCALE = 0.6
const STARTING_HEALTH = 2000
const BATTLE_POS_OFFSET = 20
const CARD_WIDTH = 135.0
const CARD_HEIGHT = 192.0
const CARD_HAND_WIDTH = 110
const HAND_Y_POSITION = 840
const HAND_Y_POSITION_OPPONENT = 80
var level_id

#Scene Paths
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const CARD_SCENE_PATH_OPPONENT = "res://Scenes/OpponentCard.tscn"
const PLAYER_FIELD_SCENE_PATH = "res://Scenes/PlayerField.tscn"
const OPPONENT_FIELD_SCENE_PATH = "res://Scenes/OpponentField.tscn"
const SINGLEPLAYER_MENU_SCENE_PATH = "res://Scenes/SingleplayerMenu.tscn"
const MUTLIPLAYER_MENU_SCENE_PATH = "res://Scenes/MultiplayerMenu.tscn"
const SINGLEPLAYER_LEVEL_SCENE_PATH = "res://Scenes/SingleplayerLevel.tscn"


#Refs
var opponent_hand: OpponentHand
var opponent_field : OpponentField
var opponent_deck : OpponentDeck
var battle_manager: BattleManager
var player_hand: PlayerHand
var player_field: PlayerField
var player_deck: PlayerDeck
var input_manager: InputManager
var card_manager: CardManager
var card_database = CardDatabase.new()

#Masks
const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2
const COLLISION_MASK_DECK = 4
const COLLISION_MASK_OPPONENT_CARD = 8

#Enums
enum ENTITY_ENUM { PLAYER, OPPONENT }
enum CARD_TYPE_ENUM { MONSTER, SPELL, TRAP, ACE, FIELD }
