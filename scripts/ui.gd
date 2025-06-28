extends Control

@onready var user_has_character: bool = false
@onready var bmi = 18.5
var clock_update_timer: Timer

func _ready() -> void:
	clock_time()
	control_bmi_label()
	control_motivation_label()

func _on_texture_button_pressed() -> void:
	$TextureButton.visible = false
	$InitializeForm.visible = true

func _on_ok_button_pressed() -> void:
	$InitializeForm.visible = false
	user_has_character = true
	pass_initial_data()
	control_motivation_label()
	control_bmi_label()
	control_buttons(false)

func _on_cancel_button_pressed() -> void:
	if user_has_character:
		control_buttons(false)
		$TextureButton.visible = false
	else:
		$TextureButton.visible = true
	$InitializeForm.visible = false
	$QuestsForm.visible = false
	$StatsForm.visible = false

func _on_quests_button_pressed() -> void:
	control_buttons(true)
	$QuestsForm.visible = true

func _on_stats_button_pressed() -> void:
	control_buttons(true)
	$StatsForm.visible = true
	$StatsForm/Name.text = str(GameManager.character_data['name'])
	$StatsForm/Height/Value.text = str(GameManager.character_data['height'])
	$StatsForm/Weight/Value.text = str(GameManager.character_data['weight'])
	$StatsForm/Age/Value.text = str(GameManager.character_data['age'])
	$StatsForm/CaloriesBurned/Value.text = str(GameManager.character_data['calories_burned'])

func control_buttons(hide_all: bool) -> void:
	if user_has_character:
		$QuestsButton.visible = true
		$StatsButton.visible = true
		$TextureButton.visible = false
	if hide_all:
		$QuestsButton.visible = false
		$StatsButton.visible = false

func control_motivation_label() -> void:
	if user_has_character:
		$MotivationLabel.position = Vector2(146, 342)
		$MotivationLabel.text = 'Keep it up!'
	else:
		$MotivationLabel.position = Vector2(146, 250)
		$MotivationLabel.text = '❤️FitQuest'
		
func control_bmi_label() -> void:
	if user_has_character:
		$BMILabel.visible = true
		$BMILabel.text = str(bmi)
	else:
		$BMILabel.visible = false
		$BMILabel.text = str(bmi)

func pass_initial_data() -> void:
	bmi = snapped($InitializeForm/Weight.value / pow($InitializeForm/Height.value / 100, 2), 0.1)
	var sanitized_name = $InitializeForm/Name.text.replace("'", "\\'").replace("\"", "\\\"")
	GameManager.update_character($InitializeForm/Height.value, $InitializeForm/Weight.value, $InitializeForm/Calories.value, $InitializeForm/Age.value, bmi, sanitized_name)
	var req_body = JSON.stringify(GameManager.short_char_data)
	var headers = ["Content-Type: application/json"]
	var api_url = 'http://localhost:3000/api/recommendations'
	var error = $HTTPRequest.request(api_url, headers, HTTPClient.METHOD_POST, req_body)
	if error != OK:
		print("An error occurred trying to make the request.")

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	$QuestsForm/LoadingSpinner.visible = false
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		$QuestsForm/LoadingSpinner.visible = false
		$QuestsForm/ErrorLabel.visible = true
		$QuestsForm/ErrorLabel.text = "Error!"
		print("Network error or server error. Status code: %s" % response_code)
		return
	# The response body from our Next.js server is already clean JSON
	var response_body_string = body.get_string_from_utf8()
	var response_json = JSON.parse_string(response_body_string)
	if response_json == null:
		print("Failed to parse the server response.")
		return
	# We can use the JSON directly, no need for a second parse
	if typeof(response_json) == TYPE_DICTIONARY:
		var titles = response_json.get("title", [])
		var descriptions = response_json.get("description", [])
		var durations = response_json.get("duration", [])
		var calories = response_json.get("calories", [])
		var button_title = [$QuestsForm/Selections/SelectButton1/Title, $QuestsForm/Selections/SelectButton2/Title, $QuestsForm/Selections/SelectButton3/Title]
		var button_description = [$QuestsForm/Selections/SelectButton1/Description, $QuestsForm/Selections/SelectButton2/Description, $QuestsForm/Selections/SelectButton3/Description]
		var button_duration = [$QuestsForm/Selections/SelectButton1/Duration, $QuestsForm/Selections/SelectButton2/Duration, $QuestsForm/Selections/SelectButton3/Duration]
		var button_calories = [$QuestsForm/Selections/SelectButton1/Calories, $QuestsForm/Selections/SelectButton2/Calories, $QuestsForm/Selections/SelectButton3/Calories]
		var count = min(titles.size(), descriptions.size(), durations.size(), calories.size())
		for i in count:
			button_title[i].text = titles[i]
			button_description[i].text = descriptions[i]
			button_duration[i].text = durations[i]
			button_calories[i].text = calories[i]
		$QuestsForm/Selections.visible = true

# DO NOT TOUCH DO NOT TOUCH DO NOT TOUCH
# DO NOT TOUCH DO NOT TOUCH DO NOT TOUCH
func update_clock_display() -> void:
	var datetime = get_current_datetime_wib()
	# Format the time into a "HH:MM" string.
	var time_string = "%02d:%02d" % [datetime.hour, datetime.minute]
	$TimeLabel.text = time_string # Update the label's text property.

func clock_time() -> void:
	# Setup the CLOCK update timer (runs every 1 second)
	clock_update_timer = Timer.new()
	add_child(clock_update_timer) # Add timer as a child of this TimeDisplay node
	clock_update_timer.timeout.connect(update_clock_display)
	clock_update_timer.wait_time = 1.0
	clock_update_timer.start()
	update_clock_display() # Run once immediately at the start.

# Helper function to get the current time in UTC+7
func get_current_datetime_wib() -> Dictionary:
	var time_utc = Time.get_unix_time_from_system()
	var time_wib = time_utc + 25200 # 7 hours in seconds
	return Time.get_datetime_dict_from_unix_time(time_wib)


# LEGACY CODE
#func pass_initial_data() -> void:
	#bmi = snapped($InitializeForm/Weight.value / pow($InitializeForm/Height.value / 100, 2), 0.1)
	#var sanitized_name = $InitializeForm/Name.text.replace("'", "\\'").replace("\"", "\\\"")
	#JavaScriptBridge.eval("window.initializeData({
		#height: '" + str($InitializeForm/Height.value) + "',
		#weight: '" + str($InitializeForm/Weight.value) + "',
		#calories: '" + str($InitializeForm/Calories.value) + "',
		#age: '" + str($InitializeForm/Age.value) + "',
		#bmi: '" + str(bmi) + "',
		#name: '" + sanitized_name + "',
		 #})")
	#var js_object = "{"
	#js_object += "bmi: '" + str(bmi) + "', "
	#js_object += "age: '" + str($InitializeForm/Age.value) + "', "
	#js_object += "sex: '" + 'Male' + "'"
	#js_object += "}"
	#var js_command = "window.getAiRecommendations(" + js_object + ")"
	#JavaScriptBridge.eval(js_command)
	#GameManager.update_character($InitializeForm/Height.value, $InitializeForm/Weight.value, $InitializeForm/Calories.value, $InitializeForm/Age.value, bmi, sanitized_name)
