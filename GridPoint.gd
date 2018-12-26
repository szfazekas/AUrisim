extends Polygon2D


export var sizex = Vector2(5,0)
export var sizey = Vector2(0,5)
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func init(pos):
	self.polygon = [pos - sizex, pos - sizey, pos + sizex, pos + sizey]

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

#func _draw():
#	pass