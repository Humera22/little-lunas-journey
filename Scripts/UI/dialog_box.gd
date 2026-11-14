extends Control

var instructions = [
	"Welcome to the outpost!",
	"Keep an eye on your resources.",
	"Make choices carefully. Each day presents different challenges.",
    "Good luck!"
]

var current_instruction = 0

func _ready():
	update_dialog()
	
func update_dialog():
	$Panel/Dialog.text = instructions[current_instruction]
	
	$Panel/PrevButton.disabled = current_instruction == 0
	
	if current_instruction == instructions.size() - 1:
		$Panel/NextButton.text = "Finish"
	else:
		$Panel/NextButton.text = "Next"
	
func next_instruction():
	if current_instruction < instructions.size() - 1:
		current_instruction += 1
		update_dialog()
	else:
		skip_instructions()


func previous_instruction():
	if current_instruction > 0:
		current_instruction -= 1
		update_dialog()


func skip_instructions():
	hide()

func _on_next_button_pressed() -> void:
	next_instruction()


func _on_prev_button_pressed() -> void:
	previous_instruction()


func _on_skip_button_pressed() -> void:
	skip_instructions()
