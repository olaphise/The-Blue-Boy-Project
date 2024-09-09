extends Node

#Declare two variables
var current_state: State
var previous_state: State

#On ready, we will start with first/idle state
func _ready():
	current_state = get_child(0) as State
	previous_state = current_state
	current_state.enter()

#Function to change state
func change_state(state):
	current_state = find_child(state) as State
	current_state.enter()
	
	previous_state.exit()
	previous_state = current_state
