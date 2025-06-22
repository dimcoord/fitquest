extends Node2D

@onready var bg_node: Control = $Background
@onready var crate_node: ColorRect = $Crates
@onready var player_bmi = 1
@onready var player_exp = 0

func _ready():
	if player_bmi > 40:
		bg_node.position = Vector2(0, -2700)
	elif player_bmi > 35:
		bg_node.position = Vector2(0, -2000)
	elif player_bmi > 30:
		bg_node.position = Vector2(0, -1300)
	elif player_bmi > 25:
		bg_node.position = Vector2(0, -600)
