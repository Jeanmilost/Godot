extends CharacterBody3D

#const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# player constants
const g_WalkingSpeed  = 1.5
const g_RotationSpeed = 4

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

		velocity.x = direction.x * g_WalkingSpeed
		velocity.z = direction.z * g_WalkingSpeed
	else:
		velocity.x = move_toward(velocity.x, 0.0, g_WalkingSpeed)
		velocity.z = move_toward(velocity.z, 0.0, g_WalkingSpeed)

	# Add the gravity.
	#if not is_on_floor():
	#	velocity.y -= gravity * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	#if direction:
	#	velocity.x = direction.x * SPEED
	#	velocity.z = direction.z * SPEED
	#else:
	#	velocity.x = move_toward(velocity.x, 0, SPEED)
	#	velocity.z = move_toward(velocity.z, 0, SPEED)

	# get player state
	var isIdle    = velocity == Vector3.ZERO
	var isWalking = velocity != Vector3.ZERO
	
	# change the animation state depending on the user action
	$AnimationTree.set("parameters/conditions/isIdle",    isIdle)
	$AnimationTree.set("parameters/conditions/isWalking", isWalking)
	
	# play the walk sound if player is walking
	if isWalking:
		if !$Sounds/Walk.is_playing():
			$Sounds/Walk.play();
	else:
		if $Sounds/Walk.is_playing():
			$Sounds/Walk.stop();
		
	move_and_slide()
