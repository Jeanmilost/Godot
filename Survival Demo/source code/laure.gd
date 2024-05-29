extends CharacterBody3D

# components
@onready var g_Pivot      = $Pivot
@onready var g_Animations = $AnimationTree
@onready var g_WalkSound  = $Sounds/Walk

# player constants
const g_WalkingSpeed  = 1.5
const g_RotationSpeed = 4

# flags
var g_DoorOpening = false

###
# Called every frame at a fixed rate, which allows any processing that requires the physics values
#@param delta - elapsed time in seconds since the previous call
##
func _physics_process(delta):
	# is door opening?
	if g_DoorOpening:
		# stop the walking sound
		if g_WalkSound.is_playing():
			g_WalkSound.stop();

		return

	# rotate the player
	if Input.is_action_pressed("turn_right"):
		rotation.y -= delta * g_RotationSpeed 
	elif Input.is_action_pressed("turn_left"):
		rotation.y += delta * g_RotationSpeed

	# move the player
	if Input.is_action_pressed("move_forward"):
		var direction = g_Pivot.global_transform.basis.z.normalized()

		velocity.x = direction.x * g_WalkingSpeed
		velocity.z = direction.z * g_WalkingSpeed
	else:
		velocity.x = move_toward(velocity.x, 0.0, g_WalkingSpeed)
		velocity.z = move_toward(velocity.z, 0.0, g_WalkingSpeed)

	# get player state
	var isIdle    = velocity == Vector3.ZERO
	var isWalking = velocity != Vector3.ZERO
	
	# change the animation state depending on the user action
	g_Animations.set("parameters/conditions/isIdle",    isIdle)
	g_Animations.set("parameters/conditions/isWalking", isWalking)
	
	# play the walk sound if player is walking
	if isWalking:
		if !g_WalkSound.is_playing():
			g_WalkSound.play();
	else:
		if g_WalkSound.is_playing():
			g_WalkSound.stop();

	move_and_slide()

###
# Called when laboratory door is opening
##
func _on_main_on_door_opening():
	g_DoorOpening = true

func _on_environment_on_door_anim_finished():
	g_DoorOpening = false
