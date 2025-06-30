extends Node3D

@onready var canvas_texture : MeshInstance3D = $painting_frame_01/canvas
# Called when the node enters the scene tree for the first time.
func _ready():
	var canvas = ImageTexture.create_from_image(GlobalState.canvas)
	canvas_texture.get_surface_override_material(0).set_texture(0,canvas)
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property($ColorRect,'modulate:a',0,4)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_main_menu_2_button_up():
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect,'modulate:a',1,0.5)
	var scene = load("res://Scenes/start.tscn")
	await tween.finished
	get_tree().change_scene_to_packed(scene)
	pass
