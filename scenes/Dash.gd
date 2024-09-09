extends State

#Flag varaible
var can_transition: bool = false

#Play glowing upon entering dash and change flag
func enter():
	super.enter()
	animation_player.play("glowing_animation")
	await dash()
	can_transition = true
	
#Dash function to tween position
func dash():
	var tween = create_tween()
	tween.tween_property(owner, "position", player.position, 0.8)
	await tween.finished

#Transition back to Follow
func transition():
	if can_transition:
		can_transition = false
		get_parent().change_state("Follow")
