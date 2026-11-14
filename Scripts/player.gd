extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# How close (in pixels) to the edge before switching scenes
const EDGE_THRESHOLD = 20.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("player")


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

	var inside = world.get_node_or_null("Inside")
	var outside = world.get_node_or_null("Outside")
	if not inside or not outside:
		return

	# If Inside is visible and player walks off the right edge → switch to Outside
	if inside.visible and global_position.x > viewport_width - EDGE_THRESHOLD:
		inside.hide()
		outside.show()
		# Place player at the left edge
		global_position.x = EDGE_THRESHOLD + 10
		velocity.x = 0

	# If Outside is visible and player walks off the left edge → switch to Inside
	elif outside.visible and global_position.x < EDGE_THRESHOLD:
		outside.hide()
		inside.show()
		# Place player at the right edge
		global_position.x = viewport_width - EDGE_THRESHOLD - 10
		velocity.x = 0
