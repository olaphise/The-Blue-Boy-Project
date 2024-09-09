extends CharacterBody2D

#Get the player and sprite node
@onready var player = get_parent().find_child("player")
@onready var sprite = $Sprite2D
@onready var progress_bar = $UI/ProgressBar

#Direction variable
#Update progress bar, using setter variable
var direction : Vector2
#Declare DEF
var DEF = 0

var health = 100:
	set(value):
		health = value
		progress_bar.value = value
		#If health < 0: switch to Death
		if value <= 0:
			progress_bar.visible = false
			find_child("FiniteStateMachine").change_state("Death")
		#If health < 50%: switch to ArmorBuff
		elif value <= progress_bar.max_value / 2 and DEF == 0:
			DEF = 5
			find_child("FiniteStateMachine").change_state("ArmorBuff")


#Turn off physics process right away
func _ready():
	set_physics_process(false)

#Updating direction with player position
func _process(delta):
	direction = player.position - position

#Flipping direction, towards player
	if direction.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

#Set motion in physics process
func _physics_process(delta):
	velocity = direction.normalized() * 40
	move_and_collide(velocity * delta)
	
#Function that will decrease health
func take_damage():
	health -= 10 - DEF
