extends KinematicBody2D

const MAX_GRAVITY = 500
const GRAVITY = 15
const DEFAULT_JUMP_FORCE = 200
const X_SLOWDOWN = 0.9
const X_VELO = 80
const COUNT_DEPRESSED = 30 
var ACCEL_FACTOR = 20 #lower is faster
var y_velocity = 0
var current_accel = 0


onready var anim_player = $AnimationPlayer
onready var sprite = $Sprite


# Called when the node enters the scene tree for the first time.
func _ready():
	print("ready")
	play_anim("stand")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	y_velocity += GRAVITY
	if y_velocity > MAX_GRAVITY:
		y_velocity = MAX_GRAVITY

	
	if Input.is_action_pressed("move_left") && is_on_floor():
		current_accel += -1
	elif Input.is_action_pressed("move_right") && is_on_floor():
		current_accel += 1
	#elif (Input.is_action_just_released("move_left") || Input.is_action_just_released("move_right")) && is_on_floor():		
	#	if current_accel < COUNT_DEPRESSED && current_accel > -COUNT_DEPRESSED:
			# count depressed is the minimal amount of concurrent X or Y 
			# we need to have extra speed; without more than it, just shut down to 0
	#		current_accel = 0
	#		play_anim("stand")
	
	if current_accel != 0:
		if (current_accel < 1.0 && current_accel > -1.0):
			current_accel = 0
		else:
			if !Input.is_action_pressed("move_left") && !Input.is_action_pressed("move_right"):
				current_accel = current_accel * X_SLOWDOWN
						
		if !is_on_floor():
			# so keep going in the given direction, but slow down, while still in the air
			play_anim("jump")
		elif is_on_floor():
			if current_accel == 0:
				play_anim("stand")
			else:
				play_anim("walk")			
						
	var x_velocity = 0

	var dir_flag = 0 # direction
	var speed_mult = 1  # should increase the longer you've held the button down
	if current_accel > 0:
		dir_flag = 1
	elif current_accel < 0:
		dir_flag = -1
		
#	if abs(current_accel) > 10:
	speed_mult = 1.0 + ((abs(current_accel) - 10)/ACCEL_FACTOR)
	if speed_mult > 3:
		speed_mult = 3
	x_velocity = (X_VELO * speed_mult) * dir_flag
#	x_velocity = X_VELO * dir_flag
	
	if x_velocity < 0:
		if !sprite.flip_h:
			sprite.flip_h = true
		play_anim("walk")
	elif x_velocity > 0: 
		if sprite.flip_h:
			sprite.flip_h = false
		play_anim("walk")
	else:
		# just to catch the landing from a jump
		if anim_player.current_animation == "jump" && is_on_floor():
			play_anim("stand")
			
	# handling simple jumps only	
	if Input.is_action_pressed("jump") && is_on_floor():
		y_velocity = -DEFAULT_JUMP_FORCE 
		if speed_mult > 1:
			y_velocity = y_velocity * speed_mult 
		play_anim("jump")
			
		
	move_and_slide(Vector2(x_velocity, y_velocity), Vector2(0,-1))
	
func play_anim(anim_name):
	if anim_player.is_playing() and anim_player.current_animation == anim_name:
		return
	anim_player.play(anim_name)