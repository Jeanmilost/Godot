extends CharacterBody3D

const StateMachine = preload("res://source code/state_machine.gd")

# components
@onready var g_Pivot      = $Pivot
@onready var g_Animations = $AnimationTree
@onready var g_WalkSound  = $Sounds/Walk
@onready var g_RunSound   = $Sounds/Run
@onready var g_FireSound  = $Sounds/Fire

# game objects
var g_StateMachine = null

# player constants
const g_WalkingSpeed  = 1.5
const g_RunningSpeed  = 3
const g_RotationSpeed = 4

# flags
var g_DoorOpening     = false
var g_IsFiring        = false
var g_FireSoundPlayed = false

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	g_StateMachine = StateMachine.new(g_Animations)

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

	# check if player is running
	var isRunning = Input.is_action_pressed("run_modifier_action")

	# check if player is pointing his gun
	var isPointingGun = velocity == Vector3.ZERO && Input.is_action_pressed("fire_modifier_action")

	# rotate the player
	if Input.is_action_pressed("turn_right"):
		rotation.y -= delta * g_RotationSpeed 
	elif Input.is_action_pressed("turn_left"):
		rotation.y += delta * g_RotationSpeed

	# move the player
	if Input.is_action_pressed("move_forward") && !isPointingGun:
		var direction = g_Pivot.global_transform.basis.z.normalized()

		if isRunning:
			velocity.x = direction.x * g_RunningSpeed
			velocity.z = direction.z * g_RunningSpeed
		else:
			velocity.x = direction.x * g_WalkingSpeed
			velocity.z = direction.z * g_WalkingSpeed
	else:
		if isRunning:
			velocity.x = move_toward(velocity.x, 0.0, g_RunningSpeed)
			velocity.z = move_toward(velocity.z, 0.0, g_RunningSpeed)
		else:
			velocity.x = move_toward(velocity.x, 0.0, g_WalkingSpeed)
			velocity.z = move_toward(velocity.z, 0.0, g_WalkingSpeed)

	# get player state
	var isIdle    = velocity == Vector3.ZERO && !isPointingGun
	var isWalking = velocity != Vector3.ZERO && !isPointingGun

	if !isPointingGun:
		g_IsFiring        = false
		g_FireSoundPlayed = false

	if !g_IsFiring:
		g_IsFiring = Input.is_action_pressed("fire")

	# change the animation state depending on the user action
	if isIdle:
		g_StateMachine._set_state(StateMachine.IEState.S_Idle)
	elif isWalking:
		if isRunning:
			g_StateMachine._set_state(StateMachine.IEState.S_Run)
		else:
			g_StateMachine._set_state(StateMachine.IEState.S_Walk)
	elif isPointingGun:
		if g_IsFiring:
			g_StateMachine._set_state(StateMachine.IEState.S_Fire)
		else:
			g_StateMachine._set_state(StateMachine.IEState.S_Fire_Idle)

	# apply the state machine
	g_StateMachine.run()

	# play the walk or run sound if player is walking or running
	if isWalking:
		if isRunning:
			if g_WalkSound.is_playing():
				g_WalkSound.stop();

			if !g_RunSound.is_playing():
				g_RunSound.play();
		else:
			if g_RunSound.is_playing():
				g_RunSound.stop();

			if !g_WalkSound.is_playing():
				g_WalkSound.play();
	else:
		if g_WalkSound.is_playing():
			g_WalkSound.stop();

		if g_RunSound.is_playing():
			g_RunSound.stop();

	# play the gun fire sound
	if isPointingGun && g_IsFiring && !g_FireSoundPlayed:
		if g_WalkSound.is_playing():
			g_WalkSound.stop();

		if g_RunSound.is_playing():
			g_RunSound.stop();

		if !g_FireSound.is_playing():
			g_FireSound.play();

		g_FireSoundPlayed = true

	move_and_slide()

###
# Called when laboratory door is opening
##
func _on_main_on_door_opening():
	g_DoorOpening = true

###
# Called when laboratory door animation finished
##
func _on_environment_on_door_anim_finished():
	g_DoorOpening = false

###
# Called when character animation finished
#@param anim_name - animation name which just finished
##
func _on_animation_tree_animation_finished(anim_name):
	# ignore all animation but the fire one
	if anim_name != "fire":
		return

	g_IsFiring        = false
	g_FireSoundPlayed = false

	g_StateMachine._set_state(StateMachine.IEState.S_Fire_Idle)
