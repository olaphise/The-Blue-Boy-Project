extends State

#Declare flag variable
var can_transition: bool = false

#Play armor_buff_animation
func enter():
	super.enter()
	animation_player.play("armor_buff_animation")
	await animation_player.animation_finished
	can_transition = true

#Transition back to Follow
func transition():
	if can_transition:
		can_transition = false
		get_parent().change_state("Follow")
