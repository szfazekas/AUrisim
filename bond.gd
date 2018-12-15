extends Line2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func init(from, to):
	self.points[0] = from + (to-from)/3
	#self.points[1] = (to-from)/2
	#self.points[2] = (to-from)/3
	
	self.points[1] = to - (to-from)/3


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
