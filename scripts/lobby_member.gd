extends Control


onready var mute = get_node("Nameplate/Mute")
onready var kick = get_node("Nameplate/Kick")
onready var ban = get_node("Nameplate/Ban")


var steam_id: int
var muted: bool


func _ready():
	if steam_id == Global.steam_id:
		get_node("Nameplate").disabled = true


func _on_Nameplate_pressed() -> void:
	mute.visible = not mute.visible
	if Global.is_lobby_owner:
		kick.visible = not kick.visible
		ban.visible = not ban.visible


func _on_Mute_toggled(button_pressed: bool) -> void:
	muted = not muted


func _on_Kick_pressed() -> void:
	pass


func _on_Ban_pressed() -> void:
	pass
