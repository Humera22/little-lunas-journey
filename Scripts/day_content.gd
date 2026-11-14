extends Node2D

var current_day_data: Dictionary = {}
var event_handled: bool = false


func setup_day(day_data: Dictionary):
	current_day_data = day_data.duplicate(true)
	event_handled = false
	# Show the day indicator on the communicator when a new day starts
	var indicator = get_node_or_null("Communicator/DayIndicator")
	if indicator:
		indicator.show()


func get_current_event() -> Dictionary:
	return current_day_data.duplicate(true)


func mark_event_handled():
	event_handled = true
