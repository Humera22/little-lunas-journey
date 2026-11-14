extends Control

func _on_resume_button_pressed() -> void:
	var game = get_tree().get_first_node_in_group("game")
	game.state_machine.change('play')
	
func _on_select_level_button_pressed() -> void:
	var game = get_tree().get_first_node_in_group("game")
	game.ui.show_screen('level_selector')
