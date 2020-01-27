extends KinematicBody2D

const MAX_GRAVITY = 500
const FIXED_GRAVITY = 50
onready var GRAVITY = FIXED_GRAVITY
const DEFAULT_JUMP_FORCE = 350

const X_SLOWDOWN = 0.9
const X_VELO = 40
const MAX_SPEED = 200

onready var __user_state = {}
onready var MAX_JUMP = 8  # should be no lower than 5
onready var coin = 0

onready var anim_player = $AnimationPlayer
onready var sprite = $Sprite

func _ready():
	print("ready")
	__user_state["left_now"] = false
	__user_state["right_now"] = false
	__user_state["jump_now"] = false
	__user_state["climbing"] = false
	__user_state["accel"] = 0
	__user_state["jump_sum"] = 0
	__user_state["y_velocity"] = 0
	play_anim("stand")

func gather_state():	
	__user_state["is_on_floor"] = is_on_floor()
	__user_state["left_now"] = Input.is_action_pressed("move_left") 
	__user_state["right_now"] = Input.is_action_pressed("move_right") 
	__user_state["jump_now"] = Input.is_action_pressed("jump")


	# handling simple jumps only	
	# 5 seems to be the right number of max renders that captures a "tap" of up/jump buttons
	if Input.is_action_pressed("jump") && is_on_floor() && __user_state["jump_sum"] == 1:
		__user_state["y_velocity"] = -DEFAULT_JUMP_FORCE 
	elif Input.is_action_pressed("jump") && (__user_state["jump_sum"] > 5 && __user_state["jump_sum"] < MAX_JUMP):
		__user_state["y_velocity"] = -(DEFAULT_JUMP_FORCE * 0.9)

	
	if (__user_state['climbing'] == true):
		if (__user_state["jump_sum"] > 0):			
			__user_state["y_velocity"] = -1 * X_VELO
			GRAVITY = 0
		else:			
			__user_state["y_velocity"] = 0
			GRAVITY = FIXED_GRAVITY
	else:
		# default gravity behavior
		GRAVITY = FIXED_GRAVITY
		__user_state["y_velocity"] += GRAVITY
		if __user_state["y_velocity"] > MAX_GRAVITY:
			__user_state["y_velocity"] = MAX_GRAVITY
	
	return __user_state

func clear_state():

	if __user_state["left_now"] && __user_state["right_now"]:
		__user_state["accel"] = __user_state["accel"] * X_SLOWDOWN		
	else:
		if __user_state["left_now"]:
			__user_state["accel"] -= 1
			if __user_state["accel"] < -MAX_SPEED:
				 __user_state["accel"] = -MAX_SPEED
		else:
			if !__user_state["right_now"]:
				__user_state["accel"] = __user_state["accel"] * X_SLOWDOWN
	
		if __user_state["right_now"]:
			__user_state["accel"] += 1
			if __user_state["accel"] > MAX_SPEED:
				 __user_state["accel"] = MAX_SPEED
			#elif __user_state["accel"] < 0:
			#	__user_state["accel"] = __user_state["accel"] * X_SLOWDOWN
		else:
			if !__user_state["left_now"]:
				__user_state["accel"] = __user_state["accel"] * X_SLOWDOWN
			
		
	if __user_state["jump_now"]:
		__user_state["jump_sum"] += 1
	else:
		__user_state["jump_sum"] = 0
		
	pass
	
func _physics_process(delta):
	var u = gather_state()
	var current_accel = 0
	current_accel = u["accel"]
	
	if current_accel > -1.0 && current_accel < 1.0:
		current_accel = 0
	
	if current_accel == 0:
		if u["is_on_floor"]:
			play_anim("stand")
	else:
		if u["right_now"] && u["is_on_floor"]:
			if sprite.flip_h:
				sprite.flip_h = false
			play_anim("walk")		
		elif u["left_now"] && u["is_on_floor"]:
			if !sprite.flip_h:
				sprite.flip_h = true
			play_anim("walk")


	if current_accel > 0 && current_accel < X_VELO:
		current_accel = X_VELO
	elif current_accel < 0 && current_accel > -X_VELO:
		current_accel = -X_VELO
	
	# just to catch the landing from a jump
	if anim_player.current_animation == "jump" && is_on_floor():
		play_anim("stand")
	elif u["jump_sum"] == 1:
		if u["climbing"] == false:
			$"AudioJump".play()
			print(($"../Player").position)
	elif u["jump_sum"] > 1:
		if u["climbing"] == false:
			play_anim("jump")
		else:
			play_anim("climb")
	elif u["jump_sum"] == 0:
		if u["climbing"] == true:
			play_anim("hang_on")
		
		
	move_and_slide(Vector2(current_accel, u["y_velocity"]), Vector2(0,-1))
	clear_state()
	
func play_anim(anim_name):
	if anim_player.is_playing() and anim_player.current_animation == anim_name:
		return
	anim_player.play(anim_name)
	
func set_coin():
	if coin < 6: # limit to how much power we add to the jump
		MAX_JUMP = MAX_JUMP + 5
	coin += 1
	
func _on_Vine_body_entered(body):
	print("entered vine " + str(body))
	__user_state['climbing'] = true

func _on_Vine_body_exited(body):
	print("exited vine " + str(body))
	__user_state['climbing'] = false
