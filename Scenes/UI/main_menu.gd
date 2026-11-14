extends Control
@onready var game = get_node('../..')


func _on_play_button_pressed() -> void:
	game.state_machine.change('play')
	game.level_manager.start_first_day(game_data.get_initial_state())
