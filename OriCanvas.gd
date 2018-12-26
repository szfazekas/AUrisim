extends Node2D



# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const neighborhood = [Vector2(1,0), Vector2(1,1), Vector2(0,1), Vector2(-1,0), Vector2(-1,-1), Vector2(0,-1)]

var arial = load('res://arial.tres')

var delta = 2
var arity = 2
var sigma = [1,2,1,2,3,1,2,1,3,3,2,1,1,2]
var transcript = [1,2,1,2,3,1,2,1,3,3,2,1,1,2]

var rotation_ang = 50
var angle_from = 75
var angle_to = 195
var center = Vector2(200, 200)
var radius = 5
var color = Color(0.3, 0.5, 0.5, 0.5)
var newb = 200

var unit = 100

var shear = Transform2D(Vector2(1,0), Vector2(-0.5, -sqrt(3)/2), Vector2(0,0))
var oldP = Vector2(0,0)
var newP = Vector2(-10000,0)
var currentP = Vector2(0,0)

var oldPP = Vector2(0,0)
var newPP = Vector2(0,0)


var beads = {}
var BeadObjects = {}
var paths = []
var bonds = []
var rules = {}
var grid = {}

var bondCombos								# from 6 directions choose at most arity many, all possible combinations
var PossibleBonds = []						# all possible elongations on an empty grid, which are arity-valid and not self-intersecting 

var overBead = false
var pressed = false
var startdrag = Vector2(0,0)
var enddrag = Vector2(0,0)



func addToGrid(pos, gridPos):
	var nodepoint
	for dir in neighborhood+[Vector2(0,0)]:
		if not(gridPos + dir in grid):
			grid[gridPos + dir] = 1
			nodepoint = load('res://GridPoint.tscn').instance()
			add_child(nodepoint)
			nodepoint.init(shear.xform((gridPos+dir)*unit))
			nodepoint.z_index = -2
			

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
	#print(dpath[-1])
	return dpath[-1]


func decrease(list, index):
	var succ = false
	while not(succ) and index>=0:
		if list[index]>0:
			list[index] = list[index] - 1
		else:
			index = index - 1



# generate all combinations n choose k, non-recursively
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


# generate all combinations of k elements from set, using genComb(|set|, k) above
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


# generate Cartesian power k of set, recursively
func genCartPower(set, k):
	var cart = []
	if set == [] or k == 0:
		return [[]]
	var tmp = genCartPower(set, k-1)
	for i in set:
		for j in tmp:
			cart.append([i]+j) 
	return cart


# generate Cartesian product of sets, recursively
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


# given pre-existing bond info prebonds and a path, return all beadwise bond sequences for this path, which are not self-contradictory
func filterSupArity(preBonds, path):
	var tmp = [] 
	var strength = 0
	var tmpEnv = {}
	
	# tmp <- all possible combinations of maximum arity many bonds for one bead
	for i in range(arity+1):
		tmp += genCombSet(neighborhood, i)
	# tmp <- all sequences of length delta of bond combinations
	tmp = genCartPower(tmp, delta)
	# if true, throw away bond sequence, because it is invalid
	var throw = false
	# tmpBonds <- valid bond sequences
	var tmpBonds = []
	
	# for each possible bond sequence
	for bondset in tmp:
		# tmpEnv <- surrounding beads
		tmpEnv = preBonds.duplicate()
		for bead in range(delta):
			tmpEnv[path[bead+1]] = []
		strength = 0
		throw = false
		# for each bead in the path
		for bead in range(0,delta):
			#tmpEnv[path[bead+1]] = []
			# for each bond in the current bead's bonds
			if not(throw):
				for dir in bondset[bead]:
					tmpEnv[path[bead+1]].append(path[bead+1]+dir)
					# if the current bead wants to bind to something not in the present path, then add 1 to strength for the new bond
					if not(tmpEnv.has(path[bead+1]+dir)):
						strength += 1
					# otherwise, check if the bonding partner has a correspoonding bond and throw away bond sequence if not
					elif not(tmpEnv[path[bead+1]+dir].has(path[bead+1])):
						throw = true
					if throw or path[bead+1]+dir == path[bead]:
						throw = true
					#elif tmpEnv.has(path[bead]+dir):
					#	tmpEnv[path[bead]+dir].append(-dir)
		if not(throw):
			tmpBonds.append([strength, tmpEnv])
	var index = 0
	for i in range(len(tmpBonds)):
		if tmpBonds[i][0] > tmpBonds[index][0]:
			index = i
	# return the list of bond sequences sorted by strength
	tmpBonds.sort_custom(self, "elongComp")
	return tmpBonds


