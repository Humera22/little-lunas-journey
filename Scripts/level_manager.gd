
extends Node

@onready var game_data = get_parent().get_node("GameData")
@onready var day_content: Node = get_node("../World/InsideNode/DayContent")


func start_first_day(starting_resources: Dictionary):
	print("Starting first day")

	game_data.resources = starting_resources.duplicate(true)
	game_data.current_day = 0
	game_data.day_snapshots.clear()

	game_data.create_snapshot(0)

	day_content.setup_day(DayEvents.DAYS[0])

	print(game_data.resources)


func advance_day():
	if game_data.current_day < DayEvents.DAYS.size() - 1:
		game_data.current_day += 1

		game_data.create_snapshot(game_data.current_day)

		day_content.setup_day(
			DayEvents.DAYS[game_data.current_day]
		)
	else:
		print("Game completed!")


func rewind_to_day(day: int):
	if not game_data.day_snapshots.has(day):
		print("Level locked.")
		return

	game_data.load_snapshot(day)
	game_data.current_day = day

	for saved_day in game_data.day_snapshots.keys():
		if saved_day > day:
			game_data.day_snapshots.erase(saved_day)

	day_content.setup_day(DayEvents.DAYS[day])
