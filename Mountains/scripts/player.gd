extends CharacterBody3D

# player constants
const g_WalkingSpeed  = 1.5
const g_RotationSpeed = 4

var gravity = 100

@onready var g_WalkSound = $Sounds/Footsteps

###
# Called every frame at a fixed rate, which allows any processing that requires the physics values
#@param delta - elapsed time in seconds since the previous call
##
func _physics_process(delta):
	# rotate the player
	if Input.is_action_pressed("turn_right"):
		rotation.y -= delta * g_RotationSpeed
	elif Input.is_action_pressed("turn_left"):
		rotation.y += delta * g_RotationSpeed

	# move the player
	if Input.is_action_pressed("move_forward"):
		var direction = $Pivot.global_transform.basis.z.normalized()

		velocity.x = direction.x * g_WalkingSpeed * -1.0
		velocity.z = direction.z * g_WalkingSpeed * -1.0

		# play walk sound, if still not playing
		if !g_WalkSound.playing:
			g_WalkSound.play()
	else:
		velocity.x = move_toward(velocity.x, 0.0, g_WalkingSpeed)
		velocity.z = move_toward(velocity.z, 0.0, g_WalkingSpeed)

		# stop walk sound, if still playing
		if g_WalkSound.playing:
			g_WalkSound.stop()

	velocity.y -= gravity * delta

	move_and_slide()
