extends Node3D

# Emitted when the door animation reached the end
signal onDoorAnimFinished

###
# Called when the door animation ends
#@param anim_name - animation name which reached the end
##
func _on_animation_player_animation_finished(anim_name):
	# notify all other scripts that the door animation reached the end
	onDoorAnimFinished.emit()
