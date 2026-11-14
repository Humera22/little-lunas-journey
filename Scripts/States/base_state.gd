class_name BaseState
extends RefCounted

var context: Node

func _init(_context: Node):
	context = _context

func enter(params = null) -> void:
	pass

func exit() -> void:
	pass

func update(delta: float) -> void:
	pass
