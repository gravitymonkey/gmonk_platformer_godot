extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var coin = load("res://Coin.tscn")
var coin_count = 0
var coin_locations = []

# Called when the node enters the scene tree for the first time.
func _ready():
	print("world ready")
	# these coins will be added only when the previous one is taken away
	coin_locations.append(Vector2(250,100))
	coin_locations.append(Vector2(420,170))
	coin_locations.append(Vector2(550,200))
	coin_locations.append(Vector2(64,452))
	coin_locations.append(Vector2(910,500))
	place_coin()
	place_coin()
	place_coin()
	place_coin()
	place_coin()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func place_coin():
	var new_coin = coin.instance()
	new_coin.set_position(coin_locations[coin_count % coin_locations.size()])
	add_child(new_coin)	
	coin_count += 1
	
