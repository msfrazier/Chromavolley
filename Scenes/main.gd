extends Node

@export var ball_scene: PackedScene
@export var trail_scene: PackedScene
@export var score_goal: int
@export var paint_goal : float
@export var volley_limit : float

#@onready var colored_pixels = 0

var player_score
var opponent_score
var player_score_label
var opponent_score_label
var fade_tween : Tween
var camera : Camera2D
var paint_trail_example: Sprite2D
var current_trail_texture
var paint_trails : Array
var trail
var ball_instance
var paint_area : Area2D
var pauseContainer
var img : Image
var rd : RenderingDevice
var animation_player : AnimationPlayer

var rect
var top_l 
var bottom_r
var total_pixels
var pixel_count_thread : Thread
# Called when the node enters the scene tree for the first time.

signal send_opponent_info(ball_position, ball_speed)
signal send_pause()
signal check_color_percentage

func _ready():
	rd = RenderingServer.get_rendering_device()
	player_score = 0
	opponent_score = 0
	player_score_label = $player_score
	opponent_score_label = $opponent_score
	paint_trail_example = $paintTrailExample
	animation_player = $AnimationPlayer
	player_score_label.set_text(str(player_score))
	opponent_score_label.set_text(str(opponent_score))
	paint_trails = [
		load("res://Scenes/Sprites/paint_trail.png"),
		load("res://Scenes/Sprites/paint_trail_2.png"),
		load("res://Scenes/Sprites/paint_trail_3.png")
	]
	paint_area = $paint_area
	pauseContainer = $pauseContainer
	
	rect = $paint_area/CollisionShape2D.shape.get_rect()
	top_l = rect.position + paint_area.position
	bottom_r = rect.end + paint_area.position
	
	if GlobalState.score_goal != -1:
		score_goal = GlobalState.score_goal
		
	if GlobalState.paint_goal != -1:
		paint_goal = GlobalState.paint_goal/100
		volley_limit = GlobalState.volley_limit
		
		print(rect)
		print(top_l)
		print(bottom_r)
		
		total_pixels = (bottom_r.x - top_l.x) * (bottom_r.y - top_l.y)

		pixel_count_thread = Thread.new()

	
	var new_trail = trail_scene.instantiate()
	new_trail.set_texture(paint_trails[0])
	current_trail_texture = 0
	add_child(new_trail)
	
	trail = new_trail
	ball_instance = $ball
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if ball_instance != null and ball_instance.velocity.length()>0 and paint_area.overlaps_area(ball_instance):
		trail.add_point(ball_instance.position)
	if Input.is_action_just_pressed("pause"):
		player_score_label.modulate.a = 1
		opponent_score_label.modulate.a = 1
		send_pause.emit()
		get_tree().paused = true
	pass
	
func create_new_trail(player_hit):
	
	var new_trail = trail_scene.instantiate()
	if player_hit:
		new_trail.set_texture(paint_trails[current_trail_texture])
	else:
		new_trail.set_texture(trail.get_texture())
	add_child(new_trail)
	trail = new_trail
	
	pass

func fade(type:String):
	fade_tween = get_tree().create_tween().set_parallel(true)
	if type=="out":
		fade_tween.tween_property(player_score_label,"modulate:a",0,1)
		fade_tween.tween_property(opponent_score_label,"modulate:a",0,1)
		fade_tween.tween_property(paint_trail_example,"modulate:a",0,1)
		
	elif type == "in":
		fade_tween.tween_property(player_score_label,"modulate:a",1,1)
		fade_tween.tween_property(opponent_score_label,"modulate:a",1,1)
		fade_tween.tween_property(paint_trail_example,"modulate:a",1,1)
	pass
	
func return_to_main_menu():
	var game_scene = load("res://Scenes/start.tscn")
	GlobalState.paint_goal = -1
	GlobalState.score_goal = -1
	GlobalState.volley_limit = -1
	GlobalState.current_level = ""
	get_tree().change_scene_to_packed(game_scene)
	
