extends Node3D

# components
@onready var g_Highlight = $Highlight

# times
var g_FlashingTime      = 3000.0
var g_FlashingTimestamp = 0.0

###
# Called when the node enters the scene tree for the first time.
##
func _ready():
	# hide the key highlight by default
	ChangeAlpha(0)

	# set the flashing time stamp
	g_FlashingTimestamp = Time.get_ticks_msec()

###
# Called every frame
#@param delta - elapsed time in seconds since the previous call
##
func _process(delta):
	# get current time
	var curTime = Time.get_ticks_msec()

	# reset the time stamp if flashing time is exceeded
	if (curTime >= g_FlashingTimestamp + g_FlashingTime):
		g_FlashingTimestamp = curTime

	# calculate delta time in percent (between 0.0 and 1.0)
	var percent = ((curTime - g_FlashingTimestamp) / g_FlashingTime)

	# calculate and apply the highlight alpha value depending on if flashing intensity is increasing or decreasing
	if (percent >= 0.9):
		var alpha = 1 - ((percent - 0.9) * 10)
		ChangeAlpha(alpha)
	elif (percent >= 0.8):
		var alpha = (((percent + 0.1) - 0.9) * 10)
		ChangeAlpha(alpha)
	else:
		ChangeAlpha(0)

###
# Changes the highlight alpha value
#@param value - alpha value to apply, between 0.0 and 1.0
##
func ChangeAlpha(value):
	var material          = g_Highlight.mesh.surface_get_material(0)
	material.albedo_color = Color(1, 1, 1, value)
	g_Highlight.mesh.surface_set_material(0, material)
