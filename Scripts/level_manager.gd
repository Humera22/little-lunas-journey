
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

		day_content.setup_day(DayEvents.DAYS[game_data.current_day], day_summary)
	else:
		print("Game completed!")


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
