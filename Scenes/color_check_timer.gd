extends Timer

signal check_color_percentage(img)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timeout():
	var tex = get_viewport().get_texture()
	var img = tex.get_image()
	#check_color_percentage.emit(img)
	check_color_percentage.emit(img)
	pass # Replace with function body.
