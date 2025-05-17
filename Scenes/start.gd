extends Node

var animation_player

# Called when the node enters the scene tree for the first time.
func _ready():
	var animation_player = $AnimationPlayer
	animation_player.play("ImgA")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
