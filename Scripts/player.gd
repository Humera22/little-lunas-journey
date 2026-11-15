extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# How close (in pixels) to the edge before switching scenes
const EDGE_THRESHOLD = 20.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Track whether we've already applied storm damage this day
var _storm_damage_applied_day: int = -1

# Interactable nodes inside the base (disabled when outside)
const INSIDE_INTERACTABLES := [
	"InsideNode/DayContent/Bed",
	"InsideNode/DayContent/Communicator",
	"InsideNode/DayContent/WaterStation",
]

# Interactable nodes outside (disabled when inside)
const OUTSIDE_INTERACTABLES := [
	"OutsideNode/Plant",
]


func _ready() -> void:
	add_to_group("player")
	# Player always starts inside — disable outside interactables immediately
	await get_tree().process_frame
	var world = get_parent()
	if world:
		_set_outside_interactables_enabled(world, false)


func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal movement
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Animate
	if animated_sprite:
		if abs(velocity.x) > 10:
			animated_sprite.play("walk")
			animated_sprite.flip_h = velocity.x < 0
		else:
			animated_sprite.play("still")

	# Scene edge switching
	_check_edge_switch()


func _check_edge_switch() -> void:
	var viewport_width = get_viewport_rect().size.x
	var world = get_parent()
	if not world:
		return

	var inside = world.get_node_or_null("InsideNode")
	var outside = world.get_node_or_null("OutsideNode")
	if not inside or not outside:
		return

	# If Inside is visible and player walks off the right edge → switch to Outside
	if inside.visible and global_position.x > viewport_width - EDGE_THRESHOLD:
		inside.hide()
		outside.show()
		# Place player at the left edge
		global_position.x = EDGE_THRESHOLD + 10
		velocity.x = 0

		_set_inside_interactables_enabled(world, false)
		_set_outside_interactables_enabled(world, true)

		# Apply solar storm health damage if it's Day 4
		_on_went_outside()

	# If Outside is visible and player walks off the left edge → switch to Inside
	elif outside.visible and global_position.x < EDGE_THRESHOLD:
		outside.hide()
		inside.show()
		# Place player at the right edge
		global_position.x = viewport_width - EDGE_THRESHOLD - 10
		velocity.x = 0

		_set_outside_interactables_enabled(world, false)
		_set_inside_interactables_enabled(world, true)


func _on_went_outside() -> void:
	var game = get_tree().get_first_node_in_group("game")
	if not game:
		return

	var level_manager = game.get_node_or_null("LevelManager")
	if not level_manager:
		return

	var game_data = game.get_node_or_null("GameData")
	if not game_data:
		return

	# Only apply once per day
	var current_day = game_data.current_day
	if _storm_damage_applied_day == current_day:
		return
	_storm_damage_applied_day = current_day

	# Going outside counts as exercise for the day
	game_data.resources["exercise_done"] = true
	print("Player went outside — exercise_done set to true for day %d." % (current_day + 1))

	level_manager.apply_storm_damage_if_day4()


# ─────────────────────── Interactable enable / disable ───────────────────────

func _set_inside_interactables_enabled(world: Node, enabled: bool) -> void:
	for path in INSIDE_INTERACTABLES:
		var node = world.get_node_or_null(path)
		if node is Area2D:
			node.monitoring = enabled
			node.monitorable = enabled
			node.set_process(enabled)
			# Clear the nearby flag so the hint hides immediately
			if not enabled and node.has_method("_clear_nearby"):
				node._clear_nearby()
			elif not enabled and "player_nearby" in node:
				node.player_nearby = false


func _set_outside_interactables_enabled(world: Node, enabled: bool) -> void:
	for path in OUTSIDE_INTERACTABLES:
		var node = world.get_node_or_null(path)
		if node is Area2D:
			node.monitoring = enabled
			node.monitorable = enabled
			node.set_process(enabled)
			if not enabled and "player_nearby" in node:
				node.player_nearby = false
