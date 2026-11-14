class_name MainMenuState
extends BaseState


func enter(params = null) -> void:
	context.world.hide()
	context.ui.show_screen('main_menu')


func exit() -> void:
	pass


func update(delta: float) -> void:
	pass
