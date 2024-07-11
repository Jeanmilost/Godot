extends CharacterBody2D

@onready var g_Sprite = $Sprite

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")

	if direction:
		g_Sprite.flip_h = direction < 0.0

		velocity.x = direction * SPEED
		g_Sprite.play("default")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		g_Sprite.stop()

	move_and_slide()
