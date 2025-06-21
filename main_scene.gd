extends Node2D

@onready var bg_node: Control = $Background
@onready var player_level = 1

func _ready():
	if player_level == 1:
		bg_node.position = Vector2(0, -1800)
