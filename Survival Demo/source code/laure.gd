extends CharacterBody3D

#const SPEED = 5.0
#const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const g_PlayerSpeed = 5.0

func _physics_process(delta):
	if Input.is_action_pressed("turn_right"):
		rotation.y -= 0.1
	elif Input.is_action_pressed("turn_left"):
		rotation.y += 0.1

	if Input.is_action_pressed("move_forward"):
		var direction = (transform.basis * Vector3(sin(rotation.y - (PI / 2.0)), 0.0, cos(rotation.y - (PI / 2.0))).normalized())

		velocity.x = direction.x * g_PlayerSpeed
		velocity.z = direction.z * g_PlayerSpeed
	else:
		velocity.x = move_toward(velocity.x, 0.0, g_PlayerSpeed)
		velocity.z = move_toward(velocity.z, 0.0, g_PlayerSpeed)

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

	#if $AnimationTree != null:
	#	$AnimationTree.set("parameters/conditions/idle", velocity == Vector3.ZERO)
	#	$AnimationTree.set("parameters/conditions/walk", velocity != Vector3.ZERO)
	
	move_and_slide()
