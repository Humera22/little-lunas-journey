
extends Node

@onready var game_data = get_parent().get_node("GameData")
@onready var day_content: Node = get_node("../World/InsideNode/DayContent")


func start_first_day(starting_resources: Dictionary):
	print("Starting first day")

	game_data.resources = starting_resources.duplicate(true)
	game_data.current_day = 0
	game_data.day_snapshots.clear()
	game_data.reset_daily_tasks()

	game_data.create_snapshot(0)

	day_content.setup_day(DayEvents.DAYS[0])

	print(game_data.resources)


func advance_day():
	if game_data.current_day < DayEvents.DAYS.size() - 1:
		# --- Apply end-of-day penalties before advancing ---
		var balance = NewClean.get_data()["balance_parameters"]
		var food_data = NewClean.get_data()["food"]

		# Oxygen deduction
		var oxy_loss: float
		if game_data.resources.get("exercise_done", false):
			oxy_loss = balance["oxy_day"]
		else:
			oxy_loss = balance["noex_oxy_day"]
		game_data.resources["oxygen"] = max(0, game_data.resources["oxygen"] - oxy_loss)

		# Health penalty if astronaut didn't drink water
		if not game_data.resources.get("astronaut_drank_today", false):
			game_data.resources["astronaut_health"] = max(0,
				game_data.resources["astronaut_health"] - balance["astronaut_failed_health"])

		# Health penalty if astronaut didn't eat enough
		var min_calories = food_data["calories_required_min"]
		var eaten = game_data.resources.get("calories_eaten_today", 0.0)
		if eaten < min_calories:
			game_data.resources["astronaut_health"] = max(0,
				game_data.resources["astronaut_health"] - balance["astronaut_failed_health"])

		# Plant health penalty if the plant was NOT fed today
		if not game_data.tasks_completed.get("feed_plant", false):
			var health_loss: float = balance["health_loss_if_not_watered"]
			game_data.resources["plant_health"] = maxf(0.0,
				game_data.resources["plant_health"] - health_loss)
			print("Plant was not fed today! Health -%.1f" % health_loss)

		# --- Daily solar panel dirty deduction ---
		# If solar_panels_clean is FALSE the panels are dusty → lose power each day
		if not game_data.resources.get("solar_panels_clean", true):
			var dusty_loss: float = balance["daily_solar_dusty"]
			game_data.resources["power"] = maxf(0.0,
				game_data.resources["power"] - dusty_loss)
			print("Dirty solar panels! Power -%.1f" % dusty_loss)

		# --- Daily solar-panel radiation damage deduction ---
		if game_data.resources.get("solar_panels_damaged", false):
			var damage_loss: float = balance["daily_solar_damaged"]
			game_data.resources["power"] = maxf(0.0,
				game_data.resources["power"] - damage_loss)
			print("Damaged solar panels! Power -%.1f" % damage_loss)

		# Store the oxygen loss for the day summary
		var day_summary = {
			"oxygen_lost": oxy_loss,
			"exercise_done": game_data.resources.get("exercise_done", false),
			"drank_water": game_data.resources.get("astronaut_drank_today", false),
			"calories_eaten": eaten,
		}

		# Reset daily flags for the new day
		game_data.resources["astronaut_drank_today"] = false
		game_data.resources["exercise_done"] = false
		game_data.resources["calories_eaten_today"] = 0.0
		game_data.reset_daily_tasks()

		# Advance
		game_data.current_day += 1
		game_data.create_snapshot(game_data.current_day)

		# --- Day 4: pick solar storm, inject warning into comms dialogue ---
		var next_day_number = game_data.current_day + 1  # 1-based
		var day_data = DayEvents.DAYS[game_data.current_day].duplicate(true)

		if next_day_number == 4:
			day_data = _prepare_day4(day_data)
		elif next_day_number == 5:
			day_data = _prepare_day5(day_data)

		day_content.setup_day(day_data, day_summary)

		# Check power warning after day transitions
		_check_power_warning()
	else:
		print("Game completed!")


# ─────────────────────────── Day 4 – Solar Storm ──────────────────────────────

