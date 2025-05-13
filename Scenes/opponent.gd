extends Area2D


@export var speed = 400
var screen_size
var col_height
var sprite_size
var color

signal hit(color,normal)
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	col_height = $opponent_col.shape.height/2
	sprite_size = self.scale.y
	color = Color(randf(),randf(),randf())
	$Sprite2D.self_modulate=color
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("down"):
		velocity.y += 1
	elif Input.is_action_pressed("up"):
		velocity.y -= 1
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
	position += velocity * delta
	position = position.clamp(Vector2(0,col_height*sprite_size), Vector2(screen_size.x,(screen_size.y-(col_height*sprite_size))))


func _on_area_entered(area):

	pass # Replace with function body.


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
