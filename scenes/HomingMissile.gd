extends State

#1 export node, 1 flag varaible
@export var bullet_node: PackedScene
var can_transition: bool = false

#Upon entering, start ranged_attack wait for animation, then shoot
func enter():
	super.enter()
	animation_player.play("ranged_attack_animation")
	await animation_player.animation_finished
	shoot()
	can_transition = true

#Function to spawn bullet
func shoot():
	var bullet = bullet_node.instantiate()
	bullet.position = owner.position
	get_tree().current_scene.add_child(bullet)

#Transition to dash
func transition():
	if can_transition:
		can_transition = false
		get_parent().change_state("Dash")
