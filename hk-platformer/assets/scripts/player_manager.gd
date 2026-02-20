class_name PlayerManager
extends Node2D

@onready var player: CharacterBody2D = $"../PlayerController"

var player_damage = 40
var player_life = 100
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.takeDamageSignal.connect(damage_player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func damage_player(damage):
	player_life -= damage
	if player_life <= 0:
		pass
