extends Node2D

@export var wind_force: float = 80.0

var player_in_zone = null

func _ready() -> void:
	$Stand.play()
	$Rotator/Blades.play()

func _on_wind_zone_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_zone = body
		
func _on_wind_zone_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_zone.wind_push = Vector2.ZERO
		player_in_zone = null
		
func _physics_process(delta: float) -> void:
	if player_in_zone:
		var direction = Vector2.UP.rotated($Rotator.global_rotation)
		
		var multiplier = 1.0
		
		if not player_in_zone.is_on_floor() and Input.is_action_pressed("ui_accept"):
			multiplier = 2     
		elif player_in_zone.is_on_floor() and Input.is_action_pressed("ui_down"):
			multiplier = 0.6
			
			
		player_in_zone.wind_push = direction * (wind_force * multiplier)
