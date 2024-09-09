extends CharacterBody2D

@onready var animationSprite = $AnimatedSprite2D
@onready var animationPlayer = $AnimationPlayer
@export var bullet_node: PackedScene

const SPEED: int = 260
const JUMPVELOCITY: int = -450
const DODGEVELOCITY: int = 400
const DASHVELOCITY: int = 750
const GRAVITY: int = 1200
const FALLGRAVITY: int = 1500
const VELOCITY := Vector2.ZERO
const ACCELERATION: float = 0.05
const FRICTION: float = 1.0

var mainStateMachine: LimboHSM
var direction
var haltMovement: bool = false
var falling: bool = false
var dodging: bool = false
var dashing: bool = false
var running : bool = false
var attacking: bool = false
var canDodge: bool = true
var canMelee: bool = true
var meleeAttackAction: int = 4

func _ready():
	initiateStateMachine()
	
func _physics_process(delta):
	#print(mainStateMachine.get_active_state())
	
	velocity.y += getGravity(velocity) * delta
	
	#MOVEMENT DIRECTION + MOVEMENT FRICTION USING 'LERP'
	var direction = Input.get_axis("left_button", "right_button")
	if direction != 0:
		velocity.x = lerp(velocity.x, direction * SPEED, ACCELERATION)
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION)
	
	#ALLOWS PLAYER TO JUMP IN DIFFERENT HEIGHTS; HOLDING JUMP_BUTTON RESULTS TO MAX JUMP, QUICKLY PLRESSING JUMP_BUTTON RESULTS TO LOW JUMPS
	if Input.is_action_just_released("jump_button") && velocity.y < 0:
		velocity.y = JUMPVELOCITY / 4
	
	#TO STOP MOVEMENT OF PLAYER; CREATED MAINLY FOR MELEE AND RANGE ATTACK STATES
	if haltMovement:
		velocity.x = 0
	
	#LAUNCHES PLAYER FORWARD WHEN DODGING
	if dodging:
		velocity.x = direction * DODGEVELOCITY
		
	flipSprite(direction)
	move_and_slide()

#IMPROVING HOW GRAVITY INFLUENCES THE PLAYER WHILE JUMPING OR FALLING
func getGravity(velocity: Vector2):
	if velocity.y < 0:
		return GRAVITY
	return FALLGRAVITY

func flipSprite(direction):
	if direction == 1:
		get_node("AttackArea").set_scale(Vector2(1, 1))
		animationSprite.flip_h = false
	if direction == -1:
		get_node("AttackArea").set_scale(Vector2(-1, 1))
		animationSprite.flip_h = true

#Shoot function to spawn bullet
func shoot():
	var bullet = bullet_node.instantiate()
	bullet.position = global_position
	bullet.direction = (get_global_mouse_position() - global_position).normalized()
	get_tree().current_scene.call_deferred("add_child",bullet)
	
func _unhandled_input(event):
	if event.is_action_pressed("left_button") && animationSprite.flip_h == false && (animationSprite.animation == "run_animation" || animationSprite.animation == "idle_animation") && is_on_floor():
		mainStateMachine.dispatch(&"toTurn")
	elif event.is_action_pressed("right_button") && animationSprite.flip_h == true && (animationSprite.animation == "run_animation" || animationSprite.animation == "idle_animation") && is_on_floor():
		mainStateMachine.dispatch(&"toTurn")
	elif event.is_action_pressed("jump_button") && is_on_floor():
		mainStateMachine.dispatch(&"toJump")
	elif event.is_action_pressed("dodge_button") && canDodge && !dashing && !attacking:
		if velocity.x == 0:
			dodging = false
			mainStateMachine.dispatch(&"stateEnded")
		elif not is_on_floor():
			dodging = false
			mainStateMachine.dispatch(&"stateEnded")
		else:
			mainStateMachine.dispatch(&"toDodge")
	elif event.is_action_pressed("dash_button") && !attacking && !dodging:
		if velocity.x == 0:
			dashing = false
			mainStateMachine.dispatch(&"stateEnded")
		else:
			mainStateMachine.dispatch(&"toDash")
	elif animationSprite.animation == "dash_animation" && event.is_action_pressed("melee_attack_button") && !dodging:
		mainStateMachine.dispatch(&"toMeleeDashAttack")
	elif event.is_action_pressed("melee_attack_button") && canMelee:
		mainStateMachine.dispatch(&"toMeleeAttack")
	elif event.is_action_pressed("range_attack_button") && is_on_floor():
		mainStateMachine.dispatch(&"toRangeIdleAttack")

