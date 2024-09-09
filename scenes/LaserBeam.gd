extends State

#Drag and drop Pivot
@onready var pivot = $"../../Pivot"
#Flag variable
var can_transition: bool = false

#On enter play laser_cast_animation, laser_animation
func enter():
	super.enter()
	await play_animation("laser_cast_animation")
	await play_animation("laser_animation")
	can_transition = true

#Function to play animation and await
func play_animation(anim_name):
	animation_player.play(anim_name)
	await animation_player.animation_finished

#set_target function to aim at player
func set_target():
	pivot.rotation = (owner.direction - pivot.position).angle()
	#Go to laser_animation in AnimationPlayer, go 2 frames before the laser shooting frame of the animation, Add track > Call Method track > LaserBeam >  insert key frame > select set_target
	
#Dash at the end
func transition():
	if can_transition:
		can_transition = false
		get_parent().change_state("Dash")
