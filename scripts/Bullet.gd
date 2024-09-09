extends Area2D

#Get 2 nodes for sprite and player
@onready var animated_sprite = $AnimatedSprite2D
@onready var player = get_parent().find_child("player")

#Acceleration and velocity variable
var acceleration: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta):
	
	#Vector to steer towards player
	acceleration = (player.position - position).normalized() * 700
	
	#Rotate to point at player
	velocity += acceleration * delta
	rotation = velocity.angle()

	velocity = velocity.limit_length(150)
	#Updating position with velocity
	position += velocity * delta

#Upon contacting bullet, free the bullet
func _on_body_entered(body):
	queue_free()
