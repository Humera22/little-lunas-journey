extends ConfirmationDialog

signal decision_made(result: bool)


func ask(message: String, title_text: String = "Confirm") -> bool:
	title = title_text
	dialog_text = message

	popup_centered()

	return await decision_made



func _on_confirmed() -> void:
	decision_made.emit(true)

func _on_canceled() -> void:
	decision_made.emit(false)
