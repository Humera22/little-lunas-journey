extends Area2D

signal water_consumed

var player_nearby = false

@onready var interact_hint: Label = $InteractHint

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if interact_hint:
		interact_hint.visible = player_nearby

	if Input.is_action_just_pressed("interact") and player_nearby:
		var game = get_tree().get_first_node_in_group("game")
		if not game:
			return

		var game_data = game.get_node("GameData")
		var ui = game.get_node("UI")
		var confirmation = ui.get_node("Confirmation")

		# Already drank today?
		if game_data.resources.get("astronaut_drank_today", false):
			confirmation.ask("You've already had your water ration for today.", "Already Drank")
			return

		var balance = NewClean.get_data()["balance_parameters"]
		var daily_drink = balance["daily_drink"]

		if game_data.resources["water"] < daily_drink:
			confirmation.ask("Not enough water left! (Need %.1f L)" % daily_drink, "No Water")
			return

		# Ask the player
		# meow
		# (source: NewClean.get_data()["balance_parameters"]["daily_drink"])
		var confirmed = await confirmation.ask(
			"Do you want to drink %.1f liters of water?" % daily_drink,
			"Drink Water"
		)
		if confirmed:
			game_data.resources["water"] -= daily_drink
			game_data.resources["astronaut_drank_today"] = true
			water_consumed.emit()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
