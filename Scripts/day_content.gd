extends Node2D

var current_day_data: Dictionary = {}
var event_handled: bool = false
var day_summary: Dictionary = {}


func setup_day(day_data: Dictionary, summary: Dictionary = {}):
	current_day_data = day_data.duplicate(true)
	day_summary = summary.duplicate(true)
	event_handled = false

	# Inject the day summary into the dialogue if we have one
	if not day_summary.is_empty():
		var summary_text = _build_summary_text(day_summary)
		current_day_data["dialogue"] = summary_text + "\n\n" + current_day_data.get("dialogue", "")

	# Show the day indicator on the communicator when a new day starts
	var indicator = get_node_or_null("Communicator/DayIndicator")
	if indicator:
		indicator.show()


func get_current_event() -> Dictionary:
	return current_day_data.duplicate(true)


func mark_event_handled():
	event_handled = true


func _build_summary_text(summary: Dictionary) -> String:
	var lines = []
	# Oxygen summary
	var oxy_lost = summary.get("oxygen_lost", 0)
	var exercised = summary.get("exercise_done", false)
	if exercised:
		lines.append("Yesterday you exercised. Oxygen consumed: %d grams." % oxy_lost)
	else:
		lines.append("No exercise yesterday. Oxygen consumed: %d grams." % oxy_lost)

	# Water summary
	if not summary.get("drank_water", true):
		lines.append("⚠ You didn't drink water yesterday! Health has dropped.")

	# Food summary
	var calories = summary.get("calories_eaten", 0.0)
	var min_cal = NewClean.get_data()["food"]["calories_required_min"]
	if calories < min_cal:
		lines.append("⚠ You didn't eat enough yesterday (%.0f / %d cal). Health has dropped." % [calories, min_cal])

	return "\n".join(lines)
