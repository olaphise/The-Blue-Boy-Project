extends Node2D
class_name State

#Get debug, player and animation player node
@onready var debug = owner.find_child("debug")
@onready var player = owner.get_parent().find_child("player")
@onready var animation_player = owner.find_child("AnimationPlayer")

#Turn off physics process
func _ready():
	set_physics_process(false)

#We will turn on/off using functions
func enter():
	set_physics_process(true)
	
func exit():
	set_physics_process(false)

#Transition will have condition to switch between states
func transition():
	pass

#Transition will be running on physics process
func _physics_process(delta):
	transition()
	debug.text = name
