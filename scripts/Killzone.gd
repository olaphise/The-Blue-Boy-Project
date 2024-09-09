extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	print("Game Over")
	#SLOWS DOWN THE ENTIRE GAME; USED HERE AS A SLOW MOTION EFFECT WHEN DYING
	Engine.time_scale = 0.5
	#BODY -- AS IN THE PLAYER -- 's COLLISIONSHAPE2D IS REFERRED AND DESTROYED?; THIS RESULTS TO "PLAYER-CLIPPING-THROUGH-THE-MAP-WHEN-DYING EFFECT"
	body.get_node("CollisionShape2D").queue_free()
	timer.start()

func _on_timer_timeout():
	#RETURN TO DEFAULT ENGINE TIME SCALE
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
