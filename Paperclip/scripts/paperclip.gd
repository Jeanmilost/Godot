extends Node3D

@onready var g_Model = $Model

var g_EnergyValue = 0.0

###
# Called every frame
#@param delta - the elapsed time since the previous frame
##
func _process(delta):
	g_EnergyValue = fmod(g_EnergyValue + delta, PI)
	g_Model.material_override.set_emission_energy_multiplier(sin(g_EnergyValue) + 4.0);
