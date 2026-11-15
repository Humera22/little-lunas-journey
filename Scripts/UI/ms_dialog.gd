extends Control
## Murashige and Skoog solution selection dialog
## Shows 3 options: 1 correct pH+strength, 2 randomised wrong values

signal feeding_complete(correct: bool)

@onready var title_label: Label = $CenterContainer/Panel/VBox/Title
@onready var dialogue_label: Label = $CenterContainer/Panel/VBox/Dialogue
@onready var options_container: VBoxContainer = $CenterContainer/Panel/VBox/OptionsContainer

var _correct_option_index: int = -1


func _ready() -> void:
	hide()


func open_dialog() -> void:
	title_label.text = "Feed the Plant"
	dialogue_label.text = "Select the correct Murashige and Skoog (MS) solution concentration for Arabidopsis Thaliana:"

	# Clear previous buttons
	for child in options_container.get_children():
		options_container.remove_child(child)
		child.queue_free()

	var plant_data = NewClean.get_data()["plant"]
	var correct_ph: float = plant_data["required_ph"]          # 5.7
	var correct_strength: float = plant_data["required_strength_x"]  # 0.125

	# Build 3 options: index 0,1,2 → shuffle to place correct one randomly
	var options := _build_options(correct_ph, correct_strength)
	_correct_option_index = options[0]["correct_index"]

	for i in range(options[0]["choices"].size()):
		var choice = options[0]["choices"][i]
		var btn = Button.new()
		btn.text = choice
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 40)
		btn.pressed.connect(_on_option_pressed.bind(i))
		options_container.add_child(btn)

	show()


func _build_options(correct_ph: float, correct_strength: float) -> Array:
	# Generate 2 wrong values with randomised pH/strength
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var wrong_phs: Array = []
	var wrong_strengths: Array = []

	# Wrong option 1 – higher pH
	wrong_phs.append(snappedf(correct_ph + rng.randf_range(0.5, 2.0), 0.1))
	wrong_strengths.append(snappedf(correct_strength * rng.randf_range(2.0, 4.0), 0.001))

	# Wrong option 2 – lower pH
	wrong_phs.append(snappedf(clampf(correct_ph - rng.randf_range(0.5, 1.5), 3.0, 5.0), 0.1))
	wrong_strengths.append(snappedf(correct_strength * rng.randf_range(0.5, 0.9), 0.001))

	var correct_text = "pH %.1f, %.3f× MS" % [correct_ph, correct_strength]
	var wrong_text_a = "pH %.1f, %.3f× MS" % [wrong_phs[0], wrong_strengths[0]]
	var wrong_text_b = "pH %.1f, %.3f× MS" % [wrong_phs[1], wrong_strengths[1]]

	# Shuffle positions
	var all_choices = [correct_text, wrong_text_a, wrong_text_b]
	var correct_slot = rng.randi_range(0, 2)

	# Swap correct into the chosen slot
	var temp = all_choices[0]
	all_choices[0] = all_choices[correct_slot]
	all_choices[correct_slot] = temp

	return [{"correct_index": correct_slot, "choices": all_choices}]


func _on_option_pressed(index: int) -> void:
	hide()
	var is_correct: bool = (index == _correct_option_index)
	feeding_complete.emit(is_correct)


func _on_body_entered(_body):
	pass
