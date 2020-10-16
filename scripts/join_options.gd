extends Panel


enum distance_filers {
	Close,
	Default,
	Far,
	Worldwide
}

onready var room_code: LineEdit = get_node("RoomCode/RCInput")
onready var scroll: ScrollContainer = get_node("Browser/ScrollContainer")
onready var lobby_master: Node2D = get_parent().get_node("Lobby")
onready var lobby_list: VBoxContainer = get_node("Browser/ScrollContainer/LobbyList")
onready var lobby_object_scene: PackedScene = preload("res://scenes/lobby_object.tscn")

func _ready():
# warning-ignore:return_value_discarded
	Steam.connect("lobby_match_list", self, "_on_lobby_match_list")


func _on_lobby_match_list(lobby_ids: Array) -> void:
	for lobby_id in lobby_ids:
		var lobby = lobby_object_scene.instance()
		lobby.lobby_id = lobby_id
		lobby_list.add_child(lobby)
		lobby.join_button.connect("pressed", lobby_master, "join_lobby", [lobby_id])


func _on_JoinRCButton_pressed() -> void:
	pass # Replace with function body.


func _on_Cancel_pressed() -> void:
	hide()
	reset_options()


func reset_options() -> void:
	room_code.text = ""
	scroll.scroll_vertical = 0


func _on_visibility_changed() -> void:
	if visible:
		Steam.addRequestLobbyListDistanceFilter(distance_filers.Worldwide)
		Steam.requestLobbyList()


func _on_Refresh_pressed() -> void:
	for child in lobby_list.get_children():
		lobby_list.remove_child(child)
		child.queue_free()
	Steam.addRequestLobbyListDistanceFilter(distance_filers.Worldwide)
	Steam.requestLobbyList()
	scroll.scroll_vertical = 0