func _prepare_day4(day_data: Dictionary) -> Dictionary:
	# Randomly pick a solar storm event and store flux + severity
	var storm = NewClean.get_random_solar_storm()
	var s_scale: String = storm.get("noaa_s_scale", "S1").strip_edges()
	var flux: float = storm.get("peak_flux_pfu", 0.0)

	# Calculate severity (numeric 1-5 from s_scale)
	var severity: int = _s_scale_to_int(s_scale)

	game_data.resources["flux"] = flux
	game_data.resources["severity"] = severity

	print("Day 4 storm: %s (flux=%.1f, severity=%d)" % [s_scale, flux, severity])

	# Build the warning message
	var warning_msg: String
	match s_scale:
		"S1", "S2":
			warning_msg = "Luna! There's a storm brewing outside. Going out right now is low risk. Please stay inside today."
		"S3":
			warning_msg = "Luna! There's a storm brewing outside. Going out right now is highly risky! Please stay inside today."
		"S4", "S5":
			warning_msg = "Luna! There's a storm brewing outside. Going out right now is extremely risky! Please stay inside and protect yourself!"
		_:
			warning_msg = "Luna! There's a storm brewing outside. Please stay inside today."

	warning_msg += "\n\nResources: Events by NASA DONKI | Peak flux (%.0f pfu) by NOAA Solar Proton Events Catalogue | Scale (%s) by NOAA Space Weather Scales" % [flux, s_scale]

	day_data["dialogue"] = warning_msg
	return day_data


func _s_scale_to_int(s_scale: String) -> int:
	match s_scale:
		"S1": return 1
		"S2": return 2
		"S3": return 3
		"S4": return 4
		"S5": return 5
	return 1


# ─────────────────────────── Day 5 – Mission Result ───────────────────────────

func _prepare_day5(day_data: Dictionary) -> Dictionary:
	var plant_health: float = game_data.resources.get("plant_health", 100.0)
	var astro_health: float = game_data.resources.get("astronaut_health", 100.0)

	var failed_msg: String = ""

	if plant_health <= 0.0 and astro_health <= 0.0:
		failed_msg = "Mission Failed: Both the plant and Luna didn't survive the mission."
	elif plant_health <= 0.0:
		failed_msg = "Mission Failed: The Arabidopsis Thaliana plant didn't survive the mission."
	elif astro_health <= 0.0:
		failed_msg = "Mission Failed: Luna didn't survive the mission."

	if not failed_msg.is_empty():
		day_data["title"] = "Mission Failed"
		day_data["dialogue"] = failed_msg
	else:
		day_data["title"] = "Mission Complete"
		day_data["dialogue"] = "Congratulations! You've survived 5 days on the lunar outpost. The resupply shuttle is on its way."

	return day_data


# ─────────────────────────── Astronaut goes outside on Day 4 ─────────────────

## Call this from player.gd (or wherever the outside transition happens)
## when it's day 4 and a solar storm is active.
func apply_storm_damage_if_day4() -> void:
	var current_day_number = game_data.current_day + 1  # 1-based
	if current_day_number != 4:
		return

	var severity: int = game_data.resources.get("severity", 0)
	if severity == 0:
		return  # No storm loaded yet

	var balance = NewClean.get_data()["balance_parameters"]
	var health_loss: float = balance["astronaut_health_loss_if_unshielded"]
	game_data.resources["astronaut_health"] = maxf(0.0,
		game_data.resources["astronaut_health"] - health_loss)

	print("Storm damage applied! Astronaut health -%.1f" % health_loss)


# ─────────────────────────── Power warning ───────────────────────────────────

func _check_power_warning() -> void:
	var power: float = game_data.resources.get("power", 100.0)
	var threshold: float = NewClean.get_data()["balance_parameters"].get("power_comp_threshold", 50.0)

	if power < threshold:
		_show_power_warning(power)


func _show_power_warning(power: float) -> void:
	var ui = get_node_or_null("../UI")
	if not ui:
		# Try via game group
		var game = get_tree().get_first_node_in_group("game")
		if game:
			ui = game.get_node_or_null("UI")
	if not ui:
		return

	# Use the existing ChoicesDialog as a news-type popup for the warning
	var choice_dialog = ui.get_node_or_null("ChoicesDialog")
	if choice_dialog:
		choice_dialog.show_event({
			"type": "news",
			"title": "⚠ Low Power Warning",
			"dialogue": "Warning! Power is critically low (%.0f units). Systems may begin to fail. Conserve power immediately!" % power,
			"choices": []
		})


# ─────────────────────────── rewind ──────────────────────────────────────────

func rewind_to_day(day: int):
	if not game_data.day_snapshots.has(day):
		print("Level locked.")
		return

	game_data.load_snapshot(day)
	game_data.current_day = day
	game_data.reset_daily_tasks()

	for saved_day in game_data.day_snapshots.keys():
		if saved_day > day:
			game_data.day_snapshots.erase(saved_day)

	day_content.setup_day(DayEvents.DAYS[day])
