extends Control

signal replay_requested
signal quit_requested

@onready var title_label: Label = $CenterContainer/Panel/VBoxLayout/Title
@onready var dialogue_label: Label = $CenterContainer/Panel/VBoxLayout/Dialogue
@onready var replay_button: Button = $CenterContainer/Panel/VBoxLayout/ButtonRow/ReplayButton
@onready var quit_button: Button = $CenterContainer/Panel/VBoxLayout/ButtonRow/QuitButton


func _ready():
	hide()
	replay_button.pressed.connect(_on_replay_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func show_conclusion(title: String, message: String):
	title_label.text = title
	dialogue_label.text = message
	show()


func _on_replay_pressed():
	hide()
	replay_requested.emit()


func _on_quit_pressed():
	quit_requested.emit()
