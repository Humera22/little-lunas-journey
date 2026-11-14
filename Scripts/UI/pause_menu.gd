extends Control
@onready var game = get_node('../..')

func _on_resume_button_pressed() -> void:
	game.state_machine.change('play')
	
func _on_select_level_button_pressed() -> void:
	game.ui.show_screen('level_selector')
