extends Line2D

var ends = []
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

#func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
#	pass

func init(from, to):
	ends = [from, to]
	self.points[0] = from + (to-from)/4
	self.points[1] = to - (to-from)/4


func initZig(from, to):
	ends = [from, to]
	width = 4
	points[0] = from + (to-from)/4
	points[1] = from + ((to-from)/2.5).rotated(PI/24)
	add_point(to - ((to-from)/2.5).rotated(PI/24))
	add_point(to - (to-from)/4)
	#self.points[0] = from + (to-from)/4
	
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
