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
	file.open(get_node("OriGUI/LoadOSBtn/LoadOS").current_file, file.READ)
	canvas.delta = int(file.get_line())
	canvas.arity = int(file.get_line())
	tmp = file.get_line().split("->")
	#load seed 
	for i in tmp:
		tmp2 = i.split(",")
		current = Vector2(int(tmp2[1]), int(tmp2[2]))
		#add seed bead
		canvas.addBeadF(current, tmp2[0], [])
		canvas.rules[tmp2[0]] = []
		#add seed edge
		if prev != null:
			canvas.addEdgeSeed(prev, current)
		prev = current
	#load transcript
	tmp = file.get_line()
	get_node("OriGUI/Transcript").text = tmp
	canvas.transcript = tmp.split(",")
	for i in canvas.transcript:
		canvas.rules[i] = []
	#load rules
	tmp = file.get_line().split(",")
	for i in tmp:
		if i != "":
			tmp2 = i.split("=")
			canvas.rules[tmp2[0]].append(tmp2[1])
			canvas.rules[tmp2[1]].append(tmp2[0])
	#load seed bonds
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
		if child.name.match("*bond*") or child.name.match("*bead*") or child.name.match("*trans*"):
			canvas.remove_child(child)
			canvas.beads = {}
			canvas.rules = {}
			canvas.BeadObjects = {}


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
			canvas.rules[tmp2[0]].append(tmp2[1])
			canvas.rules[tmp2[1]].append(tmp2[0])
	#canvas.print(canvas.rules)
	file.close()
