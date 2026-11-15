extends RefCounted
class_name DayEvents

# ---------------------------------------------------------------
# HOW TO USE VALUES FROM Data/game_data.gd (NewClean) HERE:
#
# Since DAYS is a const array, you can't call functions in it directly.
# Instead, build your dialogue strings at runtime in day_content.gd
# or play_state.gd using NewClean like this:
#
#   var balance = NewClean.get_data()["balance_parameters"]
#   var oxy = balance["oxy_day"]        # 820 grams
#   var noex = balance["noex_oxy_day"]  # 720 grams
#   var drink = balance["daily_drink"]  # 2.5 liters
#
#   var food = NewClean.get_data()["food"]
#   var min_cal = food["calories_required_min"]  # 1900
#
#   var plant = NewClean.get_data()["plant"]
#   var water_req = plant["daily_water_requirement"]  # 0.5 liters
#
# Then you can inject these into dialogue strings:
#   dialogue_label.text = "You used %d grams of oxygen today." % oxy
#
# The day_content.gd setup_day() function already does this for the
# oxygen deduction summary shown at the start of each day.
# ---------------------------------------------------------------

const DAYS = [
	{
		"day": 1,
		"type": "news",
		"title": "Mission Start",
		"dialogue": "Welcome to the lunar outpost. Your mission: keep yourself and the plant alive for 5 days. Manage your oxygen, water, power, and health. Check the communicator each day for updates.",
		"choices": []
	},
	{
		"day": 2,
		"type": "news",
		"title": "Plant Care Reminder",
		"dialogue": "Good morning, Luna! Don't forget to tend to the Arabidopsis Thaliana today. It needs the correct Murashige and Skoog (MS) solution. Interact with the plant to feed it.",
		"choices": []
	},
	{
		"day": 3,
		"type": "choice",
		"title": "Solar Panel Maintenance",
		"dialogue": "Luna, the solar panels are showing reduced efficiency — lunar dust is building up on the surface. Do you want to go outside and clean them today?",
		"choices": [
			{
				"id": "clean_panels",
				"text": "Go outside and clean the solar panels"
			},
			{
				"id": "skip_cleaning",
				"text": "Skip cleaning for now"
			}
		]
	},
	{
		"day": 4,
		"type": "news",
		"title": "Solar Storm Warning",
		"dialogue": "STORM_WARNING_PLACEHOLDER",
		"choices": []
	},
	{
		"day": 5,
		"type": "news",
		"title": "Mission Complete",
		"dialogue": "MISSION_RESULT_PLACEHOLDER",
		"choices": []
	}
]
