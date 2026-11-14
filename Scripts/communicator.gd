extends Area2D
@onready var level_manager: Node = $LevelManager
@onready var confirmation: ConfirmationDialog = $Confirmation

signal interacted

var player_nearby = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_released("interact") and player_nearby:
		interacted.emit()

func _on_body_entered(body: Node2D) -> void:
	player_nearby = true

func _on_body_exited(body: Node2D) -> void:
	player_nearby = false
