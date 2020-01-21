extends Area2D

onready var audio = $"./CollisionShape2D/AudioPlayer"
var consumed = false

func _ready():	
	pass

func _process(delta):
	if consumed && !audio.playing:
		$"../../World".place_coin()
		queue_free()
	pass


func _on_Coin_body_entered(body):
	if !consumed:
		print("on coin entered " + str(body))
		$"./CollisionShape2D/Sprite".visible = false
		$"../Player".set_coin()
		audio.play()
	consumed = true
