extends Control

@onready var game = get_node('../..')
@onready var oxygen: ProgressBar = $CenterContainer/ResourceBars/OxygenRow/Oxygen
@onready var oxygen_label: Label = $CenterContainer/ResourceBars/OxygenRow/OxygenLabel
@onready var water: ProgressBar = $CenterContainer/ResourceBars/WaterRow/Water
@onready var water_label: Label = $CenterContainer/ResourceBars/WaterRow/WaterLabel
@onready var power: ProgressBar = $CenterContainer/ResourceBars/PowerRow/Power
@onready var power_label: Label = $CenterContainer/ResourceBars/PowerRow/PowerLabel
@onready var p_health: ProgressBar = $CenterContainer/ResourceBars/PHealthRow/PHealth
@onready var p_health_label: Label = $CenterContainer/ResourceBars/PHealthRow/PHealthLabel
@onready var a_health: ProgressBar = $CenterContainer/ResourceBars/AHealthRow/AHealth
@onready var a_health_label: Label = $CenterContainer/ResourceBars/AHealthRow/AHealthLabel
@onready var units = NewClean.get_data()["game"]["units"]
@onready var level_manager = $"../../LevelManager"
@onready var next_level_button = $NextLevelButton
@onready var day_label: Label = $DayLabel

# Checklist references
@onready var task_drink: Label = $Checklist/ChecklistVBox/TaskDrink
@onready var task_eat: Label = $Checklist/ChecklistVBox/TaskEat
@onready var task_plant: Label = $Checklist/ChecklistVBox/TaskPlant
@onready var task_comms: Label = $Checklist/ChecklistVBox/TaskComms


func _ready():
	set_resource_max_values()


func set_resource_max_values():
	var initial_resources = NewClean.get_initial_state()
	oxygen.max_value = initial_resources["oxygen"]
	water.max_value = initial_resources["water"]
	power.max_value = initial_resources["power"]
	p_health.max_value = initial_resources["plant_health"]
	a_health.max_value = initial_resources["astronaut_health"]

func _process(_delta):
	update_resource_bars()
	update_checklist()
	update_day_label()

func update_resource_bars():
	var resources = game.level_manager.game_data.resources
	if resources.is_empty():
		return
	oxygen.value = resources["oxygen"]
	water.value = resources["water"]
	power.value = resources["power"]
	p_health.value = resources["plant_health"]
	a_health.value = resources["astronaut_health"]

	oxygen_label.text = str(resources["oxygen"]) + " " + str(units['oxygen'])
	water_label.text = str(resources["water"]) + " " + str(units['water'])
	power_label.text = str(resources["power"]) + " " + str(units['power'])
	p_health_label.text = str(resources["plant_health"]) + " " + str(units['plant_health'])
	a_health_label.text = str(resources["astronaut_health"]) + " " + str(units['astronaut_health'])


func update_checklist():
	var game_data = game.level_manager.game_data
	if not game_data:
		return
	var tasks = game_data.tasks_completed

	_set_task_label(task_drink, "Drink Water", tasks.get("drink_water", false))
	_set_task_label(task_eat, "Eat Food", tasks.get("eat_food", false))
	_set_task_label(task_plant, "Feed Plant", tasks.get("feed_plant", false))
	_set_task_label(task_comms, "Check Comms", tasks.get("check_comms", false))


func _set_task_label(label: Label, task_name: String, completed: bool):
	if not label:
		return
	if completed:
		label.text = "✓ " + task_name
		label.modulate = Color(0.5, 1.0, 0.5, 0.6)
	else:
		label.text = "○ " + task_name
		label.modulate = Color(1.0, 1.0, 1.0, 1.0)


func update_day_label():
	if day_label:
		var current_day = game.level_manager.game_data.current_day
		day_label.text = "Day " + str(current_day + 1)


func _on_pause_button_pressed() -> void:
	game.state_machine.change('pause')


func _on_eat_button_pressed() -> void:
	var game = get_tree().get_first_node_in_group("game")
	if not game:
		return
	var game_data = game.level_manager.game_data
	var food_menu = game.ui.get_node("FoodMenu")
	if food_menu:
		food_menu.open_menu(game_data.resources.get("calories_eaten_today", 0.0))
