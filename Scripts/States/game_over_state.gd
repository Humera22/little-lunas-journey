class_name GameOverState
extends BaseState


func enter(params = null) -> void:
	context.ui.show_screen("game_over")
	print("Game Over")


func exit() -> void:
	pass


func update(delta: float) -> void:
	pass
