extends CharacterBody2D

@onready var anim = get_node("AnimatedSprite2D")

const SPEED = 50.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var chase = false
var aggro = false

func _physics_process(delta):

	velocity.y += gravity * delta
	if aggro == true:
		chase == false
		velocity.x = 0
		anim.play("aggro_animation")
	
	elif chase == true:
		aggro == false
		if get_node("AnimatedSprite2D").animation != "death":
			anim.play("run_animation")
		player = get_node("../../Character/player")
		var direction = (player.global_position - self.global_position).normalized()
		
		if direction.x > 0:
			get_node("AnimatedSprite2D").flip_h = false
		else:
			get_node("AnimatedSprite2D").flip_h = true
		velocity.x = direction.x * SPEED
	else:
		velocity.x = 0
		anim.play("idle_animation")
	
	move_and_slide()

#CHASE DETECTION
func _on_player_detection_body_entered(body):
	if body.name == "player":
		chase = true
func _on_player_detection_body_exited(body):
	if body.name == "player":
		chase = false

#AGGRO DETECTION
func _on_aggro_detection_body_entered(body):
	if body.name == "player":
		aggro = true
func _on_aggro_detection_body_exited(body):
	if body.name == "player":
		aggro = false
