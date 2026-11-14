extends ItemList
@onready var game = get_node('../..')
@onready var game_data = $"../../GameData"
@onready var confirmation = $"../Confirmation"

func _on_item_activated(index: int) -> void:
	if index == 6:
		game.ui.show_screen("pause_menu")
		hide()
	else:
		if await confirmation.ask("Do you really want to restart from level " + str(index+1) + "?"):
			game.level_manager.rewind_to_day(index)
			game.state_machine.change("play")
			game.ui.show_screen("hud")
			hide()

func _on_visibility_changed() -> void:
	for i in range(get_item_count()):
		if i in game_data.day_snapshots:
			print(i)
			set_item_disabled(i, false)
			set_item_selectable(i, true)
