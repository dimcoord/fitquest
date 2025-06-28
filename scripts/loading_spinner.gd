# LoadingSpinner.gd
extends Control

# How fast the spinner rotates (in degrees per second)
@export var rotation_speed: float = 200.0

@onready var texture_rect = $ColorRect

# _process is called every frame
func _process(delta):
	# Rotate the TextureRect node.
	# 'delta' is the time elapsed since the last frame.
	# This makes the rotation speed independent of the frame rate.
	texture_rect.rotation_degrees += rotation_speed * delta
