extends Node2D



# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const neighborhood = [Vector2(1,0), Vector2(1,1), Vector2(0,1), Vector2(-1,0), Vector2(-1,-1), Vector2(0,-1)]


var rotation_ang = 50
var angle_from = 75
var angle_to = 195
var center = Vector2(200, 200)
var radius = 5
var color = Color(0.3, 0.5, 0.5)
var newb = 200

var unit = 100

var shear = Transform2D(Vector2(1,0), Vector2(0.5, sqrt(3)/2), Vector2(0,0))
var oldP = Vector2(0,0)
var newP = Vector2(-10000,0)
var currentP = Vector2(0,0)

var oldPP = Vector2(0,0)
var newPP = Vector2(0,0)


var beads = {}
var paths = []
var bonds = []


var pressed = false
var startdrag = Vector2(0,0)
var enddrag = Vector2(0,0)


func addBead():
	
	if not(beads.has(newPP)):
		var nodebead = load('res://bluedot.tscn').instance()
		nodebead.init(newP, unit*0.2)
		nodebead.name = 'bead_'+str(newPP.x)+'_'+str(newPP.y)
		nodebead.z_index = 2
		add_child(nodebead)
		beads[newPP] = 1
		print(nodebead.name, beads)
	
	
func delBead():
	var lt = get_children()
	var i = 0
	var tmp
	for i in lt:
		if i.name == 'bead_'+str(newPP.x)+'_'+str(newPP.y):
			tmp = i

	if tmp != null:
		self.remove_child(tmp)
		tmp.free()
		beads.erase(newPP)
	
	
func addEdge():
	var nodetrans = load('res://transcript.tscn').instance()
	nodetrans.init(oldP, newP)
	nodetrans.name = "trans "+str(oldPP.x)+","+str(oldPP.y)+"->"+str(newPP.x)+","+str(newPP.y)
	nodetrans.z_index = 1
	print(nodetrans.name)
	add_child(nodetrans)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				if event.doubleclick:
					var t = shear.affine_inverse().xform(get_transform().affine_inverse().xform(event.position))
					
					oldPP = newPP
					newPP.x = int(round(t.x/unit))
					newPP.y = int(round(t.y/unit))
					
					if not(get_parent().gui.delBtn.pressed):
						oldP = newP
						newP = shear.xform(Vector2(round(t.x/unit)*unit, round(t.y/unit)*unit))
						addBead()
						
						if (get_parent().gui.folBtn.pressed) and ((newPP-oldPP) in neighborhood):
							addEdge()
					else:
						delBead()
					
				else:
					pressed = true
					startdrag = event.position
			else:
				pressed = false
				
		elif event.button_index == BUTTON_WHEEL_UP:
			var t = get_transform()
			self.transform = Transform2D(t.x*1.02, t.y*1.02, t.origin)
			
		elif event.button_index == BUTTON_WHEEL_DOWN:
			var t = get_transform()
			self.transform = Transform2D(t.x*0.98, t.y*0.98, t.origin)
	
	if event is InputEventMouseMotion:
		if pressed:
			enddrag = event.position
			var t = get_transform()
			self.transform = Transform2D(t.x, t.y, enddrag - startdrag + t.origin)
			startdrag = enddrag
		else:
			pressed = false
			var t = shear.affine_inverse().xform(get_transform().affine_inverse().xform(event.position))
			currentP = shear.xform(Vector2(round(t.x/unit)*unit, round(t.y/unit)*unit))
	update()
	#get_tree().set_input_as_handled()


func _ready():
	print(self.get_viewport_rect().size)
	self.translate(self.get_viewport_rect().size/2)
	# Called when the node is added to the scene for the first time.
	# Initialization here
#	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _draw():
	var tx = shear.xform(Vector2(unit,0))
	var ty = shear.xform(Vector2(0,unit))
	draw_line(currentP - tx/2 - ty/2, currentP - tx/2 + ty/2, color)
	draw_line(currentP - tx/2 + ty/2, currentP + tx/2 + ty/2, color)
	draw_line(currentP + tx/2 + ty/2, currentP + tx/2 - ty/2, color)
	draw_line(currentP + tx/2 - ty/2, currentP - tx/2 - ty/2, color)
	
	draw_circle(currentP, unit/4, color)
