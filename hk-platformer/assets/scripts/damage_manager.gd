extends Node2D

@onready var player_controller: CharacterBody2D = $"../PlayerController"
@onready var pixel_level: Node2D = $"../PixelLevel"


func _ready() -> void:
	for enemy in pixel_level.get_node("Enemies").get_children():
		enemy.hurt_signal.connect(_on_hurt_signal.bind(enemy))
	

func _on_hurt_signal(enemy: CharacterBody2D):
	print("enemy touché")
	enemy.current_health -= player_controller.attack_damage
	if enemy.current_health <= 0:
		enemy.queue_free()
	

func _process(delta: float) -> void:
	pass
