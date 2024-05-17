extends Node

# components
@onready var g_Player           = $Scene/Laure
@onready var g_Camera1          = $Scene/Cameras/Camera_1
@onready var g_Camera2          = $Scene/Cameras/Camera_2
@onready var g_Camera3          = $Scene/Cameras/Camera_3
@onready var g_DoorCamera       = $Scene/Environment/Door/Camera_Pivot/Door_Camera
@onready var g_DoorPlayer       = $Scene/Environment/Door/Door_Pivot/AnimationPlayer
@onready var g_DoorCameraPlayer = $Scene/Environment/Door/Camera_Pivot/AnimationPlayer
@onready var g_Label            = $User_Interface/Label
@onready var g_DoorHandleSound  = $Sounds/Door_Handle_Turns

# flags
var g_PlayerHitDoor1 = false
var g_InArea1        = true
var g_InArea2        = false
var g_InArea3        = false

# times
var g_MsgShowTime   = 2000
var g_MsgTrialStamp = 0

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
	if g_PlayerHitDoor1:
		g_MsgTrialStamp  = Time.get_ticks_msec()
		g_PlayerHitDoor1 = false

	if (Time.get_ticks_msec() >= g_MsgTrialStamp + g_MsgShowTime):
		g_Label.visible = false
	
	#if Input.is_action_pressed("player_action"):
	#	RunDoorAnim()

###
# Switches to the door camera and run the door animation
##
func RunDoorAnim():
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

	if !g_DoorHandleSound.is_playing():
		g_DoorHandleSound.play();

	# show a message to user about the door status
	g_Label.text     = "The door is closed and won't open."
	g_Label.visible  = true
	g_PlayerHitDoor1 = true

###
# Called when a body entered on the fifth trigger area
#@param body - body which entered in the area
##
func _on_trigger_5_body_entered(body):
	if body != g_Player:
		return

	RunDoorAnim()
