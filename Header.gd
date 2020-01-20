extends MarginContainer

onready var center_label = $BackgroundColor/HBox/CenterCanvas/CenterColorRect/CenterLabel
onready var left_label = $BackgroundColor/HBox/LeftCanvas/LeftColorRect/LeftLabel
onready var right_label = $BackgroundColor/HBox/RightCanvas/RightColorRect/RightLabel

func _ready():
	print("in header")
	
func _process(delta):
	# just an example of how to connect the values
	var max_speed = $"../../Player".X_VELO 
	left_label.text = str(max_speed)
