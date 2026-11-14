
extends Control

signal choice_selected(choice_id: String)
signal news_closed

@onready var title_label = $Panel/Title
@onready var dialogue_label = $Panel/Dialogue
@onready var choices_container = $Panel/ChoicesContainer
@onready var continue_button = $Panel/ContinueButton


func _ready():
	hide()
	continue_button.pressed.connect(_on_continue_pressed)


func show_event(event_data: Dictionary):
	title_label.text = event_data.get("title", "")
	dialogue_label.text = event_data.get("dialogue", "")

	# Remove buttons from the previous event.
	for child in choices_container.get_children():
		choices_container.remove_child(child)
		child.queue_free()

	var event_type = event_data.get("type", "choice")

	if event_type == "news":
		continue_button.show()
	else:
		continue_button.hide()

		var choices = event_data.get("choices", [])

		for choice in choices:
			var button = Button.new()
			button.text = choice.get("text", "")
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

			button.pressed.connect(
				_on_choice_pressed.bind(choice.get("id", ""))
			)

			choices_container.add_child(button)

	show()


func _on_choice_pressed(choice_id: String):
	hide()
	choice_selected.emit(choice_id)


func _on_continue_pressed():
	hide()
	news_closed.emit()
