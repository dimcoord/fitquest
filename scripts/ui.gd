extends Control

# Notes:
	# 1. Receive from Next js
	# JavaScriptBridge.get_interface("godotApi").change_player_color = Callable(self, "change_player_color")

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
	bmi = snapped($InitializeForm/Weight.value / pow($InitializeForm/Height.value / 100, 2), 0.1)
	var sanitized_name = $InitializeForm/Name.text.replace("'", "\\'").replace("\"", "\\\"")
	JavaScriptBridge.eval("window.initializeData({
		height: '" + str($InitializeForm/Height.value) + "',
		weight: '" + str($InitializeForm/Weight.value) + "',
		calories: '" + str($InitializeForm/Calories.value) + "',
		age: '" + str($InitializeForm/Age.value) + "',
		bmi: '" + str(bmi) + "',
		name: '" + sanitized_name + "',
		 })")
	user_has_character = true
	GameManager.update_character($InitializeForm/Height.value, $InitializeForm/Weight.value, $InitializeForm/Calories.value, $InitializeForm/Age.value, bmi, sanitized_name)
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

# DO NOT TOUCH DO NOT TOUCH DO NOT TOUCH
# I spent forever making this piece of code to work
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
