extends Node

@export var ball_scene: PackedScene
@export var trail_scene: PackedScene
var player_score
var opponent_score
var player_score_label
var opponent_score_label
var paint_trail_example: Sprite2D
var current_trail_texture
var paint_trails : Array
var paint_layer
var trail
var ball_instance
var paint_area
var pauseContainer
# Called when the node enters the scene tree for the first time.

signal send_opponent_info(ball_position, ball_speed)
signal send_pause()

func _ready():
	player_score = 0
	opponent_score = 0
	player_score_label = $player_score
	opponent_score_label = $opponent_score
	paint_trail_example = $paintTrailExample
	player_score_label.set_text(str(player_score))
	opponent_score_label.set_text(str(opponent_score))
	paint_trails = [
		load("res://Scenes/Sprites/paint_trail.png"),
		load("res://Scenes/Sprites/paint_trail_2.png"),
		load("res://Scenes/Sprites/paint_trail_3.png")
	]
	paint_layer = $paint_layer
	paint_area = $paint_area
	pauseContainer = $pauseContainer
	
	var new_trail = trail_scene.instantiate()
	new_trail.set_texture(paint_trails[0])
	current_trail_texture = 0
	add_child(new_trail)
	
	trail = new_trail
	ball_instance = $ball
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player_score_label.modulate.a > 0 or opponent_score_label.modulate.a > 0 or paint_trail_example.modulate.a > 0:
		await get_tree().create_timer(0.5).timeout
		player_score_label.modulate.a -= 0.01
		opponent_score_label.modulate.a -= 0.01
		paint_trail_example.modulate.a -= 0.01
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


func _on_ball_scored(side):
	
	ball_instance.queue_free()
	
	$trail_timer.stop()
	
	create_new_trail(true)
	
	if side == 0:
		opponent_score += 1
		opponent_score_label.set_text(str(opponent_score))
		opponent_score_label.modulate.a = 1
		
	else:
		player_score += 1 
		player_score_label.set_text(str(player_score))
		player_score_label.modulate.a = 1
		
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
	$trail_timer.start()
	pass


func _on_trail_timer_timeout():
	#if ball_instance:
		#trail.add_point(ball_instance.position)
	pass


func _on_paddle_hit(color, normal):
	create_new_trail(true)
	trail.default_color = color
	pass # Replace with function body.


func _on_opponent_hit(color, normal):
	create_new_trail(false)
	trail.default_color = color
	pass # Replace with function body.


func _on_opponent_timer_timeout():
	send_opponent_info.emit(round(ball_instance.position.y),ball_instance.speed)
	pass # Replace with function body.


func _on_paddle_switch_trail(l_or_r):
	if l_or_r=='l':
		current_trail_texture = (current_trail_texture + 1) % 3
	elif l_or_r=='r':
		current_trail_texture = (current_trail_texture - 1) % 3
	paint_trail_example.texture = paint_trails[current_trail_texture]
	paint_trail_example.modulate.a = 1
