extends CharacterBody3D

# import the state machine
const StateMachine = preload("res://source code/state_machine.gd")

# bot actions
enum EBotAction {PA_Idle, PA_Walk, PA_Attack, PA_Attacking, PA_Hit, PA_Hitting, PA_Dead, PA_Paused}

# components
@onready var g_Animations  = $AnimationTree
@onready var g_AnimPlayer  = $Pivot/Zombie/AnimationPlayer
@onready var g_NavAgent    = $NavigationAgent
@onready var g_Target      = $"../Laure"
@onready var g_WalkSound   = $Sounds/Walk
@onready var g_MoanSound   = $Sounds/Moan
@onready var g_AttackSound = $Sounds/Attack
@onready var g_HitSound    = $Sounds/Hit
@onready var g_DieSound    = $Sounds/Die

# game objects
var g_StateMachine = null

# bot constants
const g_Speed          = 0.5
const g_Accel          = 0.25
const g_MinDistance    = 1.1
const g_MinHitDistance = 1.2
const g_HitAllowedTime = 1100.0
const g_HitMissedTime  = 1300.0

# values
var g_AttackingTimestamp = 0.0
var g_Energy             = 5.0

# flags
var g_IsActivated  = false
var g_Attacking    = false
var g_HitPerformed = false
var g_IsHit        = false
var g_IsHitting    = false
var g_PlayerDied   = false
var g_IsDying      = false

# Emitted when the bot hits the player
signal onHitPlayer

###
# Get the bot state
#@return the bot state
##
func GetBotState():
	# is bot inactive?
	if !g_IsActivated:
		return EBotAction.PA_Paused

	if g_Energy <= 0:
		return EBotAction.PA_Dead

	if g_IsHitting:
		return EBotAction.PA_Hitting

	if g_IsHit:
		return EBotAction.PA_Hit

	if g_Attacking:
		return EBotAction.PA_Attacking

	if DoStartAttack():
		return EBotAction.PA_Attack

	if  !g_PlayerDied:
		return EBotAction.PA_Walk

	return EBotAction.PA_Idle

###
# Moves and rotates the bot toward the player
#@param elapsedTime - elapsed time in seconds since the previous call
##
func TargetPlayer(elapsedTime):
	# set the player as target for the navigation agent
	g_NavAgent.target_position = g_Target.global_position

	# get the bot next position
	var nextPos = g_NavAgent.get_next_path_position()

	# calculate the move direction
	var direction = (nextPos - global_position).normalized()

	# calculate the bot position and rotation
	velocity   = velocity.lerp(direction * g_Speed, g_Accel * elapsedTime)
	rotation.y = atan2(velocity.x, velocity.z)

###
# Moves the bot during the attack
##
func MoveDuringAttack():
	# keep the bot facing the player while attacking
	var direction = global_position - g_Target.global_position
	rotation.y    = atan2(-direction.x, -direction.z)

###
# Calculates if the vectors are closer than a minimum distance
#@param vec1 - first vetor to check
#@param vec2 - second vetor to check against
#@param minDist - minimum distance
#@return true if vec1 is close to vec2, otherwise false
##
func IsCloseTo(vec1, vec2, minDist):
	return vec2.distance_to(vec1) <= minDist

###
# Checks if the bot starts to attack the player
#@returns true if the bot is attacking the player, otherwise false
##
func DoStartAttack():
	# player already died?
	if g_PlayerDied:
		return false

	# already attacking?
	if g_Attacking:
		return true

	# check if close enough to attack the player
	g_Attacking = IsCloseTo(global_position, g_Target.global_position, g_MinHitDistance)

	return g_Attacking

###
# Plays the walk sound
##
func PlayWalkSound():
	# play the walking sound
	if !g_WalkSound.is_playing():
		g_WalkSound.play();

###
# Plays the moan sound
##
func PlayMoanSound():
	# play the moan sound
	if !g_MoanSound.is_playing():
		g_MoanSound.play();

###
# Plays the attack sound
##
func PlayAttackSound():
	# play the attack sound
	if !g_AttackSound.is_playing():
		g_AttackSound.play();

