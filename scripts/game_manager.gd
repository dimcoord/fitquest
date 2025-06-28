extends Node

var user_logged_in: bool = true
var character_data: Dictionary = {}
var short_char_data: Dictionary = {}

func update_character(new_height: float, new_weight: float, new_calories: float, new_age: int, new_bmi: float, new_name: String):
	character_data['height'] = new_height
	character_data['weight'] = new_weight
	character_data['calories'] = new_calories
	character_data['age'] = new_age
	character_data['bmi'] = new_bmi
	character_data['name'] = new_name
	character_data['calories_burned'] = 0
	short_char_data['bmi'] = new_bmi
	short_char_data['height'] = new_height
	short_char_data['weight'] = new_weight
	short_char_data['age'] = new_age
	#for item in character_data.keys():
		#print(item, ': ', character_data[item])