func initiateStateMachine():
	#STATEMACHINE SYSTEM COPIED FROM YOUTUBER DEVWORM
	mainStateMachine = LimboHSM.new()
	add_child(mainStateMachine)
	
	var idleState = LimboState.new().named("idle").call_on_enter(idleStart).call_on_update(idleUpdate)
	var runState = LimboState.new().named("run").call_on_enter(runStart).call_on_update(runUpdate)
	var turnState = LimboState.new().named("turn").call_on_enter(turnStart).call_on_update(turnUpdate)
	var jumpState = LimboState.new().named("jump").call_on_enter(jumpStart).call_on_update(jumpUpdate)
	var fallingState = LimboState.new().named("falling").call_on_enter(fallingStart).call_on_update(fallingUpdate)
	var dodgeState = LimboState.new().named("dodge").call_on_enter(dodgeStart).call_on_update(dodgeUpdate)
	var dashState = LimboState.new().named("dash").call_on_enter(dashStart).call_on_update(dashUpdate)
	var meleeAttackState = LimboState.new().named("meleeAttack").call_on_enter(meleeAttackStart).call_on_update(meleeAttackUpdate)
	var meleeDashAttackState = LimboState.new().named("meleeDashAttack").call_on_enter(meleeDashAttackStart).call_on_update(meleeDashAttackUpdate)
	var rangeIdleAttackState = LimboState.new().named("rangeIdleAttack").call_on_enter(rangeIdleAttackStart).call_on_update(rangeIdleAttackUpdate)
	
	mainStateMachine.add_child(idleState)
	mainStateMachine.add_child(runState)
	mainStateMachine.add_child(turnState)
	mainStateMachine.add_child(jumpState)
	mainStateMachine.add_child(fallingState)
	mainStateMachine.add_child(dodgeState)
	mainStateMachine.add_child(dashState)
	mainStateMachine.add_child(meleeAttackState)
	mainStateMachine.add_child(meleeDashAttackState)
	mainStateMachine.add_child(rangeIdleAttackState)
	
	mainStateMachine.initial_state = idleState
	
	mainStateMachine.add_transition(idleState, runState, &"toRun")
	mainStateMachine.add_transition(dashState, runState, &"toRun")
	mainStateMachine.add_transition(meleeAttackState, runState, &"toRun")
	mainStateMachine.add_transition(rangeIdleAttackState, runState, &"toRun")
	
	mainStateMachine.add_transition(idleState, rangeIdleAttackState, &"toRangeIdleAttack")
	mainStateMachine.add_transition(runState, rangeIdleAttackState, &"toRangeIdleAttack")
	mainStateMachine.add_transition(turnState, rangeIdleAttackState, &"toRangeIdleAttack")
	mainStateMachine.add_transition(meleeAttackState, rangeIdleAttackState, &"toRangeIdleAttack")
	
	mainStateMachine.add_transition(idleState, meleeAttackState, &"toMeleeAttack")
	mainStateMachine.add_transition(runState, meleeAttackState, &"toMeleeAttack")
	mainStateMachine.add_transition(turnState, meleeAttackState, &"toMeleeAttack")
	mainStateMachine.add_transition(rangeIdleAttackState, meleeAttackState, &"toMeleeAttack")
	
	mainStateMachine.add_transition(mainStateMachine.ANYSTATE, turnState, &"toTurn")
	mainStateMachine.add_transition(mainStateMachine.ANYSTATE, jumpState, &"toJump")
	mainStateMachine.add_transition(mainStateMachine.ANYSTATE, fallingState, &"toFall")
	mainStateMachine.add_transition(mainStateMachine.ANYSTATE, dodgeState, &"toDodge")
	mainStateMachine.add_transition(mainStateMachine.ANYSTATE, dashState, &"toDash")
	mainStateMachine.add_transition(mainStateMachine.ANYSTATE, meleeDashAttackState, &"toMeleeDashAttack")
	mainStateMachine.add_transition(mainStateMachine.ANYSTATE, idleState, &"stateEnded")
	
	mainStateMachine.initialize(self)
	mainStateMachine.set_active(true)
	
func idleStart():
	haltMovement = false
	if velocity.x == 0 && is_on_floor():
		animationSprite.play("idle_animation")
	elif not is_on_floor():
		falling = true
		mainStateMachine.dispatch(&"toFall")
	elif is_on_floor():
		falling = false
func idleUpdate(delta: float):
	if velocity.x != 0:
		mainStateMachine.dispatch(&"toRun")

func runStart():
	if is_on_floor():
		animationSprite.play("run_animation")
func runUpdate(delta: float):
	if not is_on_floor():
		mainStateMachine.dispatch(&"toFall")
	elif velocity.x == 0:
		mainStateMachine.dispatch(&"stateEnded")

func turnStart():
	pass
func turnUpdate(delta: float):
	animationSprite.play("turn_animation")
	await animationSprite.animation_finished
	mainStateMachine.dispatch(&"stateEnded")

func jumpStart():
	velocity.y = JUMPVELOCITY
	animationSprite.play("jump_animation")
func jumpUpdate(delta: float):
	if is_on_floor():
		if not is_on_floor():
			falling = true
			mainStateMachine.dispatch(&"toFall")
	else:
		mainStateMachine.dispatch(&"stateEnded")
		
func fallingStart():
	if dodging == true:
		mainStateMachine.dispatch(&"toDodge")
	elif velocity.y > 0:
		if animationSprite.animation == "dodge_animation":
			await animationSprite.animation_finished
		animationSprite.play("falling_animation")
		dodging = false
		canMelee = false
