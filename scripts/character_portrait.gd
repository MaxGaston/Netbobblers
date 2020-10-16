extends Button


var animal: String

func _ready():
	animal = icon.resource_path.split('.')[0].substr(19)


func _on_CharacterPortrait_pressed() -> void:
	get_parent().set_character(animal)
