extends Control

# ---------------------------------------------------------------------------
# HOW TO USE VALUES FROM Data/game_data.gd (NewClean) HERE:
#
#   var food = NewClean.get_data()["food"]
#   var items = food["items"]           # Dictionary of food items
#   var min_cal = food["calories_required_min"]   # 1900
#   var max_cal = food["calories_required_max"]   # 3200
#
#   For each item: items["juice"] -> { "label": "Juice", "calories": 123.6 }
#
# (source: NewClean.get_data()["food"])
# ---------------------------------------------------------------------------

signal food_menu_closed

@onready var calorie_bar: ProgressBar = $Background/VBox/CalorieBarRow/CalorieBar
@onready var calorie_label: Label = $Background/VBox/CalorieBarRow/CalorieLabel
@onready var items_container: VBoxContainer = $Background/VBox/ScrollContainer/ItemsContainer
@onready var back_button: Button = $Background/VBox/BackButton
@onready var title_label: Label = $Background/VBox/TitleLabel

var _calories_eaten: float = 0.0
var _min_calories: float = 1900.0
var _max_calories: float = 3200.0
var _food_items: Dictionary = {}
var _item_buttons: Array = []

func _ready() -> void:
	hide()
	back_button.pressed.connect(_on_back_pressed)

func open_menu(current_calories: float) -> void:
	var food_data = NewClean.get_data()["food"]
	_food_items = food_data["items"]
	_min_calories = food_data["calories_required_min"]
	_max_calories = food_data["calories_required_max"]
	_calories_eaten = current_calories

	calorie_bar.min_value = 0
	calorie_bar.max_value = _max_calories
	calorie_bar.value = _calories_eaten

	_build_item_buttons()
	_update_ui()
	show()

func _build_item_buttons() -> void:
	# Clear old buttons
	for child in items_container.get_children():
		items_container.remove_child(child)
		child.queue_free()
	_item_buttons.clear()

	for key in _food_items:
		var item = _food_items[key]
		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_label = Label.new()
		name_label.text = item["label"]
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.add_theme_font_size_override("font_size", 16)

		var cal_label = Label.new()
		cal_label.text = "%.0f cal" % item["calories"]
		cal_label.custom_minimum_size = Vector2(80, 0)
		cal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

		var btn = Button.new()
		btn.text = "Eat"
		btn.custom_minimum_size = Vector2(70, 32)
		btn.set_meta("item_key", key)
		btn.pressed.connect(_on_eat_item.bind(key))
		_item_buttons.append(btn)

		row.add_child(name_label)
		row.add_child(cal_label)
		row.add_child(btn)
		items_container.add_child(row)

func _on_eat_item(item_key: String) -> void:
	# If bar is full, don't allow eating
	if _calories_eaten >= _max_calories:
		return

	var item = _food_items[item_key]
	var cal = item["calories"]
	_calories_eaten = min(_calories_eaten + cal, _max_calories)

	# Write to game data
	var game = get_tree().get_first_node_in_group("game")
	if game:
		var game_data = game.get_node("GameData")
		game_data.resources["calories_eaten_today"] = _calories_eaten
		# Mark eat_food task complete if we've hit the minimum
		if _calories_eaten >= _min_calories:
			game_data.complete_task("eat_food")

	_update_ui()

func _update_ui() -> void:
	calorie_bar.value = _calories_eaten
	calorie_label.text = "%.0f / %.0f cal" % [_calories_eaten, _max_calories]

	var full = _calories_eaten >= _max_calories
	for btn in _item_buttons:
		btn.disabled = full

	back_button.disabled = false

func _on_back_pressed() -> void:
	hide()
	food_menu_closed.emit()
