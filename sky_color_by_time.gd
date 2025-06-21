extends Control

# Get a reference to the child ColorRect node.
@onready var color_rect: ColorRect = $ColorRect

var sky_material: ShaderMaterial
var sky_update_timer: Timer

func _ready() -> void:
	# Get the shader material from the ColorRect
	if color_rect and color_rect.material is ShaderMaterial:
		sky_material = color_rect.material as ShaderMaterial
	else:
		print("Error: Background node could not find ShaderMaterial on its child ColorRect.")
		return

	# Setup the SKY update timer (runs every 60 seconds)
	sky_update_timer = Timer.new()
	add_child(sky_update_timer) # Add timer as a child of this Background node
	sky_update_timer.timeout.connect(update_sky_color)
	sky_update_timer.wait_time = 60.0
	sky_update_timer.start()
	
	# Run once immediately at the start.
	update_sky_color()

func update_sky_color() -> void:
	var datetime = get_current_datetime_wib()
	var current_hour: int = datetime.hour

	var target_color: Color
	if current_hour >= 20 or current_hour < 4:
		target_color = Color("#210B2C") # Night
	elif current_hour < 5:
		target_color = Color("#5E3318") # Dawn
	elif current_hour < 7:
		target_color = Color("#F48C42") # Sunrise
	elif current_hour < 13:
		target_color = Color("#87CEEB") # Noon
	elif current_hour < 17:
		target_color = Color("#FFD700") # Afternoon
	else:
		target_color = Color("#F48C42") # Sunset

	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sky_material, "shader_parameter/bottom_color", target_color, 5.0)
	print("Sky color updated for hour: %d" % current_hour)

# Helper function to get the current time in UTC+7
func get_current_datetime_wib() -> Dictionary:
	var time_utc = Time.get_unix_time_from_system()
	var time_wib = time_utc + 25200 # 7 hours in seconds
	return Time.get_datetime_dict_from_unix_time(time_wib)
