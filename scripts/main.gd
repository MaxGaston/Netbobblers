extends Node2D


onready var join_options: Panel = get_parent().get_node("JoinOptions")
onready var host_options: Panel = get_parent().get_node("HostOptions")


func _ready():
	pass


func _on_Join_pressed() -> void:
	join_options.show()


func _on_Host_pressed() -> void:
	host_options.show()


func _on_Settings_pressed() -> void:
	pass # Replace with function body.


func _on_Quit_pressed() -> void:
	get_tree().quit()
