extends Area2D

onready var audio = $"AudioPlayer"
var consumed = false

func _ready():
	pass

func _process(delta):
	if consumed && !audio.playing:
		queue_free()
	pass


func _on_Coin_body_entered(body):
	print("on coin entered " + str(body))
	$"../Player".set_coin()
	audio.play()
	consumed = true
