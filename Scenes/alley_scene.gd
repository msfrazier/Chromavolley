extends Node3D

@onready var canvas_texture : MeshInstance3D = $painting_frame_01/canvas
# Called when the node enters the scene tree for the first time.
func _ready():
	var canvas = ImageTexture.create_from_image(GlobalState.canvas)
	canvas_texture.get_surface_override_material(0).set_texture(0,canvas)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
