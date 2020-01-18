extends KinematicBody2D

const MAX_GRAVITY = 500
const GRAVITY = 50
const DEFAULT_JUMP_FORCE = 350

const X_SLOWDOWN = 0.9
const X_VELO = 40
const MAX_SPEED = 200
const COUNT_DEPRESSED = 30 
var ACCEL_FACTOR = 20 #lower is faster

onready var __user_state = {}

onready var anim_player = $AnimationPlayer
onready var sprite = $Sprite

func _ready():
	print("ready")
	__user_state["left_now"] = false
	__user_state["right_now"] = false
	__user_state["jump_now"] = false
	__user_state["accel"] = 0
	__user_state["jump_sum"] = 0
	__user_state["y_velocity"] = 0
	play_anim("stand")

func gather_state():	
	__user_state["is_on_floor"] = is_on_floor()
	__user_state["left_now"] = Input.is_action_pressed("move_left") 
	__user_state["right_now"] = Input.is_action_pressed("move_right") 
	__user_state["jump_now"] = Input.is_action_pressed("jump")
	
	# default gravity behavior
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
	
	if u["right_now"] && u["is_on_floor"]:
		if sprite.flip_h:
			sprite.flip_h = false
		play_anim("walk")		
	elif u["left_now"] && u["is_on_floor"]:
		if !sprite.flip_h:
			sprite.flip_h = true
		play_anim("walk")
		
	
		
	if current_accel == 0:
		if u["is_on_floor"]:
			play_anim("stand")
				
						
	var x_velocity = 0

	if current_accel > 0 && current_accel < X_VELO:
		current_accel = X_VELO
	elif current_accel < 0 && current_accel > -X_VELO:
		current_accel = -X_VELO
	
		
	x_velocity = current_accel
	
	# just to catch the landing from a jump
	if anim_player.current_animation == "jump" && is_on_floor():
		play_anim("stand")
			
	# handling simple jumps only	
	if Input.is_action_pressed("jump") && is_on_floor():
		u["y_velocity"] = -DEFAULT_JUMP_FORCE 
		play_anim("jump")
	elif Input.is_action_pressed("jump") && (u["jump_sum"] > 5 && u["jump_sum"] < 10):
		u["y_velocity"] = -DEFAULT_JUMP_FORCE 
		play_anim("jump")
	print(u["y_velocity"])
			
	move_and_slide(Vector2(x_velocity, u["y_velocity"]), Vector2(0,-1))
	clear_state()
	
func play_anim(anim_name):
	if anim_player.is_playing() and anim_player.current_animation == anim_name:
		return
	anim_player.play(anim_name)