func fallingUpdate(delta: float):
	canMelee = true
	mainStateMachine.dispatch(&"stateEnded")

func dodgeStart():
	canDodge = false
	dodging = true
	$DodgeTimer.start()
func dodgeUpdate(delta: float):
	if is_on_floor():
		animationSprite.play("dodge_animation")
		await animationSprite.animation_finished
	elif not is_on_floor():
		mainStateMachine.dispatch(&"toFall")
	dodging = false
	mainStateMachine.dispatch(&"stateEnded")
	
func dashStart():
	dashing = true
	if !attacking && !dodging && velocity.x != 0:
		if animationSprite.flip_h == false:
			velocity.x = DASHVELOCITY
		elif animationSprite.flip_h == true:
			velocity.x = -DASHVELOCITY
func dashUpdate(delta: float):
	if Input.is_action_pressed("dash_button"):
		animationSprite.play("dash_animation")
		await animationSprite.animation_finished
	elif Input.is_action_just_released("dash_button"):
		mainStateMachine.dispatch(&"stateEnded")
		if animationSprite.flip_h == false:
			velocity.x = DASHVELOCITY / 4
		elif animationSprite.flip_h == true:
			velocity.x = -DASHVELOCITY / 4
	dashing = false
	mainStateMachine.dispatch(&"stateEnded")
	
func meleeAttackStart():
	if Input.is_action_just_pressed("melee_attack_button") && meleeAttackAction == 4:
		haltMovement = true
		canDodge = false
		attacking = true
		if is_on_floor():
			$MeleeAttackResetTimer.start()
			$AttackArea/MeleeAttack1.disabled = false
			animationSprite.play("melee_attack1_animation")
			await animationSprite.animation_finished
			meleeAttackAction = meleeAttackAction - 1
		canDodge = true
		haltMovement = false
	elif Input.is_action_just_pressed("melee_attack_button") && meleeAttackAction == 3:
		haltMovement = true
		canDodge = false
		attacking = true
		if is_on_floor():
			$MeleeAttackResetTimer.start()
			$AttackArea/MeleeAttack2.disabled = false
			animationSprite.play("melee_attack2_animation")
			await animationSprite.animation_finished
			meleeAttackAction = meleeAttackAction - 1
		canDodge = true
		haltMovement = false
	elif Input.is_action_just_pressed("melee_attack_button") && meleeAttackAction == 2:
		haltMovement = true
		canDodge = false
		attacking = true
		if is_on_floor():
			$MeleeAttackResetTimer.start()
			$AttackArea/MeleeAttack3.disabled = false
			animationSprite.play("melee_attack3_animation")
			await animationSprite.animation_finished
			meleeAttackAction = meleeAttackAction - 1
		canDodge = true
		haltMovement = false
	elif Input.is_action_just_pressed("melee_attack_button") && meleeAttackAction == 1:
		haltMovement = true
		canDodge = false
		attacking = true
		if is_on_floor():
			$MeleeAttackResetTimer.start()
			$AttackArea/MeleeAttack4.disabled = false
			animationSprite.play("melee_attack4_animation")
			await animationSprite.animation_finished
			meleeAttackAction = meleeAttackAction - 1
			meleeAttackAction = 4
		canDodge = true
		haltMovement = false
func meleeAttackUpdate():
	mainStateMachine.dispatch(&"stateEnded")
	
func meleeDashAttackStart():
	dashing = true
func meleeDashAttackUpdate(delta: float):
	animationSprite.play("turn_animation")
	await animationSprite.animation_finished
	dashing = false
	mainStateMachine.dispatch(&"stateEnded")
	
func rangeIdleAttackStart():
	if is_on_floor():
		shoot()
		haltMovement = true
		canDodge = false
		animationSprite.play("range_idle_attack_animation")
		await animationSprite.animation_finished
		haltMovement = false
		canDodge = true
		mainStateMachine.dispatch(&"stateEnded")
	else:
		mainStateMachine.dispatch(&"stateEnded")
func rangeIdleAttackUpdate():
	mainStateMachine.dispatch(&"stateEnded")
	
func _on_animated_sprite_2d_animation_finished():
	if animationSprite.animation == "melee_attack1_animation" || animationSprite.animation == "melee_attack2_animation" || animationSprite.animation == "melee_attack3_animation" || animationSprite.animation == "melee_attack4_animation":
		$AttackArea/MeleeAttack1.disabled = true
		$AttackArea/MeleeAttack2.disabled = true
		$AttackArea/MeleeAttack3.disabled = true
		$AttackArea/MeleeAttack4.disabled = true
		mainStateMachine.dispatch(&"stateEnded")

func _on_attack_reset_timer_timeout():
	meleeAttackAction = 4
	attacking = false
	haltMovement = false
	mainStateMachine.dispatch(&"stateEnded")

func _on_dodge_timer_timeout():
	canDodge = true
	dodging = false

func _on_melee_attack_hold_timer_timeout():
	canMelee = true
