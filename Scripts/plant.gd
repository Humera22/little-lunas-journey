extends Area2D
## Plant interaction script – handles Murashige and Skoog solution feeding
## Correct values come from NewClean (Data/game_data.gd)

var player_nearby: bool = false

@onready var interact_hint: Label = $InteractHint


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if interact_hint:
		interact_hint.visible = player_nearby

	if Input.is_action_just_pressed("interact") and player_nearby:
		_on_interact()


func _on_interact() -> void:
	var game = get_tree().get_first_node_in_group("game")
	if not game:
		return

	var game_data = game.get_node("GameData")
	var ui = game.get_node("UI")

	# Already fed today?
	if game_data.tasks_completed.get("feed_plant", false):
		var confirmation = ui.get_node("Confirmation")
		confirmation.ask("You've already fed the plant today.", "Plant")
		return

	# Check water
	var plant_data = NewClean.get_data()["plant"]
	var water_needed: float = plant_data["daily_water_requirement"]

	if game_data.resources["water"] < water_needed:
		var confirmation = ui.get_node("Confirmation")
		confirmation.ask("Not enough water to feed the plant! (Need %.2f L)" % water_needed, "No Water")
		return

	# Open the MS solution selection dialog
	var ms_dialog = ui.get_node_or_null("MSDialog")
	if ms_dialog:
		ms_dialog.open_dialog()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
