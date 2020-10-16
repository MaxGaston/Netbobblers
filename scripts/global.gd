extends Node


var is_online: bool
var steam_id: int
var steam_name: String
var is_owned: bool

var lobby_id: int
var lobby_members: Array
var member_limit: int
var is_lobby_owner: bool

func _ready():
	var result = Steam.steamInit()
	print("Did Steam initialize?: " + str(result))
	
	if result['status'] != 1:
		print("Failed to initialize Steam. " + str(result['verbal']) + " Shutting down...")
		get_tree().quit()
	
	is_online = Steam.loggedOn()
	steam_id = Steam.getSteamID()
	steam_name = Steam.getPersonaName()
	is_owned = Steam.isSubscribed()


# warning-ignore:unused_argument
func _process(delta: float) -> void:
	Steam.run_callbacks()


func reset() -> void:
	lobby_id = 0
	lobby_members.clear()
	member_limit = 0
	is_lobby_owner = false
