extends Control


onready var map: Label = get_node("Map")
onready var players: Label = get_node("Players")
onready var ping: Label = get_node("Ping")
onready var join_button: Button = get_node("Join")

var lobby_id: int

func _ready():
	configure()


func configure() -> void:
	var num_members = Steam.getNumLobbyMembers(lobby_id)
	var member_limit = Steam.getLobbyMemberLimit(lobby_id)
	var ping_estimate = Steam.estimatePingTimeFromLocalHost(lobby_id)
	map.text = "Temp"
	players.text = "%d/%d" % [num_members, member_limit]
	ping.text = "%d" % ping_estimate
	name = "lobby_%d" % [lobby_id]
