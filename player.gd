extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -800.0
const FLOAT_GRAVITY_MULTIPLIER = 0.2

# Variabele om te onthouden of we de vorige frame in de lucht waren
var was_in_air := false

func _physics_process(delta: float) -> void:
	# 1. Zwaartekracht en zweven afhandelen
	if not is_on_floor():
		if Input.is_action_pressed("ui_accept") and velocity.y > 0:
			velocity += (get_gravity() * FLOAT_GRAVITY_MULTIPLIER) * delta
		else:
			velocity += get_gravity() * delta

	# 2. Landings-detectie (Start de timer zodra je de grond raakt)
	if is_on_floor() and was_in_air:
		$LandingTimer.start(0.15) # Verander 0.15 om de landing korter of langer te maken
	
	# Status onthouden voor het volgende frame
	was_in_air = not is_on_floor()

	# 3. Springen afhandelen
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$LandingTimer.stop() # Stop de landingstimer meteen als je direct weer springt

	# 4. Lopen en richting bepalen
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 5. De juiste animaties afspelen op basis van de situatie
	if is_on_floor():
		# Als de landingstimer loopt, dwing dan het tussen-frame af
		if not $LandingTimer.is_stopped():
			$AnimatedSprite2D.play("between_up_down")
		elif direction:
			$AnimatedSprite2D.play("walk")
		else:
			$AnimatedSprite2D.play("idle")
	else:
		# De speler is in de lucht!
		if Input.is_action_pressed("ui_accept") and velocity.y > -100:
			# Als de knop ingedrukt is en we vallen (of zijn bijna op het hoogste punt), start het zweven
			$AnimatedSprite2D.play("float")
		elif velocity.y < -150:
			# De speler gaat nog hard omhoog
			$AnimatedSprite2D.play("jump_up")
		elif velocity.y > 150:
			# De speler valt al snel naar beneden
			$AnimatedSprite2D.play("jump_down")
		else: 
			$AnimatedSprite2D.play("between_up_down")

	move_and_slide()
