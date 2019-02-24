extends Node2D

onready var canvas = $OriCanvas
onready var gui = $OriGUI

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#nce last frame.
#	# Update game logic here.
#	pass

#load OS from file. Format:
# delta (a positive integer) 
# arity (a positive integer)
# seed: beadtype,x,y->beadtype,x,y->...
# transcript: beadtype,beadtype,...
# rules: beadtype=beadtype,beadtype=beadtype,...
# seed bonds: x,y->x,y;x,y->x,y;...
func _on_LoadOS_file_selected(path):
	var file = File.new()
	var tmp = []
	var tmp2 = []
	var prev
	var current
	file.open(path, file.READ)
	canvas.delta = int(file.get_line())
	gui.deltaBox.value = canvas.delta
	canvas.arity = int(file.get_line())
	gui.arityBox.value = canvas.arity
	tmp = file.get_line().split("->")
	#load seed 
	for i in tmp:
		tmp2 = i.split(",")
		current = Vector2(int(tmp2[1].strip_edges()), int(tmp2[2].strip_edges()))
		#add seed bead
		canvas.addBeadF(current, tmp2[0].strip_edges(), [])
		canvas.rules[tmp2[0].strip_edges()] = []
		#add seed edge
		if prev != null:
			canvas.addEdgeSeed(prev, current)
		prev = current
	#load transcript
	tmp = file.get_line()
	get_node("OriGUI/Transcript").text = tmp
	canvas.transcript = []
	for i in tmp.split(","):
		canvas.transcript.append(i.strip_edges())
	#canvas.transcript = tmp.split(",")
	for i in canvas.transcript:
		canvas.rules[i] = []
	#load rules
	tmp = file.get_line().split(",")
	for i in tmp:
		if i != "":
			tmp2 = i.split("=")
			if not canvas.rules.has(tmp2[0].strip_edges()):
				canvas.rules[tmp2[0].strip_edges()] = []
			if not canvas.rules.has(tmp2[1].strip_edges()):
				canvas.rules[tmp2[1].strip_edges()] = []	
			canvas.rules[tmp2[0].strip_edges()].append(tmp2[1].strip_edges())
			canvas.rules[tmp2[1].strip_edges()].append(tmp2[0].strip_edges())
	#load seed bonds
	print(canvas.rules)
	tmp = file.get_line().split(";")
	if tmp[0] != "":
		for i in tmp:
			tmp2 = i.split("->")
			prev = Vector2(int(tmp2[0].split(",")[0]), int(tmp2[0].split(",")[1]))
			current = Vector2(int(tmp2[1].split(",")[0]), int(tmp2[1].split(",")[1]))
			canvas.addBondF(prev, current)
	file.close()


func _on_ClearBtn_pressed():
	for child in canvas.get_children():
		if child.name.match("*bond*") or child.name.match("*bead*") or child.name.match("*trans*") or canvas.GridPoints.has(child):
			canvas.remove_child(child)
	canvas.beads = {}
	canvas.rules = {}
	canvas.BeadObjects = {}
	canvas.GridPoints = []
	canvas.grid = {}
	canvas.addToGrid(Vector2(0,0), Vector2(0,0))

func _on_SaveRule_file_selected(path):
	var tmpRules = {}
	var beads = canvas.beads
	var file = File.new()
	file.open(path, file.WRITE)
#	for child in canvas.get_children():
#		if child.name.match("*bond*"):
#			if not tmpRules.has(beads[child.ends[0]][0]):
#				tmpRules[beads[child.ends[0]][0]] = [beads[child.ends[1]][0]]
#			elif not tmpRules[beads[child.ends[0]][0]].has(beads[child.ends[1]][0]):
#				tmpRules[beads[child.ends[0]][0]].append(beads[child.ends[1]][0])
#			if not tmpRules.has(beads[child.ends[1]][0]):
#				tmpRules[beads[child.ends[1]][0]] = [beads[child.ends[0]][0]]
#			elif not tmpRules[beads[child.ends[1]][0]].has(beads[child.ends[0]][0]):
#				tmpRules[beads[child.ends[1]][0]].append(beads[child.ends[1]][0])
	for key in beads.keys():
		if not tmpRules.has(beads[key][0]):
			tmpRules[beads[key][0]] = []
		for bond in beads[key][1]:
			if not (beads[bond][0] in tmpRules[beads[key][0]]):
				tmpRules[beads[key][0]].append(beads[bond][0])
			if not tmpRules.has(beads[bond][0]):
				tmpRules[beads[bond][0]] = [beads[key][0]]
	for i in tmpRules.keys():
		for j in tmpRules[i]:
			#file.store_string("hello")
			file.store_string(i+"="+j+",")
	file.close()
			

func _on_LoadRule_file_selected(path):
	var tmp
	var tmp2
	var file = File.new()
	canvas.rules = {}
	file.open(path, file.READ)
	tmp = file.get_line().split(",")
#	for child in canvas.get_children():
#		if child.name.match("*bond*"):
#			if not tmpRules.has(beads[child.ends[0]][0]):
#				tmpRules[beads[child.ends[0]][0]] = [beads[child.ends[1]][0]]
#			elif not tmpRules[beads[child.ends[0]][0]].has(beads[child.ends[1]][0]):
#				tmpRules[beads[child.ends[0]][0]].append(beads[child.ends[1]][0])
#			if not tmpRules.has(beads[child.ends[1]][0]):
#				tmpRules[beads[child.ends[1]][0]] = [beads[child.ends[0]][0]]
#			elif not tmpRules[beads[child.ends[1]][0]].has(beads[child.ends[0]][0]):
#				tmpRules[beads[child.ends[1]][0]].append(beads[child.ends[1]][0])
	for i in tmp:
		if i != "":
			tmp2 = i.split("=")
			if not canvas.rules.has(tmp2[0]):
				canvas.rules[tmp2[0]] = []
			if not canvas.rules.has(tmp2[1]):
				canvas.rules[tmp2[1]] = []
			if not canvas.rules[tmp2[0]].has(tmp2[1]):
				canvas.rules[tmp2[0]].append(tmp2[1])
			if not canvas.rules[tmp2[1]].has(tmp2[0]):
				canvas.rules[tmp2[1]].append(tmp2[0])
	#canvas.print(canvas.rules)
	file.close()


func _on_DeltaBox_value_changed(value):
	canvas.delta = value


func _on_ArityBox_value_changed(value):
	canvas.arity = value


func _on_PutBtn_pressed():
	var where = canvas.newPP
	var beadobjects = canvas.BeadObjects
	if not beadobjects.has(where):
		return
	while beadobjects[where].previous != null:
		where = beadobjects[where].previous
	var i = 0
	while beadobjects[where].next != null:
		beadobjects[where].label = canvas.transcript[i%len(canvas.transcript)]
		beadobjects[where].update()
		canvas.beads[where][0] = canvas.transcript[i%len(canvas.transcript)]
		where = beadobjects[where].next
		i += 1
	beadobjects[where].label = canvas.transcript[i%len(canvas.transcript)]
	beadobjects[where].update()
	canvas.beads[where][0] = canvas.transcript[i%len(canvas.transcript)]

func _on_Transcript_text_changed(new_text):
	canvas.transcript = new_text.split(",")


func _on_PutBondBtn_pressed():
	for key in canvas.beads.keys():
		for dir in canvas.neighborhood:
			if canvas.beads.has(key+dir) and not(key+dir in canvas.beads[key][1]):
				canvas.beads[key][1].append(key+dir)
				canvas.addBondF(key, key+dir)

func _on_SavePNG_pressed():
	#vp = canvas.get_viewport()
	pass
