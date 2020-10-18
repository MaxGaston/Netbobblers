extends Node2D


onready var member_count: Label = get_node("Members/Count")
onready var member_list: VBoxContainer = get_node("Members/Scroll/List")
onready var chat_history: VBoxContainer = get_node("Chat/Scroll/History")
onready var chat_input: LineEdit = get_node("Chat/Input")
onready var player_char: Sprite = get_node("Portrait/Sprite")
onready var main: Node2D = get_parent().get_node("Main")
onready var join_options: Panel = get_parent().get_node("JoinOptions")
onready var host_options: Panel = get_parent().get_node("HostOptions")
onready var server_buttons: Node2D = get_node("Buttons/Server")
onready var client_buttons: Node2D = get_node("Buttons/Client")
onready var game_options: Panel = get_node("GameOptions")

onready var member_scene: PackedScene = preload("res://scenes/lobby_member.tscn")

var lobby_invite_arg: bool

func _ready():
# warning-ignore:return_value_discarded
	Steam.connect("lobby_created", self, "_on_lobby_created")
# warning-ignore:return_value_discarded
	#Steam.connect("lobby_match_list", self, "_on_lobby_match_list")
# warning-ignore:return_value_discarded
	Steam.connect("lobby_joined", self, "_on_lobby_joined")
# warning-ignore:return_value_discarded
	Steam.connect("lobby_chat_update", self, "_on_lobby_chat_update")
# warning-ignore:return_value_discarded
	Steam.connect("lobby_message", self, "_on_lobby_message")
# warning-ignore:return_value_discarded
	Steam.connect("lobby_data_update", self, "_on_lobby_data_update")
# warning-ignore:return_value_discarded
	Steam.connect("lobby_invite", self, "_on_lobby_invite")
# warning-ignore:return_value_discarded
	Steam.connect("join_requested", self, "_on_lobby_join_requested")
# warning-ignore:return_value_discarded
	Steam.connect("p2p_session_request", self, "_on_p2p_session_request")
# warning-ignore:return_value_discarded
	Steam.connect("p2p_session_connect_fail", self, "_on_p2p_session_connect_fail")
	# Check for command line arguments
	check_Command_Line()


func _on_lobby_created(connect: int, lobby_id: int) -> void:
	if connect == 1:
		Global.lobby_id = lobby_id
		
		print("Created a lobby: " + str(lobby_id))
		host_options.reset_options()
		show()
		server_buttons.show()


func _on_lobby_joined(lobby_id: int, permissions: int, locked: bool, response: int) -> void:
	main.hide()
	join_options.hide()
	host_options.hide()
	show()
	Global.lobby_id = lobby_id
	Global.member_limit = Steam.getLobbyMemberLimit(lobby_id)
	if Global.steam_id == Steam.getLobbyOwner(lobby_id):
		Global.is_lobby_owner = true
		server_buttons.show()
	else:
		Global.is_lobby_owner = false
		client_buttons.show()
	update_lobby_members()


func _on_lobby_join_requested(lobby_id: int, friend_id: int):
	join_lobby(lobby_id)


func _on_lobby_data_update(success: bool, lobby_id: int, member_id: int, key: int) -> void:
	pass


func _on_p2p_session_request(steam_id: int) -> void:
	pass


func _on_lobby_chat_update(lobby_id: int, changed_id: int, making_change_id: int, chat_state: int) -> void:
	var who = Steam.getFriendPersonaName(making_change_id)
	var what: String
	
	match chat_state:
		1:
			what = " joined"
		2:
			what = " left"
		8:
			what = " been kicked"
		16:
			what = " been banned"
		_:
			what = " ???"
	
	var msg = "%s has %s." % [who, what]
	send_chat_message(msg)
	update_lobby_members()


func join_lobby(lobby_id: int) -> void:
	Steam.joinLobby(lobby_id)


func send_chat_message(msg: String, sender_id: int = 0):
	if sender_id != 0:
		msg = Steam.getFriendPersonaName(sender_id) + ": " + msg
	var sent = Steam.sendLobbyChatMsg(Global.lobby_id, msg)
	if not sent:
		print("Error sending chat msg")


func _on_lobby_message(result: bool, sender_id: int, msg: String, type: int) -> void:
	for member in Global.lobby_members:
		if member.steam_id == sender_id and member['muted'] == true:
			return
	chat_print(msg)


func _on_lobby_invite(inviter: int, lobby: int, game: int):
	pass


func chat_print(msg: String) -> void:
	var lbl = Label.new()
	lbl.text = msg
	chat_history.add_child(lbl)


func update_lobby_members() -> void:
	Global.lobby_members.clear()
	for child in member_list.get_children():
		member_list.remove_child(child)
	
	var num_members = Steam.getNumLobbyMembers(Global.lobby_id)
	member_count.text = "Players (%d/%d)" % [num_members, Global.member_limit]
	
	for i in range(0, num_members):
		var member_steam_id = Steam.getLobbyMemberByIndex(Global.lobby_id, i)
		var member_steam_name = Steam.getFriendPersonaName(member_steam_id)
		add_lobby_member(member_steam_id, member_steam_name)


func add_lobby_member(steam_id: int, steam_name: String) -> void:
	Global.lobby_members.append({"steam_id":steam_id, "steam_name":steam_name, "muted":false})
	var member = member_scene.instance()
	member.steam_id = steam_id
	member.get_node("Nameplate").text = steam_name
	member_list.add_child(member)


func check_Command_Line() -> void:
	var args = OS.get_cmdline_args()
	
	# There are arguments to process
	if args.size() > 0:
		
		# Loop through them and get the useful ones
		for arg in args:
			print("Command line: " + str(arg))
			
			# An invite argument was passed
			if lobby_invite_arg:
				join_lobby(int(arg))
				
			# A Steam connection argument exists
			if arg == "+connect_lobby":
				lobby_invite_arg = true


func _on_Leave_pressed() -> void:
	Steam.leaveLobby(Global.lobby_id)
	hide()
	player_char.texture = null
	for child in chat_history.get_children():
		chat_history.remove_child(child)
	main.show()
	for member in Global.lobby_members:
		Steam.closeP2PSessionWithUser(member['steam_id'])
	Global.reset()
	for child in member_list.get_children():
		member_list.remove_child(child)


func _on_Input_text_entered(new_text: String) -> void:
	send_chat_message(new_text)
	chat_input.text = ""