###
# Plays the hit sound
##
func PlayHitSound():
	# play the hit sound
	if !g_HitSound.is_playing():
		g_HitSound.play();

###
# Plays the die sound
##
func PlayDieSound():
	# play the die sound
	if !g_DieSound.is_playing():
		g_DieSound.play();

###
# Stops all the sounds
##
func StopSounds():
	# stop the walk sound
	if g_WalkSound.is_playing():
		g_WalkSound.stop();

	# stop the moan sound
	if g_MoanSound.is_playing():
		g_MoanSound.stop();

	# stop the attack sound
	if g_AttackSound.is_playing():
		g_AttackSound.stop();

	# stop the hit sound
	if g_HitSound.is_playing():
		g_HitSound.stop();

	# stop the die sound
	if g_DieSound.is_playing():
		g_DieSound.stop();

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
	# get current time
	var curTime = Time.get_ticks_msec()

	var moved = false

	# switch the bot action to apply
	match GetBotState():
		EBotAction.PA_Paused:
			return

		EBotAction.PA_Idle:
			StopSounds()

			g_StateMachine._set_state(StateMachine.IEState.S_Idle)

		EBotAction.PA_Walk:
			# make the bot to walk toward the player
			TargetPlayer(delta)

			PlayWalkSound()

			moved = true

			g_StateMachine._set_state(StateMachine.IEState.S_Walk)

		EBotAction.PA_Attack:
			g_AttackingTimestamp = Time.get_ticks_msec()

			MoveDuringAttack()

			StopSounds()
			PlayAttackSound()

			g_StateMachine._set_state(StateMachine.IEState.S_Attack)

		EBotAction.PA_Attacking:
			MoveDuringAttack()

			# is the player still not hit and the bot attack animation reached the point where the player can be hit?
			if !g_HitPerformed && curTime >= g_AttackingTimestamp + g_HitAllowedTime && curTime < g_AttackingTimestamp + g_HitMissedTime:
				# if player is still close enough to the bot, it will be hit
				if IsCloseTo(global_position, g_Target.global_position, g_MinHitDistance):
					onHitPlayer.emit()
					g_HitPerformed = true

		EBotAction.PA_Hit:
			StopSounds()
			PlayHitSound()

			g_StateMachine._set_delayed_state(StateMachine.IEState.S_Hit, 0.3)

			g_IsHitting = true

		EBotAction.PA_Hitting:
			g_IsHitting = true #REM

		EBotAction.PA_Dead:
			if !g_IsDying:
				StopSounds()
				PlayDieSound()
				g_IsDying = true

			g_StateMachine._set_state(StateMachine.IEState.S_Die)

		_:
			StopSounds()

			g_StateMachine._set_state(StateMachine.IEState.S_Idle)

	# apply the bot changes
	if moved:
		move_and_slide()

###
# Called when character animation finished
#@param anim_name - animation name which just finished
##
func _on_animation_tree_animation_finished(anim_name):
	# was bot hit?
	if anim_name == "Hit":
		g_IsHit        = false
		g_IsHitting    = false
		g_Attacking    = false
		g_HitPerformed = false
		return

	# was bot attacking?
	if anim_name == "Attack":
		g_IsHit        = false
		g_IsHitting    = false
		g_Attacking    = false
		g_HitPerformed = false

###
# Called when the player enters in the laboratory
##
func _on_main_on_player_enters_labo_room():
	PlayMoanSound()

	g_IsActivated = true

###
# Called when the player leaves the laboratory
##
func _on_main_on_player_leaves_labo_room():
	StopSounds()

	g_IsActivated = false

###
# Called when the player hits the bot
##
func _on_laure_on_player_hit_bot():
	if g_IsHit:
		return

	# remove 1 point of energy
	if g_IsActivated && !g_IsHit:
		g_Energy = g_Energy - 1

	g_IsHit     = true
	g_IsHitting = false

###
# Called when the player died
##
func _on_laure_on_player_died():
	g_PlayerDied = true
