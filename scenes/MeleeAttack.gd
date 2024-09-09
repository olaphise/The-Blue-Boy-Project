extends State

#On entering, start melee_attack_animation
func enter():
	super.enter()
	animation_player.play("melee_attack_animation")

#Transition back to Follow, if distance > 30
func transition():
	if owner.direction.length() > 30:
		get_parent().change_state("Follow")
