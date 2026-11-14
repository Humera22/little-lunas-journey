
extends RefCounted
class_name StateMachine


var states: Dictionary = {}
var current: BaseState


func _init(state_list: Dictionary = {}) -> void:
	states = state_list
	current = BaseState.new()


func change(state_name: String, enter_params = null) -> void:
	assert(states.has(state_name), "State does not exist: " + state_name)

	current.exit()

	current = states[state_name].new()

	current.enter(enter_params)


func update(delta: float) -> void:
	current.update(delta)
