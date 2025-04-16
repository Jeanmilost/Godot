extends CharacterBody3D

# constants
const g_Speed = 20.0

###
# Called every frame at a fixed rate, which allows any processing that requires the physics values
#@param delta - elapsed time in seconds since the previous call
##
func _physics_process(delta):
	# get pressed key and deduce the direction to move to
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(0, -input_dir.y, input_dir.x)).normalized()

	# move the player item
	if direction:
		velocity.y = direction.y * g_Speed
		velocity.z = direction.z * g_Speed
	else:
		velocity.y = move_toward(velocity.y, 0, g_Speed)
		velocity.z = move_toward(velocity.z, 0, g_Speed)

	move_and_slide()

	# limit the item position into the screen
	position.x = clamp(position.x, -45, 45)
	position.y = clamp(position.y,  0,  20) 
