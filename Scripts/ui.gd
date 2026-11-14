extends CanvasLayer

@onready var main_menu = $MainMenu
@onready var hud = $HUD
@onready var pause_menu = $PauseMenu
@onready var game_over = $GameOver
@onready var level_selector = $LevelsSelector
@onready var choices_dialog = $ChoicesDialog



func show_screen(screen_name: String) -> void:
	main_menu.hide()
	hud.hide()
	pause_menu.hide()
	game_over.hide()
	
	match screen_name:
		'main_menu':
			main_menu.show()
		'hud':
			hud.show()
		'pause_menu':
			hud.show()
			pause_menu.show()
		'game_over':
			game_over.show()
		'level_selector':
			level_selector.show()
	
