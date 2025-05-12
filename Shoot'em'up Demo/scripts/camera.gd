extends Camera3D

const g_ScrollEndPos = -1250

func _ready():
	position.z = -1200

###
# Called every frame
#@param delta - elapsed time in seconds since the previous frame
##
func _process(delta):
	# horizontal scroll
	if position.z > g_ScrollEndPos:
		position.z += -10 * delta;
