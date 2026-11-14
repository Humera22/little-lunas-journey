extends ItemList

func _get_game():
	return get_tree().get_first_node_in_group("game")

func _on_item_activated(index: int) -> void:
	var game = _get_game()
	if not game:
		return
	var game_data = game.get_node("GameData")
	var confirmation = get_parent().get_node("Confirmation")

	# Last item is the back button
	if index == get_item_count() - 1:
		game.ui.show_screen("pause_menu")
	else:
		if not game_data.day_snapshots.has(index):
			return  # Level is locked
		if await confirmation.ask("Do you really want to restart from level " + str(index + 1) + "?"):
			game.level_manager.rewind_to_day(index)
			game.state_machine.change("play")
			game.ui.show_screen("hud")

func _on_visibility_changed() -> void:
	if not visible:
		return
	var game = _get_game()
	if not game:
		return
	var game_data = game.get_node("GameData")
	for i in range(get_item_count() - 1):  # Skip the back button
		if game_data.day_snapshots.has(i):
			set_item_disabled(i, false)
			set_item_selectable(i, true)
		else:
			set_item_disabled(i, true)
			set_item_selectable(i, false)
