extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
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


var pressed = false
var startdrag = Vector2(0,0)
var enddrag = Vector2(0,0)


func addBead():
	
	
	#print(oldP, canvX, canvY)
	var nodebead = load('res://blueball.tscn').instance()
	nodebead.init(newP)
	nodebead.name = 'bead_'+str(newPP.x)+'_'+str(newPP.y)
	add_child(nodebead)
	print(nodebead.name)
	
	
func delBead():
	var lt = get_children()
	var i = 0
	var tmp
	for i in lt:
		if i.name == 'bead_'+str(newPP.x)+'_'+str(newPP.y):
			tmp = i
		#print(i.name)
	#print("bead_"+str(newPP.x)+"_"+str(newPP.y))
	#var tmp = self.find_node("bead_"+str(newPP.x)+"_"+str(newPP.y))
	#print(find_node('bead*'))
	if tmp != null:
		self.remove_child(tmp)
		tmp.free()
	
	
func addEdge():
	var nodetrans = load('res://transcript.tscn').instance()
	nodetrans.init(oldP, newP)
	nodetrans.name = "trans "+str(oldPP.x)+","+str(oldPP.y)+"->"+str(newPP.x)+","+str(newPP.y)
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
						#print(get_parent().gui.delBtn.pressed, get_parent().canvas, self)
						oldP = newP
						newP = shear.xform(Vector2(round(t.x/unit)*unit, round(t.y/unit)*unit))
						addBead()
						
						if oldP.x!=-10000:
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
			#self.transform = Transform2D(Vector2(1,0), Vector2(0,1), get_child(0).get_camera_position())
			startdrag = enddrag
			#print("dragged", event.global_position, startdrag)
		else:
			pressed = false
			var t = shear.affine_inverse().xform(get_transform().affine_inverse().xform(event.position))
			currentP = shear.xform(Vector2(round(t.x/unit)*unit, round(t.y/unit)*unit))
	#update()
	#get_tree().set_input_as_handled()


func wrap(value, min_val, max_val):
    var f1 = value - min_val
    var f2 = max_val - min_val
    return fmod(f1, f2) + min_val


func draw_circle_arc(center, radius, angle_from, angle_to, color):
    var nb_points = 32
    var points_arc = PoolVector2Array()

    for i in range(nb_points+1):
        var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
        points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

    for index_point in range(nb_points):
        draw_line(points_arc[index_point], points_arc[index_point + 1], color)


func _process(delta):
	angle_from += rotation_ang*delta
	angle_to += rotation_ang*delta
	center += Vector2(10,10)*delta
	if angle_from > 360 and angle_to > 360:
        angle_from = wrap(angle_from, 0, 360)
        angle_to = wrap(angle_to, 0, 360)
	update()

#func _ready():
#	self.transform = shear
	# Called when the node is added to the scene for the first time.
	# Initialization here
#	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _draw():
	#draw_line(oldP, newP, color)
#	for i in range(1000):
#		draw_circle(center+Vector2((i/33)*20, (i%33)*20), radius, color)
	var tx = shear.xform(Vector2(unit,0))
	var ty = shear.xform(Vector2(0,unit))
	draw_line(currentP - tx/2 - ty/2, currentP - tx/2 + ty/2, color)
	draw_line(currentP - tx/2 + ty/2, currentP + tx/2 + ty/2, color)
	draw_line(currentP + tx/2 + ty/2, currentP + tx/2 - ty/2, color)
	draw_line(currentP + tx/2 - ty/2, currentP - tx/2 - ty/2, color)
	
	#draw_polygon([currentP -t/2, (currentP - t2/2).]
	
	draw_circle(currentP, unit/4, color)
	#draw_circle_arc(center, radius*10, angle_from, angle_to, color)