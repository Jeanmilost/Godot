extends Node

# components
@onready var g_Player           = $Scene/Laure
@onready var g_Camera1          = $Scene/Cameras/Camera_1
@onready var g_Camera2          = $Scene/Cameras/Camera_2
@onready var g_Camera3          = $Scene/Cameras/Camera_3
@onready var g_Camera4          = $Scene/Cameras/Camera_4
@onready var g_Key              = $Scene/Key
@onready var g_DoorCamera       = $Scene/Environment/Door/Camera_Pivot/Door_Camera
@onready var g_DoorPlayer       = $Scene/Environment/Door/Door_Pivot/AnimationPlayer
@onready var g_DoorCameraPlayer = $Scene/Environment/Door/Camera_Pivot/AnimationPlayer
@onready var g_Label            = $User_Interface/Label
@onready var g_DoorHandleSound  = $Sounds/Door_Handle_Turns
@onready var g_DoorLockedSound  = $Sounds/Door_Key_Locked
@onready var g_DoorUnlockSound  = $Sounds/Door_Key_Unlock
@onready var g_PickUpSound      = $Sounds/Pick_Up

# flags
var g_PlayerHitDoor1   = false
var g_PlayerHitDoor2   = false
var g_PlayerHitDoor3   = false
var g_InArea1          = true
var g_InArea2          = false
var g_InArea3          = false
var g_CanTakeKey       = false
var g_KeyFound         = false
var g_LabDoorUnlocking = false
var g_LabDoorUnlocked  = false
var g_ExitingRoom 	   = false

# times
var g_MsgShowTime   = 2000
var g_MsgTrialStamp = 0

# Emitted when the door opening sequence is running
signal onDoorOpening

# Emitted when the player enters or leaves the labo room
signal onPlayerEntersLaboRoom
signal onPlayerLeavesLaboRoom

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	g_Camera1.current = true
	g_Label.visible   = false

###
# Called every frame
#@param delta - elapsed time in seconds since the previous call
##
func _process(delta):
	# check if label is still visible, hide it if no
	if (Time.get_ticks_msec() >= g_MsgTrialStamp + g_MsgShowTime):
		g_Label.visible = false
		
		if g_LabDoorUnlocking:
			g_LabDoorUnlocking = false
			g_LabDoorUnlocked  = true
	
	if Input.is_action_pressed("player_action"):
		# player hits the first door?
		if g_PlayerHitDoor1:
			# play the turning door handle sound
			if !g_DoorHandleSound.is_playing():
				g_DoorHandleSound.play();

			# show a message to user about the door status
			g_Label.text     = "The door is closed and won't open."
			g_Label.visible  = true
			g_MsgTrialStamp  = Time.get_ticks_msec()

		# player hits the second door?
		if g_PlayerHitDoor2:
			# already found the key?
			if g_KeyFound:
				if g_LabDoorUnlocked:
					# run door animation
					RunDoorAnim()
				elif !g_LabDoorUnlocking:
					# play the turning door handle sound
					if !g_DoorUnlockSound.is_playing():
						g_DoorUnlockSound.play();

					# show a message to user about the door status
					g_Label.text     = "You unlocked the Laboratory door."
					g_Label.visible  = true
					g_MsgTrialStamp  = Time.get_ticks_msec()

					# notify that the door is unlocking, thus the player can enter in the door on
					# next time the action button is pressed
					g_LabDoorUnlocking = true
			else:
				# play the turning door handle sound
				if !g_DoorLockedSound.is_playing():
					g_DoorLockedSound.play();

				# show a message to user about the door status
				g_Label.text     = "You need the Laboratory key to open this door."
				g_Label.visible  = true
				g_MsgTrialStamp  = Time.get_ticks_msec()

		# player hits the room door?
		if g_PlayerHitDoor3:
			# run door animation
			RunDoorAnim()
			
			g_ExitingRoom = true

		if g_CanTakeKey && !g_KeyFound:
			# play the pick up sound
			if !g_PickUpSound.is_playing():
				g_PickUpSound.play()

			g_Label.text    = "You found the laboratory key."
			g_Label.visible = true
			g_MsgTrialStamp = Time.get_ticks_msec()
			g_Key.visible   = false
			g_KeyFound      = true

