class_name NewClean
extends RefCounted

const GAME := {
	"title": "idfk",
	"duration_days": 5,
	"description": "Keep the astronaut and the outpost plant alive by managing water, electrical power, oxygen, and heat.",
	"units": {
		"power": "power_units",
		"oxygen": "grams",
		"water": "liters",
		"plant_health": "0_to_100",
		"astronaut_hydration": "0_to_100",
		"astronaut_health": "0_to_100",
	}
}
const INITIAL_STATE := {
	"power": 100.0,
	"oxygen": 3500,
	"water": 15.0,
	"astronaut_hydration": 100.0,
	"plant_health": 100.0,
	"astronaut_drank_today": false,
	"exercise_done": false,
	"calories_eaten_today": 0.0,
	"solar_panels_clean": true,
	"astronaut_health": 100.0,
	"nutrient_ph": null,
	"nutrient_ph_wrong": false,
	"solar_panels_damaged": false,
	"choices_made": [],
}
const FOOD := {
	"calories_required_min": 1900,
	"calories_required_max": 3200,
	"meals_per_day": 3,
	"snacks_per_day": 1,
	"items": {
		"juice": {"label": "Juice", "calories": 123.6},
		"scrambled_eggs": {"label": "Scrambled eggs", "calories": 183},
		"tortillas": {"label": "Tortillas", "calories": 189},
		"shrimp_cocktail": {"label": "Shrimp cocktail", "calories": 117.95},
		"carrots": {"label": "Carrots", "calories": 42.5},
		"dried_apricots": {"label": "Dried apricots", "calories": 156},
		"beef_steak": {"label": "Beef steak", "calories": 208},
		"chocolate_pudding": {"label": "Chocolate pudding", "calories": 124},
	},
}
const BALANCE_PARAMETERS := {
	# MINIMUM liters per day
	"daily_drink": 2.5,
	#"astro_hydr_loss": 25.0,
	#"hydration_recovery": 25.0,
	#"eds_cost": 5.0,
	# oxygen per kg per day per astronaut + exercise
	"oxy_day": 820,
	# oxygen per day no exercise
	"noex_oxy_day": 720,
	#power deducted when panels are dusty on day 3 continuously til cleaned
	"daily_solar_dusty": 10.0,
	"power_comp_threshold": 50, #if power reaches 50 issue a warning 
  #power deducted when solar panels are effected by radiation storm
	"daily_solar_damaged": 15.0, #power deducted til panels replaced
	"astronaut_death_hydration_threshold": 0.0, #if the user clicks on sleeping pod while hydration is 0 then critical
	"astronaut_death_oxygen_threshold": 0.0,
	"plant_death_health_threshold": 0.0,
	"health_loss_if_not_watered": 25.0,
	"health_recovery_when_watered": 10.0,
	"wrong_ph_penalty": 15.0,
	"astronaut_health_loss_if_unshielded": 25.0,
	"plant_health_loss_if_unshielded": 25.0,
	"astronaut_failed_health": 40.0,
	"plant_failed_health": 40.0,
}
const PLANT_DATA := {
	"description": "Arabidopsis Thaliana",
	"initial_growth_stage": "seed",
	"daily_water_requirement": 0.5,
	"nutrient_solution": "Murashige and Skoog (MS)",
	"required_ph": 5.7,
	"required_strength_x": 0.125,
}
const SOLAR_STORM_EVENTS := [
{
	"date": "2011-08-04",
		"peak_flux_pfu": 96.0,
		"noaa_s_scale": "S1",
		"noaa_start_utc": "2011-08-04T06:35:00",
		"noaa_peak_time_utc": "2011-08-05T21:50:00",
		"donki_event_time_utc": "2011-08-04T05:10:00",
		"donki_sep_id": "2011-08-04T05:10:00-SEP-001"
	},
	{
		"date": "2012-03-07",
		"peak_flux_pfu": 6530.0,
   		 "noaa_s_scale": "S3",
		"noaa_start_utc": "2012-03-07T05:10:00",
		"noaa_peak_time_utc": "2012-03-08T11:15:00",
		"donki_event_time_utc": "2012-03-07T05:00:00",
		"donki_sep_id": "2012-03-07T05:00:00-SEP-001"
	},
	{
		"date": "2012-01-27",
		"peak_flux_pfu": 796.0,
		"noaa_s_scale": "S2",
		"noaa_start_utc": "2012-01-27T19:05:00",
		"noaa_peak_time_utc": "2012-01-28T02:05:00",
		"donki_event_time_utc": "2012-01-27T19:00:00",
		"donki_sep_id": "2012-01-27T19:00:00-SEP-001"
	}]

const DATA := {
	"game": GAME,
	"initial_state": INITIAL_STATE,
	"balance_parameters": BALANCE_PARAMETERS,
	"plant": PLANT_DATA,
	"food": FOOD,
	"solar_storm_events": SOLAR_STORM_EVENTS,
}



static func get_data() -> Dictionary:
	return DATA.duplicate(true)


static func get_initial_state() -> Dictionary:
	return INITIAL_STATE.duplicate(true)

static func get_random_solar_storm() -> Dictionary:
	var events: Array = DATA["solar_storm_events"]
	return events.pick_random().duplicate(true)
 
