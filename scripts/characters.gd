extends GridContainer


onready var player_sprite: Sprite = get_parent().get_node("Portrait/Sprite")


func _ready():
	pass


func set_character(animal: String) -> void:
	var path_round = "res://assets/round/%s.png" % animal
	var path_square = "res://assets/square/%s.png" % animal
	player_sprite.texture = load(path_round)
