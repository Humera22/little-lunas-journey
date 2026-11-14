extends Control


func _on_play_button_pressed() -> void:
	var game = get_tree().get_first_node_in_group("game")
	game.state_machine.change('play')
	game.level_manager.start_first_day(NewClean.get_initial_state())
