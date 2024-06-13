extends CharacterBody3D

# import the state machine
const StateMachine = preload("res://source code/state_machine.gd")

# components
@onready var g_Animations = $AnimationTree
@onready var g_NavAgent   = $NavigationAgent
@onready var g_Target     = $"../Laure"

# game objects
var g_StateMachine = null

# zombie constants
const g_Speed = 0.5
const g_Accel = 0.25

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
	g_NavAgent.target_position = g_Target.global_position

	var direction = (g_NavAgent.get_next_path_position() - global_position).normalized()

	velocity   = velocity.lerp(direction * g_Speed, g_Accel * delta)
	rotation.y = atan2(velocity.x, velocity.z)

	# get player state
	var isIdle    = velocity == Vector3.ZERO
	var isWalking = velocity != Vector3.ZERO

	# change the animation state depending on the user action
	if isIdle:
		g_StateMachine._set_state(StateMachine.IEState.S_Idle)
	elif isWalking:
		g_StateMachine._set_state(StateMachine.IEState.S_Walk)

	# apply the state machine
	g_StateMachine.run()

	move_and_slide()