# check if an elongation is compatible with bonding ruleset and surrounding beads
func checkElong(preBeads, path, elong, trans):
	var tmpBeads = preBeads.duplicate()
	var valid = true
	var bondseq = elong[1]
	for bead in range(1,len(path)):
		tmpBeads[path[bead]] = [trans[bead], []]
	for bead in range(1,len(path)):
		for bond in bondseq[path[bead]]:
			if not(tmpBeads.has(bond)):
				valid = false
			elif not(rules[tmpBeads[path[bead]][0]].has(tmpBeads[bond][0])):
				valid = false
			elif len(tmpBeads[bond]) < arity:
				tmpBeads[bond].append(path[bead])
			else:
				valid = false
	return valid


# compare strength of bond sequences a and b
func elongComp(a, b):
	if a[0] > b[0]:
		return true
	else:
		return false


func filterElongSet(eSet, trans):
	var tmp = [[0,'nothing']]
	var tmp2 = []
	var maxbond = 0
	var solution = []
	#print(beads)
	for path in eSet:
		tmp2 = filterSupArity({}, path)
		for bondseq in tmp2:
			if checkElong(beads, path, bondseq, trans):
				if bondseq[0] > maxbond:
					maxbond = bondseq[0]
					solution = [[path,bondseq]]
				elif bondseq[0] == maxbond:
					solution.append([path, bondseq])
	if len(solution)>1:
		var currentpos = solution[0][0][1]
		var currentbonds = solution[0][1][1][currentpos]
		for bondseq in solution:
			if bondseq[0][1] != currentpos or bondseq[1][1][bondseq[0][1]] != currentbonds:
				print("Nondeterministic")
				print(solution)
				return null
		return solution[0]
	else:
		return solution[0]



func fold(pos, trans):
	var hang = []
	var currentpos = pos
	var oldpos = pos
	var solution = []
	for i in range(delta+1):
		hang.append(trans[i])
	var i = 1
	while i < len(trans)-delta:
		solution = filterElongSet(generateDeltaPath(currentpos, hang), hang)
		if solution != null:
			oldpos = currentpos
			currentpos = solution[0][1]
			addBeadF(currentpos, trans[i], solution[1][1][solution[0][1]])
			addEdgeF(oldpos, currentpos)
			hang.pop_front()
			hang.append(trans[i+delta-1])
			i += 1
		else:
			print("Stopped folding")
			return


func addBeadF(pos, type, bonds):
	var canvpos = shear.xform(pos*unit)
	addToGrid(canvpos, pos)
	var nodebead = load('res://bluedot.tscn').instance()
	nodebead.init(canvpos, unit*0.2, type)
	nodebead.name = 'bead_'+str(pos.x)+'_'+str(pos.y)
	nodebead.z_index = -1
	add_child(nodebead)
	beads[pos] = [type,bonds]
	for i in bonds:
		beads[i][1].append(pos)
	BeadObjects[pos] = nodebead


func addEdgeF(from, to):
	var nodetrans = load('res://transcript.tscn').instance()
	var canvfrom = shear.xform(from*unit)
	var canvto = shear.xform(to*unit)
	nodetrans.init(canvfrom, canvto)
	nodetrans.name = "trans "+str(from.x)+","+str(from.y)+"->"+str(to.x)+","+str(to.y)
	nodetrans.z_index = -2
	BeadObjects[from].next = to
	BeadObjects[to].previous = from
	print(nodetrans.name)
	add_child(nodetrans)


func addBead():
	addToGrid(newP, newPP)
	var nodebead = load('res://bluedot.tscn').instance()
	nodebead.init(newP, unit*0.2, get_parent().gui.btSelect.get_selected_id())
	nodebead.name = 'bead_'+str(newPP.x)+'_'+str(newPP.y)
	nodebead.z_index = -1
	add_child(nodebead)
	beads[newPP] = [get_parent().gui.btSelect.get_selected_id(),[]]
	BeadObjects[newPP] = nodebead



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
		BeadObjects.erase(newPP)



func addEdge():
	var nodetrans = load('res://transcript.tscn').instance()
	nodetrans.init(oldP, newP)
	nodetrans.name = "trans "+str(oldPP.x)+","+str(oldPP.y)+"->"+str(newPP.x)+","+str(newPP.y)
	nodetrans.z_index = -2
	BeadObjects[oldPP].next = newPP
	BeadObjects[newPP].previous = oldPP
	print(nodetrans.name)
	add_child(nodetrans)



func addBond():
	if BeadObjects[oldPP].next != newPP and BeadObjects[oldPP].previous != newPP:
		var nodetrans = load('res://bond.tscn').instance()
		nodetrans.initZig(oldP, newP)
		beads[oldPP][1].append(newPP)
		beads[newPP][1].append(oldPP)
		nodetrans.name = "bond "+str(oldPP.x)+","+str(oldPP.y)+"->"+str(newPP.x)+","+str(newPP.y)
		nodetrans.z_index = -3
		print(nodetrans.name)
		print(beads)
		add_child(nodetrans)



