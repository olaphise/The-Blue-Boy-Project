extends State

#Upon entering, set owner's physics process to true, and play idle animation
func enter():
	super.enter()
	owner.set_physics_process(true)
	animation_player.play("idle_animation")
	
#Upon exiting, turn off owner's physics process
func exit():
	super.exit()
	owner.set_physics_process(false)

#If the distance < 30, transition to MeleeAttack
func transition():
	var distance = owner.direction.length()
	if distance < 30:
		get_parent().change_state("MeleeAttack")
	
	#This LaserBeam was added
	#elif distance > 130:
		#get_parent().change_state("HomingMissile")
	
	#If distance > 30: chance to switch to any of 1 states
	elif distance > 130:
		var chance = randi() % 2
		match chance:
			0:
				get_parent().change_state("HomingMissile")
			1:
				get_parent().change_state("LaserBeam")
