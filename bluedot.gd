extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var rotation_ang = 50
var angle_from = 75
var angle_to = 195
var center = Vector2(200, 200)
var radius = 5
var color = Color(0.0, 0.0, 1.0)
var label = ''

var pressed = false
var startdrag = Vector2(0,0)
var enddrag = Vector2(0,0)
var arial = load('res://arial.tres')
var arialshift = Vector2(arial.get_ascent()/3.5, -arial.get_ascent()/2.5)

var previous = null
var next = null
var bonds = []



func init(pos, r, l):
	center = pos
	radius = r
	label = l
	#draw_circle(center, r, color)
#func _process(delta):
	#update()

#func _input(event):
#	#update()
		



func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
func _draw():
	#var arial = load('res://arial.tres')
	draw_circle(center, radius, color)
	draw_string(arial, center-arialshift, label)
	