func _unhandled_input(event):
	if event is InputEventKey:
		return
	var t = shear.affine_inverse().xform(get_transform().affine_inverse().xform(event.position))
	if shear.xform(Vector2(round(t.x/unit)*unit, round(t.y/unit)*unit)).distance_to(shear.xform(t)) < unit*0.3:
		overBead = true
	else:
		overBead = false
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				if event.doubleclick:
					if overBead:
						oldPP = newPP
						newPP.x = int(round(t.x/unit))
						newPP.y = int(round(t.y/unit))
						
						if not(get_parent().gui.delBtn.pressed):
							oldP = newP
							newP = shear.xform(Vector2(round(t.x/unit)*unit, round(t.y/unit)*unit))
							if (get_parent().gui.foldBtn.pressed):
								fold(newPP, get_parent().gui.transcript.text)
							else:
								if not(beads.has(newPP)):
									addBead()
								elif not(get_parent().gui.bondBtn.pressed):
									delBead()
									addBead()
								
								if (get_parent().gui.folBtn.pressed) and ((newPP-oldPP) in neighborhood):
									addEdge()
									
								elif (get_parent().gui.bondBtn.pressed) and ((newPP-oldPP) in neighborhood):
									addBond()
								
#							elif (get_parent().gui.foldBtn.pressed):
#								filterElongSet(generateDeltaPath(newPP, ["1","1","2"]), ["1","1","2"])
								
						else:
							delBead()
					
				else:
					pressed = true
					startdrag = event.position
			else:
				pressed = false
				
		elif event.button_index == BUTTON_WHEEL_UP:
			var tr = get_transform()
			self.transform = Transform2D(tr.x*1.02, tr.y*1.02, tr.origin)
			
		elif event.button_index == BUTTON_WHEEL_DOWN:
			var tr = get_transform()
			self.transform = Transform2D(tr.x*0.98, tr.y*0.98, tr.origin)
	
	if event is InputEventMouseMotion:
		if pressed:
			enddrag = event.position
			var tr = get_transform()
			self.transform = Transform2D(tr.x, tr.y, enddrag - startdrag + tr.origin)
			startdrag = enddrag
		else:
			pressed = false
			currentP = shear.xform(Vector2(round(t.x/unit)*unit, round(t.y/unit)*unit))
	update()
	#get_tree().set_input_as_handled()



func _ready():
	print(self.get_viewport_rect().size)
	self.translate(self.get_viewport_rect().size/2)
	bondCombos = genCombSet(neighborhood,2)+genCombSet(neighborhood,1)+genCombSet(neighborhood,0)
	var tmpBonds = {}
	#print(genCombSet(neighborhood,0))
	var tmp = genCombSet(neighborhood,2)+genCombSet(neighborhood,1)+genCombSet(neighborhood,0)
	rules["0"] = ["0"]
	rules["1"] = ["1"]
	rules["2"] = ["2"]
	rules["3"] = ["3"]
	rules["4"] = ["4"]
	addToGrid(Vector2(0,0), Vector2(0,0))
	#filterSupArity({}, [Vector2(0,0), Vector2(1,0), Vector2(1,-1), Vector2(0,-1)])
	print(len(genCartPower(tmp,delta)))
	print(len(genCart([genCombSet(neighborhood,2) + genCombSet(neighborhood,1) + genCombSet(neighborhood,0),genCombSet(neighborhood,2)+genCombSet(neighborhood,1)+genCombSet(neighborhood,0)])))
	#print(bondCombos)
	#print(generateCartesian([1,2,3],3))
	#PossibleBonds = filterSupArity(tmpBonds, generateDeltaPath(Vector2(0,0), [transcript[i] for i in range(delta)]))


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _draw():
	arial.set_size(unit/3)
	
	var tx = shear.xform(Vector2(unit,0))
	var ty = shear.xform(Vector2(0,unit))
	
	# draw cursor: a paralellogram reflecting the shear and a filled circle where the bead is/would be placed
	
	#draw_line(currentP - tx/2 - ty/2, currentP - tx/2 + ty/2, color)
	#draw_line(currentP - tx/2 + ty/2, currentP + tx/2 + ty/2, color)
	#draw_line(currentP + tx/2 + ty/2, currentP + tx/2 - ty/2, color)
	#draw_line(currentP + tx/2 - ty/2, currentP - tx/2 - ty/2, color)
	if overBead:
		draw_circle(currentP, unit/4, color)
