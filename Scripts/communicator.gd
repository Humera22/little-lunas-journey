extends Area2D

signal interacted

var player_nearby = false

@onready var interact_hint: Label = $InteractHint

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if interact_hint:
		interact_hint.visible = player_nearby

	if Input.is_action_just_pressed("interact") and player_nearby:
		interacted.emit()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
