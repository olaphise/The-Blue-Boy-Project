extends Node2D

const SPEED: int = 60
var direction = 1

@onready var rayCastRight = $RayCastRight
@onready var rayCastLeft = $RayCastLeft
@onready var animationSprite = $AnimatedSprite2D

func _process(delta):
		
	#DEFAULT STARTING MOVEMENT
	position.x += direction * SPEED * delta
	
	#ANIMATION
	if direction:
		animationSprite.play("idle")
	elif direction == 0:
		animationSprite.play("idle")
	
	#CHANGES DIRECTION WHEN COLLIDING WITH A WALL
	if rayCastRight.is_colliding():
		direction = -1
		animationSprite.flip_h = true
	if rayCastLeft.is_colliding():
		direction = 1
		animationSprite.flip_h = false

