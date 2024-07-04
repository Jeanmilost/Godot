extends CharacterBody3D

# import the state machine
const StateMachine = preload("res://source code/state_machine.gd")

# player actions
enum EPlayerAction {PA_Idle, PA_Walk, PA_Run, PA_Fire_Idle, PA_Fire, PA_Firing, PA_Hit, PA_Dead, PA_Paused}

# components
@onready var g_Pivot      = $Pivot
@onready var g_Fire       = $Pivot/Model/laure/Game_engine/Skeleton3D/cl_gun_left_handMesh/Fire
@onready var g_Animations = $AnimationTree
@onready var g_WalkSound  = $Sounds/Walk
@onready var g_RunSound   = $Sounds/Run
@onready var g_FireSound  = $Sounds/Fire
@onready var g_HitSound   = $Sounds/Hit
@onready var g_DyingSound = $Sounds/Dying
@onready var g_GunRay     = $GunRay

# game objects
var g_StateMachine = null

# player constants
const g_WalkingSpeed  = 1.5
const g_RunningSpeed  = 3
const g_RotationSpeed = 4
const g_FireTime      = 0.01

# values
var g_FireTimestamp = 0.0
var g_Energy        = 5

# flags
var g_DoorOpening      = false
var g_IsFiring         = false
var g_IsHit            = false
var g_IsBotHit         = false
var g_FireSoundPlayed  = false
var g_HitSoundPlayed   = false
var g_DyingSoundPlayed = false

# Emitted when the player hit the bot
signal onPlayerHitBot

# Emitted when the player died
signal onPlayerDied

###
# Get the player state
#@param walk - if true, the walk key is pressed
#@param run - if true, the run key is pressed
#@param aim - if true, the aim key is pressed
#@param fire - if true, the fire key is pressed
#@return the player state
##
func GetPlayerState(walk, run, aim, fire):
	if g_DoorOpening:
		return EPlayerAction.PA_Paused

	if g_Energy <= 0:
		return EPlayerAction.PA_Dead

	if g_IsHit:
		return EPlayerAction.PA_Hit

	if g_IsFiring:
		return EPlayerAction.PA_Firing

	if aim:
		if fire:
			return EPlayerAction.PA_Fire

		return EPlayerAction.PA_Fire_Idle

	if walk:
		if run:
			return EPlayerAction.PA_Run

		return EPlayerAction.PA_Walk

	return EPlayerAction.PA_Idle

###
# Move the player
#@param walking - if true, player is currently walking
#@param running - if true, player will run instead of walk
##
func Move(walking, running):
	# move the player
	if walking:
		var direction = g_Pivot.global_transform.basis.z.normalized()

		if running:
			velocity.x = direction.x * g_RunningSpeed
			velocity.z = direction.z * g_RunningSpeed
		else:
			velocity.x = direction.x * g_WalkingSpeed
			velocity.z = direction.z * g_WalkingSpeed
	else:
		if running:
			velocity.x = move_toward(velocity.x, 0.0, g_RunningSpeed)
			velocity.z = move_toward(velocity.z, 0.0, g_RunningSpeed)
		else:
			velocity.x = move_toward(velocity.x, 0.0, g_WalkingSpeed)
			velocity.z = move_toward(velocity.z, 0.0, g_WalkingSpeed)

###
# Rotate the player
#@param delta - elapsed time in seconds since the previous frame
##
func Rotate(delta):
	if Input.is_action_pressed("turn_right"):
		rotation.y -= delta * g_RotationSpeed 
	elif Input.is_action_pressed("turn_left"):
		rotation.y += delta * g_RotationSpeed

###
# Plays the walk sound
##
func PlayWalkSound():
	# stop the running sound
	if g_RunSound.is_playing():
		g_RunSound.stop();

	# play the walking sound
	if !g_WalkSound.is_playing():
		g_WalkSound.play();

###
# Plays the run sound
##
func PlayRunSound():
	# stop the walking sound
	if g_WalkSound.is_playing():
		g_WalkSound.stop();

	# play the running sound
	if !g_RunSound.is_playing():
		g_RunSound.play();

###
# Stops all the walk and run sounds
##
func StopWalkAndRunSounds():
	# stop the walking sound
	if g_WalkSound.is_playing():
		g_WalkSound.stop();

	# stop the running sound
	if g_RunSound.is_playing():
		g_RunSound.stop();

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	g_StateMachine = StateMachine.new(g_Animations)
	g_Fire.visible = false

