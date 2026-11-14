extends Node2D

@onready var state_machine = $GameStateMachine
@onready var level_manager = $LevelManager
@onready var world = $World
@onready var ui = $UI
@onready var player_needs = $Systems/PlayerNeeds


func _ready() -> void:
	state_machine.initialize(self, {
		'play' : PlayState,
		'pause' : PauseState,
		'game_over': GameOverState,
		'main_menu': MainMenuState
	})
	
	state_machine.change('main_menu')
	
func _process(delta: float) -> void:
	state_machine.update(delta)
