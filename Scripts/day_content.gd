extends Node2D

var current_day_data: Dictionary = {}


func setup_day(day_data: Dictionary):
	current_day_data = day_data.duplicate(true)


func get_current_event() -> Dictionary:
	return current_day_data.duplicate(true)
