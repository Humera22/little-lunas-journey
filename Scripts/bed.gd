extends Area2D

var player_nearby = false

@onready var interact_hint: Label = $InteractHint

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if interact_hint:
		interact_hint.visible = player_nearby

	if Input.is_action_just_pressed("interact") and player_nearby:
		var game = get_tree().get_first_node_in_group("game")
		if game:
			var level_manager = game.get_node("LevelManager")
			var ui = game.get_node("UI")
			var confirmation = ui.get_node("Confirmation")
			var game_data = game.get_node("GameData")

			# Check for incomplete tasks and build warning
			var incomplete = game_data.get_incomplete_tasks()
			var message = ""
			if incomplete.size() > 0:
				var warnings = ""
				for task in incomplete:
					warnings += "⚠ " + task + " hasn't been completed!\n"
				message = warnings + "\nDo you still want to sleep and advance to the next day?"
			else:
				message = "All tasks completed! Do you want to sleep and advance to the next day?"

			if await confirmation.ask(message, "Sleep"):
				# Apply health penalty for incomplete tasks that matter
				if not game_data.tasks_completed.get("drink_water", false):
					# Health drop handled in level_manager.advance_day()
					pass
				level_manager.advance_day()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
