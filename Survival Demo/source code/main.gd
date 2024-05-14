extends Node

@onready var g_Camera1          = $Scene/Cameras/Camera_1
@onready var g_Camera2          = $Scene/Cameras/Camera_2
@onready var g_DoorCamera       = $Scene/Environment/Door/Camera_Pivot/Door_Camera
@onready var g_DoorPlayer       = $Scene/Environment/Door/Door_Pivot/AnimationPlayer
@onready var g_DoorCameraPlayer = $Scene/Environment/Door/Camera_Pivot/AnimationPlayer

var g_InArea1 = true
var g_InArea2 = false

# Called when the node enters the scene tree for the first time
func _ready():
	g_Camera1.current = true

###
# Called every frame. 'delta' is the elapsed time since the previous frame.
#@param delta - elapsed time in seconds since the previous call
##
func _process(delta):
	#if g_Camera1:
		#g_Camera1.current = true

	#if $Scene/Environment/Door/Camera_Pivot/Door_Camera:
		#$Scene/Environment/Door/Camera_Pivot/Door_Camera.current = true

	if Input.is_action_pressed("player_action"):
		RunDoorAnim()

###
# Switch to the door camera and run the door animation
##
func RunDoorAnim():
	# show the animation camera
	g_DoorCamera.current = true
	
	# start the door animation
	if !g_DoorPlayer.is_playing():
		g_DoorPlayer.play("door_opening")
	
	#start the camera animation
	if !g_DoorCameraPlayer.is_playing():
		g_DoorCameraPlayer.play("camera_walking")

###
# Called when a body entered on the first trigger area
#@param body - body which entered in the area
##
func _on_trigger_1_body_entered(body):
	g_Camera1.current = true
	g_InArea1         = true

func _on_trigger_1_body_exited(body):
	# quitting area 1 but still in area 2?
	if g_InArea2:
		g_Camera2.current = true

	g_InArea1 = false

###
# Called when a body entered on the second trigger area
#@param body - body which entered in the area
##
func _on_trigger_2_body_entered(body):
	g_Camera2.current = true
	g_InArea2         = true

func _on_trigger_2_body_exited(body):
	# quitting area 2 but still in area 1?
	if g_InArea1:
		g_Camera1.current = true

	g_InArea2 = false
