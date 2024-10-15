extends MeshInstance3D

# exposed values
@export var chunk_size          = 2.0
@export var height_ratio        = 0.5
@export var colShape_size_ratio = 0.1

# components
@onready var g_ColShape = $StaticBody/Collider

# variables
var g_Image     = Image.new()
var g_HeightMap = HeightMapShape3D.new()

###
# Create a colliter matching with the terrain heightmap
#@param heightRatio - height ratio, should match with the height ratio applied to the shader
#@param sizeRatio - collision shape size ratio
##
func _create_terrain_collider(heightRatio, sizeRatio):
	# apply the same height ratio to the shader
	#mesh.material.shader.set("shader_parameters/height", heightRatio)

	# load heightmap image
	g_Image.load("res://assets/models/mountains/heightmap.exr")
	g_Image.convert(Image.FORMAT_RF)
	g_Image.resize(g_Image.get_width() * sizeRatio, g_Image.get_height() * sizeRatio)

	# get the heightmap data
	var data = g_Image.get_data().to_float32_array()

	# apply the height ratio
	for i in range(0, data.size()):
		data[i] *= heightRatio

	# configure the heightmap collider
	g_HeightMap.map_width = g_Image.get_width()
	g_HeightMap.map_depth = g_Image.get_height()
	g_HeightMap.map_data  = data

	# apply a sclae ratio to match the collider with the terrain
	var scaleRatio   = chunk_size / float(g_Image.get_width())
	g_ColShape.scale = Vector3(scaleRatio, 1, scaleRatio)

###
# Create a colliter matching with the terrain heightmap (other variant)
#@param heightRatio - height ratio, should match with the height ratio applied to the shader
#@param sizeRatio - collision shape size ratio
##
func _create_terrain_collider_v2(heightRatio, sizeRatio):
	# apply the same height ratio to the shader
	#mesh.material.set("shader_parameters/height", heightRatio)

	# load heightmap image
	g_Image.load("res://assets/models/mountains/heightmap.exr")
	g_Image.convert(Image.FORMAT_RF)
	g_Image.resize(g_Image.get_width() * sizeRatio, g_Image.get_height() * sizeRatio)

	var data: PackedFloat32Array
	var i = 0

	# build the heightmap data
	for y in g_Image.get_height():
		for x in g_Image.get_width():
			data.append(g_Image.get_pixel(x, y).r * heightRatio)
			i += 1

	# configure the heightmap collider
	g_HeightMap.map_width = g_Image.get_width()
	g_HeightMap.map_depth = g_Image.get_height()
	g_HeightMap.map_data  = data

	# apply a sclae ratio to match the collider with the terrain
	var scaleRatio   = chunk_size / float(g_Image.get_width())
	g_ColShape.scale = Vector3(scaleRatio, 1, scaleRatio)

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	# configure the collider
	g_ColShape.shape = g_HeightMap
	mesh.size        = Vector2(chunk_size, chunk_size)

	# create the terrain collider
	_create_terrain_collider(height_ratio, colShape_size_ratio)
