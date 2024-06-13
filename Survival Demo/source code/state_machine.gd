###
# State machine
#@author Jean-Milost Reymond
##
class_name StateMachine

# states
enum IEState {S_Idle, S_Walk, S_Run, S_Fire_Idle, S_Fire, S_Repulse, S_Hit, S_Die}

# properties
var m_Animations = null
var m_State      = IEState.S_Idle

###
# Constructor
#@param animations - animations used by the state machine
##
func _init(animations):
	m_Animations = animations

###
# Gets the current machine state
#@return current machine state
##
func _get_state():
	return m_State

###
# Sets the current machine state
#@param state - current machine state
##
func _set_state(state):
	# if state changed, force animation to restart, otherwise non looping animations will not play
	if state != m_State:
		m_Animations.active = false
		m_Animations.active = true

	# set new state
	m_State = state

###
# Runs the state machine
##
func run():
	match m_State:
		IEState.S_Idle:
			m_Animations.set("parameters/conditions/isIdle",      true)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     false)

		IEState.S_Walk:
			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   true)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     false)

		IEState.S_Run:
			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   true)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     false)

		IEState.S_Fire_Idle:
			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isFireIdle",  true)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     false)

		IEState.S_Fire:
			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    true)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     false)

		IEState.S_Repulse:
			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", true)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     false)

		IEState.S_Hit:
			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       true)
			m_Animations.set("parameters/conditions/isDying",     false)

		IEState.S_Die:
			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     true)

		_:
			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     false)
