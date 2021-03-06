extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var rotation_ang = 50
var angle_from = 75
var angle_to = 195
var center = Vector2(200, 200)
var radius = 5
var color = Color(1.0, 0.0, 0.0)

var pressed = false
var startdrag = Vector2(0,0)
var enddrag = Vector2(0,0)


func init(pos):
	center = pos

func _process(delta):
	update()

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			pressed = true
			startdrag = event.global_position
			#get_tree().set_input_as_handled()
			#print("pressed OK")
		else:
			pressed = false
	if event is InputEventMouseMotion:
		if pressed:
			enddrag = event.global_position
			center += enddrag - startdrag
			startdrag = enddrag
			#print("dragged", event.global_position, startdrag)
		else:
			pressed = false
	#update()
		



func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
func _draw():
	draw_circle(center, radius, color)
	