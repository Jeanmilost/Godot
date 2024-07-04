###
# State machine
#@author Jean-Milost Reymond
##
class_name StateMachine

# states
enum IEState {S_Idle, S_Walk, S_Run, S_Attack, S_Attack_End, S_Fire_Idle, S_Fire, S_Fire_End, S_Repulse, S_Repulse_End, S_Hit, S_Hit_End, S_Die, S_Die_End}

# properties
var m_Animations = null
var m_State      = IEState.S_Idle

###
# Constructor
#@param animations - animations used by the state machine
##
func _init(animations):
	m_Animations = animations
	m_Animations.connect("animation_finished", _on_animation_finished)

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
	var state_changed = state != m_State

	# set new state
	m_State = state

	# state changed?
	if state_changed:
		_run(0.0)

###
# Sets the current machine state
#@param state - current machine state
#@param start_time - animation start time in seconds
##
func _set_delayed_state(state, start_time):
	var state_changed = state != m_State

	# set new state
	m_State = state

	# state changed?
	if state_changed:
		_run(start_time)

###
# Runs the state machine
#@param start_time - animation start time in seconds
##
func _run(start_time):
	# dispatch state
	match m_State:
		IEState.S_Idle:
			m_Animations.set("parameters/conditions/isIdle",      true)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isAttacking", false)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     false)

		IEState.S_Walk:
			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   true)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isAttacking", false)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     false)

		IEState.S_Run:
			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   true)
			m_Animations.set("parameters/conditions/isAttacking", false)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     false)

		IEState.S_Attack:
			# possible animation deadlock?
			if _check_deadlock():
				# this is a workaround to resolve animation deadlock, force to change state to fire
				# idle (the only one from which the fire may be started)
				m_Animations.set("parameters/conditions/isIdle",      true)
				m_Animations.set("parameters/conditions/isAttacking", false)

				# wait for a few time, otherwise the animation change will not be computed
				await m_Animations.get_tree().create_timer(0.05).timeout

			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isAttacking", true)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     false)

		IEState.S_Attack_End:
			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isAttacking", false)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     false)

		IEState.S_Fire_Idle:
			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isAttacking", false)
			m_Animations.set("parameters/conditions/isFireIdle",  true)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     false)

		IEState.S_Fire:
			# possible animation deadlock?
			if _check_deadlock():
				# this is a workaround to resolve animation deadlock, force to change state to fire
				# idle (the only one from which the fire may be started)
				m_Animations.set("parameters/conditions/isFireIdle", true)
				m_Animations.set("parameters/conditions/isFiring",   false)

				# wait for a few time, otherwise the animation change will not be computed
				await m_Animations.get_tree().create_timer(0.05).timeout

			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isAttacking", false)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    true)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     false)

		IEState.S_Fire_End:
			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isAttacking", false)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     false)

		IEState.S_Repulse:
			# possible animation deadlock?
			if _check_deadlock():
				# this is a workaround to resolve animation deadlock, force to change state to fire
				# idle (the only one from which the fire may be started)
				m_Animations.set("parameters/conditions/isIdle",      true)
				m_Animations.set("parameters/conditions/isRepulsing", false)

				# wait for a few time, otherwise the animation change will not be computed
				await m_Animations.get_tree().create_timer(0.05).timeout

			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isAttacking", false)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", true)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     false)

		IEState.S_Repulse_End:
			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isAttacking", false)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     false)

		IEState.S_Hit:
			# possible animation deadlock?
			if _check_deadlock():
				# this is a workaround to resolve animation deadlock, force to change state to fire
				# idle (the only one from which the fire may be started)
				m_Animations.set("parameters/conditions/isIdle", true)
				m_Animations.set("parameters/conditions/isHit",  false)

				# wait for a few time, otherwise the animation change will not be computed
				await m_Animations.get_tree().create_timer(0.05).timeout

			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isAttacking", false)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       true)
			m_Animations.set("parameters/conditions/isDying",     false)

		IEState.S_Hit_End:
			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isAttacking", false)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     false)

		IEState.S_Die:
			# possible animation deadlock?
			if _check_deadlock():
				# this is a workaround to resolve animation deadlock, force to change state to fire
				# idle (the only one from which the fire may be started)
				m_Animations.set("parameters/conditions/isIdle",  true)
				m_Animations.set("parameters/conditions/isDying", false)

				# wait for a few time, otherwise the animation change will not be computed
				await m_Animations.get_tree().create_timer(0.05).timeout

			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isAttacking", false)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     true)

		IEState.S_Die_End:
			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isAttacking", false)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     false)

		_:
			m_Animations.set("parameters/conditions/isIdle",      false)
			m_Animations.set("parameters/conditions/isWalking",   false)
			m_Animations.set("parameters/conditions/isRunning",   false)
			m_Animations.set("parameters/conditions/isAttacking", false)
			m_Animations.set("parameters/conditions/isFireIdle",  false)
			m_Animations.set("parameters/conditions/isFiring",    false)
			m_Animations.set("parameters/conditions/isRepulsing", false)
			m_Animations.set("parameters/conditions/isHit",       false)
			m_Animations.set("parameters/conditions/isDying",     false)

	m_Animations.advance(start_time)

###
# Detects a possible animation deadlock. This is the case when a non-looping animation is replayed
# immediately without playing another animation  between
#@return true if a deadlock is detected, otherwise false
##
func _check_deadlock():
	# dispatch state
	match m_State:
		IEState.S_Attack:  return m_Animations["parameters/conditions/isAttacking"]
		IEState.S_Fire:    return m_Animations["parameters/conditions/isFiring"]
		IEState.S_Repulse: return m_Animations["parameters/conditions/isRepulsing"]
		IEState.S_Hit:     return m_Animations["parameters/conditions/isHit"]
		IEState.S_Die:     return m_Animations["parameters/conditions/isDying"]
		_:                 return false

###
# Converts the state to string
#@param state - state to convert
#@return state as string
##
func _state_to_str(state):
	match state:
		IEState.S_Idle:        return "IEState.S_Idle"
		IEState.S_Walk:        return "IEState.S_Walk"
		IEState.S_Run:         return "IEState.S_Run"
		IEState.S_Attack:      return "IEState.S_Attack"
		IEState.S_Attack_End:  return "IEState.S_Attack_End"
		IEState.S_Fire_Idle:   return "IEState.S_Fire_Idle"
		IEState.S_Fire:        return "IEState.S_Fire"
		IEState.S_Fire_End:    return "IEState.S_Fire_End"
		IEState.S_Repulse:     return "IEState.S_Repulse"
		IEState.S_Repulse_End: return "IEState.S_Repulse_End"
		IEState.S_Hit:         return "IEState.S_Hit"
		IEState.S_Hit_End:     return "IEState.S_Hit_End"
		IEState.S_Die:         return "IEState.S_Die"
		IEState.S_Die_End:     return "IEState.S_Die_End"
		_:                     return "Unknown (" + m_State.to_string() + ")"

###
# Called when an animation finished
#@param anim_name - animation name which just finished
##
func _on_animation_finished(anim_name):
	# search for finished animation, and put to end state
	if anim_name == "attack" || anim_name == "Attack":
		m_State = IEState.S_Attack_End
	elif anim_name == "fire" || anim_name == "Fire":
		m_State = IEState.S_Fire_End
	elif anim_name == "repulse" || anim_name == "Repulse":
		m_State = IEState.S_Repulse_End
	elif anim_name == "hit" || anim_name == "Hit":
		m_State = IEState.S_Hit_End
	elif anim_name == "die" ||anim_name == "Die":
		m_State = IEState.S_Die_End
