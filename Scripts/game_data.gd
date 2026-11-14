extends Node
var current_day = 0

var resources = {}

var day_snapshots = {}

func create_snapshot(day):
	day_snapshots[day] = resources.duplicate(true)

func load_snapshot(day):
	if day_snapshots.has(day):
		resources = day_snapshots[day].duplicate(true)
