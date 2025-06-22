extends Control

# time_display.gd
# Attach this script to your "TimeDisplay" Control node.

# Get a reference to the child TimeLabel node.
@onready var time_label: Label = $TimeLabel

var clock_update_timer: Timer

func _ready() -> void:
	# Setup the CLOCK update timer (runs every 1 second)
	clock_update_timer = Timer.new()
	add_child(clock_update_timer) # Add timer as a child of this TimeDisplay node
	clock_update_timer.timeout.connect(update_clock_display)
	clock_update_timer.wait_time = 1.0
	clock_update_timer.start()
	
	# Run once immediately at the start.
	update_clock_display()

func update_clock_display() -> void:
	var datetime = get_current_datetime_wib()
	
	# Format the time into a "HH:MM" string.
	var time_string = "%02d:%02d" % [datetime.hour, datetime.minute]
	
	# Update the label's text property.
	time_label.text = time_string

# Helper function to get the current time in UTC+7
func get_current_datetime_wib() -> Dictionary:
	var time_utc = Time.get_unix_time_from_system()
	var time_wib = time_utc + 25200 # 7 hours in seconds
	return Time.get_datetime_dict_from_unix_time(time_wib)
