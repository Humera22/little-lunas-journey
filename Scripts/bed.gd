extends Area2D

var player_nearby = false

@onready var interact_hint: Label = $InteractHint

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if interact_hint:
		interact_hint.visible = player_nearby

	if Input.is_action_just_pressed("interact") and player_nearby:
		# Get LevelManager from the scene tree root
		var game = get_tree().get_first_node_in_group("game")
		if game:
			var level_manager = game.get_node("LevelManager")
			var ui = game.get_node("UI")
			var confirmation = ui.get_node("Confirmation")
			if await confirmation.ask("Do you want to sleep and advance to the next day?", "Sleep"):
				level_manager.advance_day()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
