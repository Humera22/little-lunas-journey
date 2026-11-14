class_name PauseState
extends BaseState


func enter(params = null) -> void:
	context.get_tree().paused = true
	context.ui.show_screen('pause_menu')
	print("Game paused")


func exit() -> void:
	context.get_tree().paused = false
	print("Game unpaused")


func update(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		context.state_machine.change('play')
