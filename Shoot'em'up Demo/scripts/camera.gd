extends Camera3D

###
# Called every frame
#@param delta - elapsed time in seconds since the previous frame
##
func _process(delta):
	# horizontal scroll
	position.z += -10 * delta;
