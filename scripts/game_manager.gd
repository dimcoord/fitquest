extends Node

var user_logged_in: bool = true
var character_data: Dictionary = {}

func update_character(new_height: float, new_weight: float, new_calories: float, new_age: int, new_bmi: float, new_name: String):
	character_data['height'] = new_height
	character_data['weight'] = new_weight
	character_data['calories'] = new_calories
	character_data['age'] = new_age
	character_data['bmi'] = new_bmi
	character_data['name'] = new_name
	character_data['calories_burned'] = 10
	for item in character_data.keys():
		print(item, ': ', character_data[item])
