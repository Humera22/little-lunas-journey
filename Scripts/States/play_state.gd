class_name PlayState
extends BaseState

func enter(params = null) -> void:
	context.get_tree().paused = false
	context.ui.show_screen('hud')
	connect_gameplay_signals()
	
func exit() -> void:
	print("Leaving gameplay")

func update(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		pause()
	
func pause() -> void:
	context.state_machine.change('pause')
	

func connect_gameplay_signals():
	var communicator = context.world.get_node("DayContent/Communicator")
	var choice_dialog = context.ui.get_node("ChoiceDialog")

	if not communicator.interacted.is_connected(_on_communicator_interacted):
		communicator.interacted.connect(_on_communicator_interacted)

	if not choice_dialog.choice_selected.is_connected(_on_choice_selected):
		choice_dialog.choice_selected.connect(_on_choice_selected)

	if not choice_dialog.news_closed.is_connected(_on_news_closed):
		choice_dialog.news_closed.connect(_on_news_closed)


func _on_communicator_interacted():
	var event_data = context.level_manager.day_content.get_current_event()

	var choice_dialog = context.ui.get_node("ChoiceDialog")
	choice_dialog.show_event(event_data)


func _on_choice_selected(choice_id: String):
	print("Player selected: ", choice_id)

	var game_data = context.level_manager.game_data

	if game_data.resources.has("choices_made"):
		game_data.resources["choices_made"].append({
			"day": game_data.current_day + 1,
			"choice_id": choice_id
		})


func _on_news_closed():
	print("Player finished reading the news.")
