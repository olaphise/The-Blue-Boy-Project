extends State

#Just play the animation, thats it
func enter():
	super.enter()
	animation_player.play("death_animation")
	await animation_player.animation_finished
	animation_player.play("boss_slained_animation")