###
# Switches to the door camera and run the door animation
##
func RunDoorAnim():
	# notify all other scripts that the door is now opening
	onDoorOpening.emit()

	# show the animation camera
	g_DoorCamera.current = true
	
	# start the door animation
	if !g_DoorPlayer.is_playing():
		g_DoorPlayer.play("door_opening")
	
	# start the camera animation
	if !g_DoorCameraPlayer.is_playing():
		g_DoorCameraPlayer.play("camera_walking")

###
# Called when a body entered on the first trigger area
#@param body - body which entered in the area
##
func _on_trigger_1_body_entered(body):
	if body != g_Player:
		return

	g_Camera1.current = true
	g_InArea1         = true

###
# Called when a body exited the first trigger area
#@param body - body which exited the area
##
func _on_trigger_1_body_exited(body):
	if body != g_Player:
		return

	# quitting area 1 but still in area 2?
	if g_InArea2:
		g_Camera2.current = true

	g_InArea1 = false

###
# Called when a body entered on the second trigger area
#@param body - body which entered in the area
##
func _on_trigger_2_body_entered(body):
	if body != g_Player:
		return

	g_Camera2.current = true
	g_InArea2         = true

###
# Called when a body exited the second trigger area
#@param body - body which exited the area
##
func _on_trigger_2_body_exited(body):
	if body != g_Player:
		return

	# quitting area 2 but still in area 1?
	if g_InArea1:
		g_Camera1.current = true
	# quitting area 2 but still in area 1?
	elif g_InArea3:
		g_Camera3.current = true

	g_InArea2 = false

###
# Called when a body entered on the third trigger area
#@param body - body which entered in the area
##
func _on_trigger_3_body_entered(body):
	if body != g_Player:
		return

	g_Camera3.current = true
	g_InArea3         = true

###
# Called when a body exited the third trigger area
#@param body - body which exited the area
##
func _on_trigger_3_body_exited(body):
	if body != g_Player:
		return

	# quitting area 3 but still in area 2?
	if g_InArea2:
		g_Camera2.current = true

	g_InArea3 = false

###
# Called when a body entered on the fourth trigger area
#@param body - body which entered in the area
##
func _on_trigger_4_body_entered(body):
	if body != g_Player:
		return

	g_PlayerHitDoor1 = true

###
# Called when a body exited the fourth trigger area
#@param body - body which exited the area
##
func _on_trigger_4_body_exited(body):
	g_PlayerHitDoor1 = false

###
# Called when a body entered on the fifth trigger area
#@param body - body which entered in the area
##
func _on_trigger_5_body_entered(body):
	if body != g_Player:
		return

	g_PlayerHitDoor2 = true

###
# Called when a body exited the fifth trigger area
#@param body - body which exited the area
##
func _on_trigger_5_body_exited(body):
	g_PlayerHitDoor2 = false

###
# Called when a body entered on the sixth trigger area
#@param body - body which entered in the area
##
func _on_trigger_6_body_entered(body):
	if body != g_Player:
		return

	g_CanTakeKey = true

###
# Called when a body exited the sixth trigger area
#@param body - body which exited the area
##
func _on_trigger_6_body_exited(body):
	if body != g_Player:
		return

	g_CanTakeKey = false

###
# Called when a body entered on the seventh trigger area
#@param body - body which entered in the area
##
func _on_trigger_7_body_entered(body):
	if body != g_Player:
		return

	g_PlayerHitDoor3 = true

###
# Called when a body exited the seventh trigger area
#@param body - body which exited the area
##
func _on_trigger_7_body_exited(body):
	if body != g_Player:
		return

	g_PlayerHitDoor3 = false

###
# Called when th door animation finished
##
func _on_environment_on_door_anim_finished():
	if g_ExitingRoom:
		# place the player in the corridor
		g_Player.position.x = -2.5
		g_Player.position.z = -6.6
		g_Player.rotation.y = -deg_to_rad(270)

		# enable the third corridor camera
		g_DoorCamera.current = false
		g_Camera3.current    = true

		g_ExitingRoom = false

		onPlayerLeavesLaboRoom.emit()
	else:
		# place the player in the labo room
		g_Player.position.x = -11
		g_Player.position.z = -20
		g_Player.rotation.y = -deg_to_rad(90)

		# enable the room first camera
		g_DoorCamera.current = false
		g_Camera4.current    = true

		onPlayerEntersLaboRoom.emit()
