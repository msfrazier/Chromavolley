extends CharacterBody2D


@export var speed =400
var screen_size
var col_height
var sprite_size
var color
var future_location
var desired_location
var position_range


signal hit(color,normal)
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	col_height = $opponent_col.shape.height/2
	sprite_size = self.scale.y
	color = Color(randf(),randf(),randf())
	future_location = 324
	desired_location = 324
	position_range = range(0,screen_size.y)
	$Sprite2D.self_modulate=color
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
	
func _physics_process(delta):
	
	velocity = Vector2.ZERO

	if is_equal_approx(position.y,desired_location):
		velocity=Vector2.ZERO
	elif position.y < desired_location-(speed/100):
		velocity.y += 1
	elif position.y > desired_location+(speed/100):
		velocity.y -= 1
	else:
		velocity = Vector2.ZERO
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	#print("final velocity: ", velocity)
	position = position.clamp(Vector2(0,col_height*sprite_size), Vector2(screen_size.x,(screen_size.y-(col_height*sprite_size))))
	move_and_slide()
	
func _on_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	var ball_shape = area.shape_owner_get_owner(area.shape_find_owner(area_shape_index))
	var collision_points = $opponent_col.shape.collide_and_get_contacts(
		$opponent_col.global_transform,
		ball_shape.shape,
		ball_shape.global_transform
		)
	var normal = (collision_points[1]-collision_points[0]).normalized()
	
	hit.emit(color,normal)
	color = Color(randf(),randf(),randf())
	$Sprite2D.self_modulate=color
	pass # Replace with function body.


func _on_main_send_opponent_info(ball_position, ball_speed):
	#future_location = round(ball_position)
	#if position_range.has(future_location):
		#pass
	#else:
		#position_range = range(
			#round(future_location-(col_height*sprite_size)),
			#round(future_location+(col_height*sprite_size))
			#)
		#desired_location = position_range.pick_random()
	#
	#speed = ball_speed
	
	pass

	#print(round(future_location-(col_height*sprite_size)))
	#print(round(future_location+(col_height*sprite_size)))


func _on_ball_send_opponent_info(pos):
	desired_location = pos.y
	desired_location = clampf(desired_location,0,screen_size.y)
	print("desired_location ", desired_location)
	pass # Replace with function body.
