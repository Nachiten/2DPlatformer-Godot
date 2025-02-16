extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_time: Timer = $CoyoteTime

enum JumpState { FLOOR, JUMPING_UP, JUMPING_DOWN, FALLING }
var jump_state = JumpState.FLOOR
var can_coyote_jump = false

signal can_coyote_jump_changed(newValue)

func set_jump_state(newState: JumpState) -> void:
	if newState == jump_state:
		return

	jump_state = newState
	print("New state: ", JumpState.keys()[jump_state])

	match newState:
		JumpState.FALLING:
			coyote_time.start()
			can_coyote_jump = true
			can_coyote_jump_changed.emit(can_coyote_jump)
		JumpState.FLOOR:
			can_coyote_jump = false
			can_coyote_jump_changed.emit(can_coyote_jump)

func _on_coyote_time_timeout() -> void:
	can_coyote_jump = false
	can_coyote_jump_changed.emit(can_coyote_jump)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

		# If we stopped being on floor without jumping, then we are falling
		if jump_state == JumpState.FLOOR:
			set_jump_state(JumpState.FALLING)
	else:
		# If we are on floor, we are not jumping nor falling
		set_jump_state(JumpState.FLOOR)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or can_coyote_jump):
		can_coyote_jump = false
		can_coyote_jump_changed.emit(can_coyote_jump)
		velocity.y = JUMP_VELOCITY
		set_jump_state(JumpState.JUMPING_UP)
	elif jump_state == JumpState.JUMPING_UP and velocity.y > 0:
		# If velocity went from negative to positive, we started falling down from the jump
		set_jump_state(JumpState.JUMPING_DOWN)

	# Get the input direction: -1, 0, 1
	var direction := Input.get_axis("move_left", "move_right")

	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