###
# Called every frame at a fixed rate, which allows any processing that requires the physics values
#@param delta - elapsed time in seconds since the previous call
##
func _physics_process(delta):
	# get current time
	var curTime = Time.get_ticks_msec()

	# get input status
	var walkPressed = Input.is_action_pressed("move_forward")
	var runPressed  = Input.is_action_pressed("run_modifier_action")
	var aimPressed  = Input.is_action_pressed("fire_modifier_action")
	var firePressed = Input.is_action_pressed("fire")

	var moved = false

	# switch the player action to apply
	match GetPlayerState(walkPressed, runPressed, aimPressed, firePressed):
		EPlayerAction.PA_Paused:
			StopWalkAndRunSounds()
			return

		EPlayerAction.PA_Idle:
			# rotate the player
			Rotate(delta)

			StopWalkAndRunSounds()

			g_StateMachine._set_state(StateMachine.IEState.S_Idle)

		EPlayerAction.PA_Walk:
			# rotate the player
			Rotate(delta)

			# move the player
			Move(true, false)

			moved = true

			PlayWalkSound()

			g_StateMachine._set_state(StateMachine.IEState.S_Walk)

		EPlayerAction.PA_Run:
			# rotate the player
			Rotate(delta)

			# move the player
			Move(true, true)

			moved = true

			PlayRunSound()

			g_StateMachine._set_state(StateMachine.IEState.S_Run)

		EPlayerAction.PA_Fire_Idle:
			# rotate the player
			Rotate(delta)

			# move the player
			Move(false, false)

			moved = true

			StopWalkAndRunSounds()

			g_StateMachine._set_state(StateMachine.IEState.S_Fire_Idle)

		EPlayerAction.PA_Fire:
			# rotate the player
			Rotate(delta)

			# move the player
			Move(false, false)

			# configure the fire status
			moved           = true
			g_IsFiring      = true
			g_Fire.visible  = true
			g_FireTimestamp = Time.get_ticks_msec()

			StopWalkAndRunSounds()

			# play the fire sound
			if !g_FireSound.is_playing():
				g_FireSound.play();

			g_StateMachine._set_state(StateMachine.IEState.S_Fire)

		EPlayerAction.PA_Firing:
			# hide the fire effect if fire time was elapsed
			if (curTime >= g_FireTimestamp + g_FireTime):
				g_Fire.visible = false

			# is the gun ray hit something 
			if !g_IsBotHit && g_GunRay.is_colliding():
				# get the collider
				var gunCollider = g_GunRay.get_collider()

				# hit the bot?
				if gunCollider.name == "Zombie":
					g_IsBotHit = true
					onPlayerHitBot.emit()

		EPlayerAction.PA_Hit:
			StopWalkAndRunSounds()

			# play the dying sound
			if !g_HitSoundPlayed && !g_HitSound.is_playing():
				g_HitSound.play();
				g_HitSoundPlayed = true

			g_StateMachine._set_state(StateMachine.IEState.S_Hit)

		EPlayerAction.PA_Dead:
			StopWalkAndRunSounds()

			# play the dying sound
			if !g_DyingSoundPlayed && !g_DyingSound.is_playing():
				g_DyingSound.play();
				g_DyingSoundPlayed = true

			g_StateMachine._set_state(StateMachine.IEState.S_Die)

		_:
			StopWalkAndRunSounds()

			g_StateMachine._set_state(StateMachine.IEState.S_Idle)

	# apply the player changes
	if moved:
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
	# player was hit
	if anim_name == "hit":
		# reset both fire and hit status
		g_IsHit          = false
		g_IsBotHit       = false
		g_HitSoundPlayed = false
		g_IsFiring 		 = false
		return

	# player aiming
	if anim_name == "fire_idle":
		# reset fire status
		g_IsFiring = false
		g_IsBotHit = false
		return

	# player fired
	if anim_name == "fire":
		# reset both fire and hit status
		g_IsHit          = false
		g_IsBotHit       = false
		g_HitSoundPlayed = false
		g_IsFiring       = false

###
# Called when the bot hits the player
##
func _on_zombie_on_hit_player():
	# remove 1 point of energy
	g_Energy = g_Energy - 1

	# no longer energy, player died
	if !g_Energy:
		onPlayerDied.emit()

	g_IsHit = true
