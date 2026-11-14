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


func _ready():
	print("Oxygen: ", oxygen)
	print("Water: ", water)
	print("Power: ", power)
	print("Plant Health: ", p_health)
	print("Astronaut Health: ", a_health)
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


func _on_pause_button_pressed() -> void:
	game.state_machine.change('pause')
