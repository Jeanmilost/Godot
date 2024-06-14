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
const g_Speed       = 0.5
const g_Accel       = 0.25
const g_MinDistance = 1.1

# flags
var g_IsActivated = false
var g_Attacking   = false

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

	# set the player as target for the navigation agent
	g_NavAgent.target_position = g_Target.global_position

	# not attacking?
	if !g_Attacking:
		# check if close enough to attack the player
		g_Attacking = IsCloseTo(global_position, g_Target.global_position, g_MinDistance)

		# if attacking, restart the animation
		if (g_Attacking):
			g_Animations.active = false
			g_Animations.active = true

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

	# get bot state
	var isIdle    = velocity == Vector3.ZERO && !g_Attacking
	var isWalking = velocity != Vector3.ZERO && !g_Attacking

	# change the animation state depending on the bot action
	if isIdle:
		g_StateMachine._set_state(StateMachine.IEState.S_Idle)
	elif isWalking:
		g_StateMachine._set_state(StateMachine.IEState.S_Walk)
	elif g_Attacking:
		g_StateMachine._set_state(StateMachine.IEState.S_Attack)

	# apply the state machine
	g_StateMachine.run()

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
	# ignore all animation but the fire one
	if anim_name != "Attack":
		return

	g_Attacking = false

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
