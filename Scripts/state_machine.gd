extends Node
class_name StateMachine

var states: Dictionary = {}
var current: BaseState
var context: Node

func initialize(_context:Node, _states: Dictionary = {}) -> void:
	context = _context
	states = _states
	current = BaseState.new(_context)
	
func change(state_name: String, enter_params = null) -> void:
	assert(states.has(state_name), "State doesn't exist: " + state_name)
	
	current.exit()
	current = states[state_name].new(context)
	current.enter(enter_params)

func update(delta: float) -> void:
	current.update(delta)
