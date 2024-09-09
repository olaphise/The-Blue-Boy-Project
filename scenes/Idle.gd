extends State

@onready var collision = $"../../PlayerDetection/CollisionShape2D"
@onready var progress_bar = owner.find_child("ProgressBar")

#Declare player_entered flag variable, and make it a setter function
var player_entered: bool = false:
	set(value):
		player_entered = value
		collision.set_deferred("disabled", value)
		progress_bar.set_deferred("visible", value)
		
#If player enters, transition to Follow State
func transition():
	if player_entered:
		get_parent().change_state("Follow")

#Body entered signal connected to Idle
#Upon entering, we will set player_entered to true
func _on_player_detection_body_entered(body):
	player_entered = true
