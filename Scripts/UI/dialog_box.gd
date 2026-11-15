extends Control

var instructions = [
	"Welcome to the moon simulation Luna!",
	"Your job is to flourish a plant.",
	"If you can successfully do that while staying alive, you will succeed and be selected to go to the moon and actually grow plants there!",
	"Make sure to eat enough calories, drink enough water, and feed the plant every day. Failure to do so will result in a loss of health.",
	"Make sure to check the comms for any updates and news.",
	"Press E to interact with items."
]

var current_instruction = 0

func _ready():
	update_dialog()
	
func update_dialog():
	$Panel/VBoxLayout/Dialog.text = instructions[current_instruction]
	
	$Panel/VBoxLayout/HBoxButtons/PrevButton.disabled = current_instruction == 0
	
	if current_instruction == instructions.size() - 1:
		$Panel/VBoxLayout/HBoxButtons/NextButton.text = "Finish"
	else:
		$Panel/VBoxLayout/HBoxButtons/NextButton.text = "Next"
	
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
