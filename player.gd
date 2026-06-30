extends CharacterBody2D

const SPEED = 300.0
const CROUCH_SPEED = 230.0
const JUMP_VELOCITY = -1200.0
const FLOAT_GRAVITY_MULTIPLIER = 0.2
const MAX_FLOAT_FALL_SPEED = 250.0

const WALL_SLIDE_SPEED = 150.0 
const WALL_JUMP_VERTICAL = -650.0
const WALL_JUMP_HORIZONTAL = 400.0

var wind_push := Vector2.ZERO
var was_in_air := false
var was_on_wall := false 
var wall_jump_lock := 0.0

var wall_coyote_timer := 0.0
var last_wall_normal := Vector2.ZERO

var floor_coyote_timer := 0.0

@onready var hoogte_label = $"../CanvasLayer/HeightLabel"

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	
	var wall_normal := Vector2.ZERO
	
	# ---- Coyote timer voor vloer ----
	if is_on_floor():
		floor_coyote_timer = 0.15
	else:
		if floor_coyote_timer > 0:
			floor_coyote_timer -= delta
	
	# ---- 0. Muur-detectie & subtiele Squish tegen de muur ----
	if is_on_wall():
		if not was_on_wall and not is_on_floor():
			$AnimatedSprite2D.scale = Vector2(0.93, 1.07) 
		
		wall_normal = get_wall_normal()
		last_wall_normal = wall_normal
		wall_coyote_timer = 0.2
	else:
		if wall_coyote_timer > 0:
			wall_coyote_timer -= delta
	
	var is_wall_sliding: bool = is_on_wall() and not is_on_floor() \
		and direction != 0 and sign(direction) != sign(wall_normal.x)

	if wall_jump_lock >  0:
		wall_jump_lock -= delta

	# ---- 1. Zwaartekracht en zweven ----
	if not is_on_floor():
		if is_wall_sliding:
			if velocity.y < WALL_SLIDE_SPEED:
				velocity += get_gravity() * delta * 3
			else:
				velocity.y = WALL_SLIDE_SPEED
		elif Input.is_action_pressed("ui_accept") and velocity.y > 0:
			velocity += (get_gravity() * FLOAT_GRAVITY_MULTIPLIER) * delta
			velocity.y = clampf(velocity.y, -INF, MAX_FLOAT_FALL_SPEED)
		else:
			velocity += get_gravity() * delta

	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y *= 0.5

	# ---- 2. Landings-detectie & subtiele Landing Squish ----
	if is_on_floor() and was_in_air:
		$LandingTimer.start(0.15)
		$AnimatedSprite2D.scale = Vector2(1.12 + velocity.y * 0.002  , 0.88)
		
	was_in_air = not is_on_floor()
	was_on_wall = is_on_wall()

	# ---- 3. Springen & subtiele Jump Stretch ----
	if Input.is_action_just_pressed("ui_accept") and wall_coyote_timer > 0 and not is_on_floor():
		velocity.y = WALL_JUMP_VERTICAL
		velocity.x = last_wall_normal.x * WALL_JUMP_HORIZONTAL * 1.3
		wall_jump_lock = 0.1
		wall_coyote_timer = 0.0
		$LandingTimer.stop()
		$AnimatedSprite2D.scale = Vector2(0.92, 1.08)
		
	elif Input.is_action_just_pressed("ui_accept") and floor_coyote_timer > 0 and not Input.is_action_pressed("ui_down"):
		velocity.y = JUMP_VELOCITY
		floor_coyote_timer = 0.0
		$LandingTimer.stop()
		$AnimatedSprite2D.scale = Vector2(0.92, 1.08)

	# ---- 4. Horizontale beweging ----
	var is_crouching := Input.is_action_pressed("ui_down") and is_on_floor()

	if wall_jump_lock <= 0:
		if direction:
			velocity.x = direction * (CROUCH_SPEED if is_crouching else SPEED)
			if is_wall_sliding:
				$AnimatedSprite2D.flip_h = direction > 0
			else:
				$AnimatedSprite2D.flip_h = direction < 0
				
		else:
			var friction_speed = CROUCH_SPEED if is_crouching else SPEED
			velocity.x = move_toward(velocity.x, 0, friction_speed)

	# ---- 5. Animaties ----
	if is_on_floor():
		if not $LandingTimer.is_stopped():
			$AnimatedSprite2D.play("between_up_down")
		elif is_crouching:
			$AnimatedSprite2D.play("crouch_walk" if direction else "crouch")
		elif direction:
			$AnimatedSprite2D.play("walk")
		else:
			$AnimatedSprite2D.play("idle")
	else:
		if is_wall_sliding:
			$AnimatedSprite2D.play("wallslide")
			
		elif Input.is_action_pressed("ui_accept") and velocity.y > -100:
			$AnimatedSprite2D.play("float")
		elif velocity.y < -150:
			$AnimatedSprite2D.play("jump_up")
		elif velocity.y > 150:
			$AnimatedSprite2D.play("jump_down")
		else:
			$AnimatedSprite2D.play("between_up_down")

	# ---- 6. Wind-effect ----
	if not is_on_floor() or wind_push.y > 50 or wind_push.y < -50:
		velocity.x += wind_push.y * -1.3
	if not is_on_floor():
		velocity.y += wind_push.x * 0.4

	# ---- 7. Schaal herstellen ----
	$AnimatedSprite2D.scale = $AnimatedSprite2D.scale.lerp(Vector2.ONE, delta * 15.0)

	move_and_slide()
func _process(delta: float) -> void:
	var hoogte = (  round(-global_position.y) + 406) / 100
	hoogte_label.text = str(hoogte) + " m "
