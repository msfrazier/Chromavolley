extends Node

var animation_player
var ImgA
var ImgB
var menu_images : Array
var position_options : Array
var menu_animation : Animation
var changing_img

var startButton : TextureButton
var exitButton : TextureButton
var classicModeButton : TextureButton
var classicPlayButton : TextureButton

var menu_tween_speed := 0.3

@onready var score_slider := $scoreSlider
@onready var slider_score := $scoreSlider/Label

#var from
#var to
#var from_next

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player = $AnimationPlayer
	ImgA = $ImgA
	ImgB = $ImgB
	startButton = $startButton
	exitButton = $exitButton
	classicModeButton = $classicModeButton
	classicPlayButton = $classicPlayButton
	slider_score.text = str(score_slider.value)
	changing_img = "A"
	menu_animation = animation_player.get_animation("ImgA")
	menu_images = [
		"res://Scenes/Sprites/images/Elioth_Gruner_-_Spring_frost_-_Google_Art_Project.jpg",
		"res://Scenes/Sprites/images/jan-vermeer-van-delft-the-glass-of-wine-google-art-project.jpg!HalfHD.jpg",
		"res://Scenes/Sprites/images/the_shipwreck_2000.22.1.png",
		"res://Scenes/Sprites/images/ram-s-head-white-hollyhock-hills-1935.jpg!Large.jpg",
		"res://Scenes/Sprites/images/sketch-with-many-figures-for-sunday-afternoon-on-grande-jatte-1884(1).jpg!HalfHD.jpg",
		"res://Scenes/Sprites/images/putti-detail-from-the-sistine-madonna-1513.jpg!Large.jpg",
		"res://Scenes/Sprites/images/impression-sunrise.jpg!Large.jpg",
		"res://Scenes/Sprites/images/000.jpg!Large.jpg",
		"res://Scenes/Sprites/images/the-birth-of-venus-1485(1).jpg!Large.jpg",
		"res://Scenes/Sprites/images/the-burning-of-a-turkish-frigate(3).jpg!Large.jpg",
		"res://Scenes/Sprites/images/the-great-wave-off-kanagawa.jpg!Large.jpg",
		
	]
	position_options = [
		Vector2(0,0),
		Vector2(-333,-183),
		Vector2(-152,-183),
		Vector2(0,-183),
		Vector2(-333,0),
		Vector2(-152,0),
	]
	#position_options.shuffle()
	menu_images.shuffle()
	ImgA.texture = load(menu_images.pick_random())
	ImgB.texture = load(menu_images.pick_random())
	animation_player.play("ImgA")
	animation_player.animation_set_next("ImgA","ImgA")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass


func _on_animation_player_animation_finished(anim_name):
	animation_player.play("ImgA")
	pass # Replace with function body.
	



func _on_timer_timeout():
	if changing_img == "A":
		changing_img = "B"
		var to = position_options.pop_front()
		var temp = position_options.pop_front()
		position_options.push_back(to)
		position_options.push_back(temp)
		menu_animation.track_set_key_value(0,2,to)
		menu_animation.track_set_key_value(0,0,to)
		var new_image = menu_images.pop_front()
		ImgA.texture = load(new_image)
		menu_images.push_back(new_image)
	else:
		changing_img = "A"
		var to = position_options.pop_front()
		var temp = position_options.pop_front()
		position_options.push_back(to)
		position_options.push_back(temp)
		menu_animation.track_set_key_value(2,2,to)
		menu_animation.track_set_key_value(2,0,to)
		var new_image = menu_images.pop_front()
		ImgB.texture = load(new_image)
		menu_images.push_back(new_image)
	pass

func _on_exit_button_button_up():
	get_tree().quit()
	pass # Replace with function body.


func _on_start_button_button_up():
	classicModeButton.show()
	$paintModeButton.show()
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(startButton,"position",Vector2(1160,240),menu_tween_speed)
	tween.tween_property(exitButton,"position",Vector2(-270,430),menu_tween_speed)
	await tween.finished 
	var tween2 = get_tree().create_tween().set_parallel(true)
	tween2.tween_property(classicModeButton,"position",Vector2(440,240),menu_tween_speed)
	tween2.tween_property($paintModeButton, "position", Vector2(440, 430), menu_tween_speed)
	pass # Replace with function body.


func _on_classic_mode_button_button_up():
	
	score_slider.show()
	classicPlayButton.show()
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(classicModeButton,"position",Vector2(-270,240),menu_tween_speed)
	tween.tween_property($paintModeButton, "position", Vector2(1165, 430), menu_tween_speed)
	await tween.finished
	classicModeButton.hide()
	$paintModeButton.hide()
	var tween2 = get_tree().create_tween().set_parallel(true)
	tween2.tween_property($classicScoreLabel,"position",Vector2(89,152),menu_tween_speed)
	tween2.tween_property(score_slider, "position", Vector2(354,336),menu_tween_speed)
	tween2.tween_property(classicPlayButton,"position",Vector2(440,430),menu_tween_speed)
	pass # Replace with function body.



func _on_score_slider_value_changed(value):
	slider_score.set_text(str(value))
	pass # Replace with function body.


func _on_classic_play_button_button_up():
	var game_scene= load("res://Scenes/main.tscn")
	GlobalState.score_goal = score_slider.value
	get_tree().change_scene_to_packed(game_scene)
	pass # Replace with function body.
