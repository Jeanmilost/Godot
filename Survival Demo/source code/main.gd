extends Node

@onready var g_Camera1    = $Scene/Camera
@onready var g_DoorCamera = $Scene/Environment/Door/Camera_Pivot/Door_Camera

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if g_Camera1:
		#g_Camera1.current = true

	#if $Scene/Environment/Door/Camera_Pivot/Door_Camera:
		#$Scene/Environment/Door/Camera_Pivot/Door_Camera.current = true

	if Input.is_action_pressed("player_action"):
		RunDoorAnim()

# Run the door animation, which links 
func RunDoorAnim():
	# show the animation camera
	$Scene/Environment/Door/Camera_Pivot/Door_Camera.current = true
	
	# start the door animation
	if !$Scene/Environment/Door/Door_Pivot/AnimationPlayer.is_playing():
		$Scene/Environment/Door/Door_Pivot/AnimationPlayer.play("door_opening")
	
	#start the camera animation
	if !$Scene/Environment/Door/Camera_Pivot/AnimationPlayer.is_playing():
		$Scene/Environment/Door/Camera_Pivot/AnimationPlayer.play("camera_walking")
