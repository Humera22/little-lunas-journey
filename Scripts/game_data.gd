extends Node
var current_day = 0

var resources = {}

var day_snapshots = {}

# Daily task tracking - reset each day
var tasks_completed = {
	"drink_water": false,
	"eat_food": false,
	"feed_plant": false,
	"check_comms": false,
}

func reset_daily_tasks():
	tasks_completed = {
		"drink_water": false,
		"eat_food": false,
		"feed_plant": false,
		"check_comms": false,
	}

func complete_task(task_name: String):
	if tasks_completed.has(task_name):
		tasks_completed[task_name] = true

func get_incomplete_tasks() -> Array:
	var incomplete = []
	var labels = {
		"drink_water": "Drink Water",
		"eat_food": "Eat Food",
		"feed_plant": "Feed Plant",
		"check_comms": "Check Comms",
	}
	for task in tasks_completed:
		if not tasks_completed[task]:
			incomplete.append(labels.get(task, task))
	return incomplete

func create_snapshot(day):
	day_snapshots[day] = resources.duplicate(true)

func load_snapshot(day):
	if day_snapshots.has(day):
		resources = day_snapshots[day].duplicate(true)
