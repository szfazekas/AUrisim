extends Node2D



# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const neighborhood = [Vector2(1,0), Vector2(1,1), Vector2(0,1), Vector2(-1,0), Vector2(-1,-1), Vector2(0,-1)]

var delta = 3
var arity = 2
var sigma = [1,2,1,2,3,1,2,1,3,3,2,1,1,2]
var transcript = [1,2,1,2,3,1,2,1,3,3,2,1,1,2]

var rotation_ang = 50
var angle_from = 75
var angle_to = 195
var center = Vector2(200, 200)
var radius = 5
var color = Color(0.3, 0.5, 0.5)
var newb = 200

var unit = 100

var shear = Transform2D(Vector2(1,0), Vector2(-0.5, -sqrt(3)/2), Vector2(0,0))
var oldP = Vector2(0,0)
var newP = Vector2(-10000,0)
var currentP = Vector2(0,0)

var oldPP = Vector2(0,0)
var newPP = Vector2(0,0)


var beads = {}
var paths = []
var bonds = []


var bondCombos								# from 6 directions choose at most arity many, all possible combinations
var PossibleBonds = []						# all possible elongations on an empty grid, which are arity-valid and not self-intersecting 

var pressed = false
var startdrag = Vector2(0,0)
var enddrag = Vector2(0,0)



# generate all non-intersecting paths of length delta, which are consistent with beads[], starting from start
func generateDeltaPath(start, trans):
	var prolong = [{}]
	var dpath = [[[start]]]
	for i in range(delta):
		prolong.append({})
		dpath.append([])
		for j in dpath[i]:
			for dir in neighborhood:
				if not(beads.has(j[-1]+dir) or j.has(j[-1]+dir)):
					prolong[i][j[-1]+dir] = trans[i]
					dpath[i+1].append(j+[j[-1]+dir]) 


func decrease(list, index):
	var succ = false
	while not(succ) and index>=0:
		if list[index]>0:
			list[index] = list[index] - 1
		else:
			index = index - 1



# generate all combinations n choose k
func genComb(n, k):
	if n < k or k < 0:
		return []
	var index = k-1
	var combos = []
	var comb = []
	
	for i in range(k):
		comb.append(i)
	combos.append(comb.duplicate())
	
	while index >= 0:
		if comb[index] < n-k+index:
			comb[index] += 1
			for i in range(index+1, k):
				comb[i] = comb[i-1] + 1
			combos.append(comb.duplicate())
			index = k-1
		else:
			index -= 1
	return combos


# generate all combinations of k elements from set
func genCombSet(set,k):
	var tmp = genComb(len(set), k)
	var combos = []
	var comb = []
	for i in tmp:
		comb = []
		for j in i:
			comb.append(set[j])
		combos.append(comb.duplicate())
	return combos 


# generate Cartesian power k of set
func genCartPower(set, k):
	var cart = []
	if set == [] or k == 0:
		return [[]]
	var tmp = genCartPower(set, k-1)
	for i in set:
		for j in tmp:
			cart.append([i]+j) 
	return cart


# generate Cartesian product of sets
func genCart(sets):
	var cart = []
	if sets == [] or sets.has([]):
		return [[]]
	var tmp = sets.pop_front()
	var tmp2 = genCart(sets)
	for i in tmp:
		for j in tmp2:
			cart.append([i]+j) 
	return cart



func filterSupArity(preBonds, elongs):
	var tmp = generateComb()
	for i in elongs:
		for j in i:
			for k in bondCombos:
				for l in k:
					preBonds[j+neighborhood[l]] += 1
	pass

func getBonds(preBonds):
	# path has the current path
	# bonds has all possible bond structures for this path; initially empty
	var bonds = [[preBonds]]
	# for each bead in the path
	#for i in range(len(path)):
		# for each bond structure with fewer beads
		#for j in bonds[i]:
		#set arity+1 many lists
	pass
	

func addBead():
	if not(beads.has(newPP)):
		var nodebead = load('res://bluedot.tscn').instance()
		nodebead.init(newP, unit*0.2)
		nodebead.name = 'bead_'+str(newPP.x)+'_'+str(newPP.y)
		nodebead.z_index = 2
		add_child(nodebead)
		beads[newPP] = 1
		#print(nodebead.name, beads)
	

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


func addBond():
	var nodetrans = load('res://bond.tscn').instance()
	nodetrans.init(oldP, newP)
	nodetrans.name = "bond "+str(oldPP.x)+","+str(oldPP.y)+"->"+str(newPP.x)+","+str(newPP.y)
	nodetrans.z_index = 0
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
						elif (get_parent().gui.bondBtn.pressed) and ((newPP-oldPP) in neighborhood):
							addBond()
						elif (get_parent().gui.foldBtn.pressed):
							generateDeltaPath(newPP, [1,1,1])
							print(generateComb([1,2,3,4],3))
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
	bondCombos = genCombSet(neighborhood, 2)
	var tmpBonds = {}
	
	print(len(genCart([range(100),range(1000)])))
	#print(bondCombos)
	#print(generateCartesian([1,2,3],3))
	#PossibleBonds = filterSupArity(tmpBonds, generateDeltaPath(Vector2(0,0), [transcript[i] for i in range(delta)]))


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