func finished(won:bool):
	print(rect.position+paint_area.position)
	var end_screen = get_viewport().get_texture().get_image().get_region(
		Rect2(
			rect.position+paint_area.position,
			rect.size
		)
	)
	end_screen.save_png("finished.png")
	GlobalState.canvas = end_screen
	var end_scene : PackedScene
	if won:
		$finished_label.set_text("Success!")
	else:
		$finished_label.set_text("Failure...")
		end_scene = load("res://Scenes/alley_scene.tscn")
	var tween = get_tree().create_tween().set_parallel(true)
	camera = Camera2D.new()
	paint_area.add_child(camera)
	tween.tween_property(camera,"zoom",Vector2(2,2),1).set_trans(Tween.TRANS_QUAD)
	tween.tween_property($finished_label,"visible_ratio",1,2)
	await tween.finished
	animation_player.play("fade_out")
	await animation_player.animation_finished
	print("done2")
	get_tree().change_scene_to_packed(end_scene)
	pass

func _on_ball_scored(side):
	
	ball_instance.queue_free()
	
	create_new_trail(true)
	
	if side == 0:
		opponent_score += 1
		opponent_score_label.set_text(str(opponent_score))
		opponent_score_label.modulate.a = 1
		
	else:
		player_score += 1 
		player_score_label.set_text(str(player_score))
		player_score_label.modulate.a = 1
	
	
	if score_goal != -1:
		if player_score == score_goal:
			finished(true)
			return true
		
		elif opponent_score == score_goal:
			finished(false)
			return true
			
	elif paint_goal != -1:
		
		if player_score + opponent_score >= volley_limit:
			$color_check_timer.stop()
			print("Failure...")
			finished(false)
			return true
			
		
		
	var ball = ball_scene.instantiate()
	
	ball.position = Vector2(576,324)
	ball.scale = Vector2(0.105,0.105)
	ball.name = "ball"
	
	$start_timer.timeout.connect(ball._on_start_timer_timeout)
	$paddle.hit.connect(ball._on_paddle_hit)
	$opponent.hit.connect(ball._on_paddle_hit)
	
	ball.send_opponent_info.connect($opponent._on_ball_send_opponent_info)
	ball.scored.connect(self._on_ball_scored)
	
	add_child(ball,true)
	
	ball_instance = ball
	
	$start_timer.start()


func _on_start_timer_timeout():

	fade("out")
	if paint_goal != -1:
		$color_check_timer.start()
	
	pass

func _on_paddle_hit(color, normal):
	create_new_trail(true)
	trail.default_color = color
	pass # Replace with function body.


func _on_opponent_hit(color, normal):
	create_new_trail(false)
	trail.default_color = color
	pass # Replace with function body.


func _on_paddle_switch_trail(l_or_r):
	if l_or_r=='l':
		current_trail_texture = (current_trail_texture + 1) % 3
	elif l_or_r=='r':
		current_trail_texture = (current_trail_texture - 1) % 3
	paint_trail_example.texture = paint_trails[current_trail_texture]
	paint_trail_example.modulate.a = 1


func _on_check_color_percentage(img):
	var colored_pixels = 0
	var ratio = colored_pixels/total_pixels
	#await RenderingServer.frame_post_draw
	for x in range(top_l.x,bottom_r.x,4):
			for y in range(top_l.y,bottom_r.y,4):
				var pixel = img.get_pixel(x,y)
				if pixel.r<0.95 or pixel.b<0.95 or pixel.g<0.95:
					colored_pixels += 1
	ratio = (colored_pixels)/(total_pixels/16)
	#print("ratio: ", ratio)
	if ratio < paint_goal:
		pass
	else:
		print("Finished")
		GlobalState.completed_levels.append(GlobalState.current_level)
		return_to_main_menu()

	pass # Replace with function body.
