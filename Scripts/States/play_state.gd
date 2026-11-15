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

	# MS dialog
	var ms_dialog = context.ui.get_node_or_null("MSDialog")
	if ms_dialog and ms_dialog.has_signal("feeding_complete") and not ms_dialog.feeding_complete.is_connected(_on_ms_feeding_complete):
		ms_dialog.feeding_complete.connect(_on_ms_feeding_complete)


# ─────────────────────────────── communicator ────────────────────────────────

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

	# Day-specific choice handling
	var current_day = game_data.current_day + 1  # 1-based

	match current_day:
		3:
			_handle_day3_choice(choice_id, game_data)
		_:
			pass


func _handle_day3_choice(choice_id: String, game_data) -> void:
	# choice_id "clean_panels" = player cleans; "skip_cleaning" = player skips
	if choice_id == "skip_cleaning":
		# Mark panels as dirty (not clean) so daily power deduction kicks in
		game_data.resources["solar_panels_clean"] = false
		print("Day 3: Player skipped cleaning. Solar panels are now dirty.")
	elif choice_id == "clean_panels":
		game_data.resources["solar_panels_clean"] = true
		print("Day 3: Player cleaned the solar panels.")


func _on_news_closed():
	print("Player finished reading the news.")
	var day_content = context.world.get_node("InsideNode/DayContent")
	day_content.mark_event_handled()

	var game_data = context.level_manager.game_data
	game_data.complete_task("check_comms")


# ─────────────────────────────── water ───────────────────────────────────────

func _on_water_consumed():
	print("Astronaut drank water.")
	var game_data = context.level_manager.game_data
	game_data.complete_task("drink_water")


# ─────────────────────────────── food ────────────────────────────────────────

func _on_food_menu_closed():
	var game_data = context.level_manager.game_data
	var min_cal = NewClean.get_data()["food"]["calories_required_min"]
	if game_data.resources.get("calories_eaten_today", 0.0) >= min_cal:
		game_data.complete_task("eat_food")


# ─────────────────────────────── plant ───────────────────────────────────────

func _on_ms_feeding_complete(correct: bool):
	var game_data = context.level_manager.game_data
	var plant_data = NewClean.get_data()["plant"]
	var balance = NewClean.get_data()["balance_parameters"]

	if correct:
		# Correct MS solution
		game_data.resources["nutrient_ph"] = plant_data["required_ph"]
		game_data.resources["nutrient_ph_wrong"] = false
		# Small health recovery for correct feeding
		var recovery = balance.get("health_recovery_when_watered", 0.0)
		game_data.resources["plant_health"] = minf(100.0,
			game_data.resources["plant_health"] + recovery)
		print("Plant fed correctly!")
		_show_ms_feedback(true, plant_data["required_ph"], plant_data["required_strength_x"])
	else:
		# Wrong MS solution – apply penalty
		var penalty: float = balance["wrong_ph_penalty"]
		game_data.resources["plant_health"] = maxf(0.0,
			game_data.resources["plant_health"] - penalty)
		game_data.resources["nutrient_ph_wrong"] = true
		print("Wrong MS solution! Plant health penalty: -%.1f" % penalty)
		_show_ms_feedback(false, plant_data["required_ph"], plant_data["required_strength_x"])

	game_data.complete_task("feed_plant")


func _show_ms_feedback(correct: bool, correct_ph: float, correct_strength: float) -> void:
	var choice_dialog = context.ui.get_node_or_null("ChoicesDialog")
	if not choice_dialog:
		return

	var title: String
	var message: String

	if correct:
		title = "✓ Correct Solution!"
		message = "Great work, Luna! pH %.1f at %.3f× MS is exactly what Arabidopsis Thaliana needs. The plant looks healthier already." % [correct_ph, correct_strength]
	else:
		title = "✗ Wrong Solution!"
		message = "That wasn't right. The correct Murashige and Skoog solution for Arabidopsis Thaliana is pH %.1f at %.3f× MS. The plant's health has decreased." % [correct_ph, correct_strength]

	choice_dialog.show_event({
		"type": "news",
		"title": title,
		"dialogue": message,
		"choices": []
	})
