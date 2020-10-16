extends Panel


onready var public: Button = get_node("Public")
onready var friends: Button = get_node("Friends")
onready var private: Button = get_node("Private")
onready var player_count: Slider = get_node("Players/Count")
onready var lobby: Node2D = get_parent().get_node("Lobby")

var type_group: ButtonGroup = ButtonGroup.new()
var lobby_types: Dictionary = {"Public" : 2, "Friends": 1, "Private": 0}


func _ready():
	public.group = type_group
	friends.group = type_group
	private.group = type_group


func _on_Confirm_pressed() -> void:
	var lobby_type = lobby_types[type_group.get_pressed_button().name]
	var max_players = player_count.value
	
	if Global.lobby_id == 0:
		Steam.createLobby(lobby_type, max_players)


func _on_Cancel_pressed() -> void:
	hide()
	reset_options()


func reset_options() -> void:
	friends.pressed = true
	player_count.value = 2
