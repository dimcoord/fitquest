extends Control

# background_controller.gd
# Attach this script to your "Background" Control node.

# Get a reference to the child ColorRect node.
@onready var color_rect: ColorRect = $ColorRect

# --- NEW: Reference to the TextureRect we want to sync ---
@export var synced_texture_rect: TextureRect

var sky_material: ShaderMaterial
var sky_update_timer: Timer

func _ready() -> void:
	if color_rect and color_rect.material is ShaderMaterial:
		sky_material = color_rect.material as ShaderMaterial
	else:
		print("Error: Background node could not find ShaderMaterial on its child ColorRect.")
		return

	sky_update_timer = Timer.new()
	add_child(sky_update_timer)
	sky_update_timer.timeout.connect(update_sky_color)
	sky_update_timer.wait_time = 60.0
	sky_update_timer.start()
	
	update_sky_color()

func update_sky_color() -> void:
	var datetime = get_current_datetime_wib()
	var current_hour: int = datetime.hour
	var target_modulate_color = Color(1, 1, 1)


	var target_color: Color
	if current_hour >= 20 or current_hour < 4:
		target_color = Color("#210B2C") # Night
		target_modulate_color = Color(0.5, 0.5, 0.5)
	elif current_hour < 5:
		target_color = Color("#5E3318") # Dawn
		target_modulate_color = Color(0.5, 0.5, 0.5)
	elif current_hour < 7:
		target_color = Color("#F48C42") # Sunrise
		target_modulate_color = Color(0.7, 0.7, 0.7)
	elif current_hour < 13:
		target_color = Color("#87CEEB") # Noon
	elif current_hour < 17:
		target_color = Color("#FFD700") # Afternoon
	else:
		target_color = Color("#F48C42") # Sunset
		target_modulate_color = Color(0.7, 0.7, 0.7)

	# Create a single tween to handle both animations
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	
	# Animate the sky shader's color (This part stays the same)
	tween.tween_property(sky_material, "shader_parameter/bottom_color", target_color, 5.0)

	# --- MODIFIED LOGIC: Animate the TextureRect's BRIGHTNESS ---
	if is_instance_valid(synced_texture_rect):
		# 3. Animate the 'modulate' property to this new grey color.
		tween.tween_property(synced_texture_rect, "modulate", target_modulate_color, 5.0)
		print("Sky and synced texture updated for hour: %d" % current_hour)

# Helper function to get the current time in UTC+7
func get_current_datetime_wib() -> Dictionary:
	var time_utc = Time.get_unix_time_from_system()
	var time_wib = time_utc + 25200 # 7 hours in seconds
	return Time.get_datetime_dict_from_unix_time(time_wib)
