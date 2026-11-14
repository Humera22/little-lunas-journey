class_name PlayState
extends BaseState

func enter(params = null) -> void:
	context.get_tree().paused = false
	context.ui.show_screen('hud')
	context.world.show()
	connect_gameplay_signals()

func exit() -> void:
	print("Leaving gameplay")

func update(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		pause()

func pause() -> void:
	context.state_machine.change('pause')


func connect_gameplay_signals():
	# Communicator
	var communicator = context.world.get_node("InsideNode/DayContent/Communicator")
	var choice_dialog = context.ui.get_node("ChoicesDialog")

	if communicator and not communicator.interacted.is_connected(_on_communicator_interacted):
		communicator.interacted.connect(_on_communicator_interacted)

	if choice_dialog and not choice_dialog.choice_selected.is_connected(_on_choice_selected):
		choice_dialog.choice_selected.connect(_on_choice_selected)

	if choice_dialog and not choice_dialog.news_closed.is_connected(_on_news_closed):
		choice_dialog.news_closed.connect(_on_news_closed)

	# Water station
	var water_station = context.world.get_node_or_null("InsideNode/DayContent/WaterStation")
	if water_station and not water_station.water_consumed.is_connected(_on_water_consumed):
		water_station.water_consumed.connect(_on_water_consumed)

	# Food menu
	var food_menu = context.ui.get_node_or_null("FoodMenu")
	if food_menu and not food_menu.food_menu_closed.is_connected(_on_food_menu_closed):
		food_menu.food_menu_closed.connect(_on_food_menu_closed)


func _on_communicator_interacted():
	var day_content = context.world.get_node("InsideNode/DayContent")
	if day_content.event_handled:
		return

	var event_data = day_content.get_current_event()
	if event_data.is_empty():
		return

	var choice_dialog = context.ui.get_node("ChoicesDialog")
	if choice_dialog:
		choice_dialog.show_event(event_data)


func _on_choice_selected(choice_id: String):
	print("Player selected: ", choice_id)

	var day_content = context.world.get_node("InsideNode/DayContent")
	day_content.mark_event_handled()

	var game_data = context.level_manager.game_data
	game_data.complete_task("check_comms")

	if game_data.resources.has("choices_made"):
		game_data.resources["choices_made"].append({
			"day": game_data.current_day + 1,
			"choice_id": choice_id
		})

	# --- HOW TO ADD CHOICE EFFECTS ---
	# Add a match block here to apply resource changes based on choice_id.
	# Example:
	#   match choice_id:
	#       "choice_a":
	#           game_data.resources["water"] -= 2.0
	#       "choice_b":
	#           game_data.resources["power"] += 10.0


func _on_news_closed():
	print("Player finished reading the news.")
	var day_content = context.world.get_node("InsideNode/DayContent")
	day_content.mark_event_handled()

	var game_data = context.level_manager.game_data
	game_data.complete_task("check_comms")


func _on_water_consumed():
	print("Astronaut drank water.")
	var game_data = context.level_manager.game_data
	game_data.complete_task("drink_water")


func _on_food_menu_closed():
	# Check if we've hit the minimum calories and mark the task complete
	var game_data = context.level_manager.game_data
	var min_cal = NewClean.get_data()["food"]["calories_required_min"]
	if game_data.resources.get("calories_eaten_today", 0.0) >= min_cal:
		game_data.complete_task("eat_food")
