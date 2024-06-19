extends CharacterBody3D

# import the state machine
const StateMachine = preload("res://source code/state_machine.gd")

# components
@onready var g_Animations = $AnimationTree
@onready var g_NavAgent   = $NavigationAgent
@onready var g_Target     = $"../Laure"

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

# flags
var g_IsActivated  = false
var g_Attacking    = false
var g_HitPerformed = false
var g_PlayerDied   = false

# Emitted when the bot hits the player
signal onHitPlayer

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
	# is bot inactive?
	if (!g_IsActivated):
		return

	# get current time
	var curTime = Time.get_ticks_msec()

	# player still alive?
	if !g_PlayerDied:
		# set the player as target for the navigation agent
		g_NavAgent.target_position = g_Target.global_position

		# not attacking?
		if !g_Attacking:
			# check if close enough to attack the player
			g_Attacking = !g_PlayerDied && IsCloseTo(global_position, g_Target.global_position, g_MinDistance)

			# if attacking, restart the animation
			if (g_Attacking):
				g_Animations.active = false
				g_Animations.active = true

				g_AttackingTimestamp = Time.get_ticks_msec()

		# still not attacking?
		if !g_Attacking:
			# get the bot next position
			var nextPos = g_NavAgent.get_next_path_position()

			# calculate the move direction
			var direction = (nextPos - global_position).normalized()

			# calculate the bot position and rotation
			velocity   = velocity.lerp(direction * g_Speed, g_Accel * delta)
			rotation.y = atan2(velocity.x, velocity.z)
		else:
			# keep the bot facing the player while attacking
			var direction = global_position - g_Target.global_position
			rotation.y    = atan2(-direction.x, -direction.z)

			# can hit the player?
			if !g_HitPerformed && curTime >= g_AttackingTimestamp + g_HitAllowedTime && curTime < g_AttackingTimestamp + g_HitMissedTime:
				# if player is close enough to the bot, it will be hit
				if IsCloseTo(global_position, g_Target.global_position, g_MinHitDistance):
					onHitPlayer.emit()
					g_HitPerformed = true

	# get bot state
	var isIdle    = (velocity == Vector3.ZERO && !g_Attacking) || g_PlayerDied
	var isWalking =  velocity != Vector3.ZERO && !g_Attacking

	# change the animation state depending on the bot action
	if isIdle:
		g_StateMachine._set_state(StateMachine.IEState.S_Idle)
	elif isWalking:
		g_StateMachine._set_state(StateMachine.IEState.S_Walk)
	elif g_Attacking:
		g_StateMachine._set_state(StateMachine.IEState.S_Attack)

	# apply the state machine
	g_StateMachine.run()

	# no longer move and slide the bot if player died (otherwise for an unknown reason it  will drift)
	if g_PlayerDied:
		return

	# apply the bot changes
	move_and_slide()

###
# Calculates if the vectors are closer than a minimum distance
#@param vec1 - first vetor to check
#@param vec2 - second vetor to check against
#@param minDist - minimum distance
##
func IsCloseTo(vec1, vec2, minDist):
	return vec2.distance_to(vec1) <= minDist

###
# Called when character animation finished
#@param anim_name - animation name which just finished
##
func _on_animation_tree_animation_finished(anim_name):
	# ignore all animation but the attack one
	if anim_name != "Attack":
		return

	g_Attacking    = false
	g_HitPerformed = false

###
# Called when the player enters in the laboratory
##
func _on_main_on_player_enters_labo_room():
	g_IsActivated = true

###
# Called when the player leaves the laboratory
##
func _on_main_on_player_leaves_labo_room():
	g_IsActivated = false

###
#Called when the player died
##
func _on_laure_on_player_died():
	g_PlayerDied = true
