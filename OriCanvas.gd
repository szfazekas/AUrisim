extends Node2D



# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const neighborhood = [Vector2(1,0), Vector2(1,1), Vector2(0,1), Vector2(-1,0), Vector2(-1,-1), Vector2(0,-1)]

var arial = load('res://arial.tres')

var delta = 2
var arity = 1
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
#var bonds = []
var rules = {}
var grid = {}

var bondCombos								# from 6 directions choose at most arity many, all possible combinations
var PossibleBonds = []						# all possible elongations on an empty grid, which are arity-valid and not self-intersecting 

var overBead = false
var pressed = false
var startdrag = Vector2(0,0)
var enddrag = Vector2(0,0)


func valid(path, bondset, sol, index, trans):
	var tmpBeads ={}
	for bead in path:
		for dir in neighborhood:
			if beads.has(bead+dir):
				tmpBeads[bead+dir] = [beads[bead+dir][0], beads[bead+dir][1].duplicate()]
	#tmpBeads = beads.duplicate()
	for i in range(1, index+2):
		tmpBeads[path[i]] = [trans[i],[]]
		for bond in bondset[sol[i-1]]:
			tmpBeads[path[i]][1].append(bond)
			#if beads.has([path[i]+bond]) and not(tmpBeads.has([path[i]+bond])):
			#	tmpBeads[path[i]+bond] = [beads[path[i]][0], beads[path[i]][1].duplicate()]
			if tmpBeads.has(path[i]+bond) and not(path[i] in tmpBeads[path[i]+bond][1]):
				tmpBeads[path[i]+bond][1].append(path[i])
				if len(tmpBeads[path[i]+bond][1]) > arity:
					
					return false
	for i in range(1, index+2):
		for bond in bondset[sol[i-1]]:
			if i>0 and path[i] + bond == path[i-1]:
				
				return false
			elif not(tmpBeads.has(path[i] + bond)):
				
				return false
			elif not(rules[trans[i]].has(tmpBeads[path[i]+bond][0])):
				
				return false
#			elif len(beads[path[i]+bond][1])+len(bondset[sol[i]]) > arity:
#				value = false
	
	return true

func backtrack(path, trans, bondset):
	var tmp = {}
	var index = 0
	var solutions = []
	var sol = []
	var bondNo = len(bondset)
	var strength
	var maxstrength = -1
	for i in range(delta):
		sol.append(-1)
	while index > -1:
		if sol[index] < bondNo - 1:
			sol[index] += 1
			if valid(path, bondset, sol, index, trans):
				if index == delta-1:
					#for i in range(delta):
					#	for j in bondset[sol[i]]:
					#		tmp.append()
					strength = 0
					for i in sol:
						strength += len(bondset[i])
					if strength > maxstrength:
						maxstrength = strength
						solutions = [strength, [sol.duplicate()], true]
					elif strength == maxstrength:
						if sol[0] == solutions[1][0][0]:
							solutions[1].append(sol.duplicate())
						else:
							solutions[2] = false
					
				else:
					index += 1
					sol[index] = -1
		else:
			index -= 1
	return solutions


func findNext(pos, trans):
	var det = true
	var bondset = []
	var tmp = []
	var maxstrength = -1
	var solutions = []
	for i in range(arity+1):
		bondset = bondset + genCombSet(neighborhood, i)
	var tmppath
	var tmptrans
	var paths = generateDeltaPath(pos, trans)
	for path in paths:
#		tmppath = path.duplicate()
#		tmppath.pop_front()
#		tmptrans = trans
#		tmptrans.remove(0)
		tmp = backtrack(path, trans, bondset)
		if tmp[0] > maxstrength:
			if tmp[2]:
				maxstrength = tmp[0]
				solutions = [[path, tmp[1]]]
				det = true
			else:
				det = false
		elif tmp[0] == maxstrength:
			if path[1] == solutions[0][0][1] and tmp[1][0][0] == solutions[0][1][0][0]:
				solutions.append([path, tmp[1]])
			else:
				det = false
	if det:
		if len(solutions) > 1:
			print("multiple")
			#print("multiple - ", maxstrength, " --- ", solutions)
		else:
			print("single")
			#print("single - ", maxstrength, " --- ", solutions)
		return [solutions[0][0][1], solutions[0][1][0][0]]
	else:
		print("nondeterministic")
		return []


func foldNew(pos, trans):
	var bondset = []
	var beadpos = pos
	var ntrans = trans
	for i in range(arity+1):
		bondset = bondset + genCombSet(neighborhood, i)
	var tmp1
	var tmp2
	while len(ntrans) >= delta +1:
		tmp2 = []
		tmp1 = findNext(beadpos, ntrans)
		#print("this*** ",tmp1)
		if tmp1 != []:
			#print(bondset[tmp1[1]], "latest")
			for i in bondset[tmp1[1]]:
				tmp2.append(tmp1[0] + i)
			#print(tmp2, beads[tmp2[0]])
			addBeadF(tmp1[0], ntrans[1], tmp2)
			for j in tmp2:
				#addBondF(Vector2(0,-1), Vector2(-1,-2))
				#print(tmp1[0], " --> ", j)
				addBondF(tmp1[0], j)
			addEdgeF(beadpos, tmp1[0])
			ntrans.remove(0)
			beadpos = tmp1[0]
		else:
			print("nondeterministic")
			return

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
	#var prolong = [{}]
	var dpath = [[[start]]]
	for i in range(delta):
		#prolong.append({})
		dpath.append([])
		for j in dpath[i]:
			for dir in neighborhood:
				if not(beads.has(j[-1]+dir) or j.has(j[-1]+dir)):
					#prolong[i][j[-1]+dir] = trans[i]
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
	#print(tmpBonds)
	# return the list of bond sequences sorted by strength
	tmpBonds.sort_custom(self, "elongComp")
	return tmpBonds



func filterElongs(preBonds, path):
	var tmp = [] 
	var strength = 0
	var tmpEnv = {}
	var returnEnv = {}
	
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
		strength = 0
		tmpEnv = preBonds.duplicate()
		for bead in range(delta):
			tmpEnv[path[bead+1]] = []
			returnEnv[path[bead+1]] = []
			for i in bondset[bead]:
				tmpEnv[path[bead+1]].append(path[bead+1] + i)
				returnEnv[path[bead+1]].append(path[bead+1] + i)
			strength += len(bondset[bead])
		#strength = 0
		throw = false
		# for each bead in the path
		for bead in range(delta):
			#tmpEnv[path[bead+1]] = []
			# for each bond in the current bead's bonds
			if not(throw):
				for dir in bondset[bead]:
					
					# if the current bead wants to bind to something not in the present path, then add 1 to strength for the new bond
					if path.has(path[bead+1]+dir) and not(tmpEnv[path[bead+1]+dir].has(path[bead+1])):
						throw = true
					if path[bead+1]+dir == path[bead]:
						throw = true
					#elif tmpEnv.has(path[bead]+dir):
					#	tmpEnv[path[bead]+dir].append(-dir)
		if not(throw):
			tmpBonds.append([strength, returnEnv.duplicate()])
	var index = 0
	for i in range(len(tmpBonds)):
		if tmpBonds[i][0] > tmpBonds[index][0]:
			index = i
#	for i in range(len(tmpBonds)):
#		if tmpBonds[i][0] >= 3:
#			print(tmpBonds[i])
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
				#print(1)
			elif not(rules[tmpBeads[path[bead]][0]].has(tmpBeads[bond][0])):
				valid = false
				#print(2)
			elif len(tmpBeads[bond][1]) < arity:
				if not(path[bead] in tmpBeads[bond][1]):
					tmpBeads[bond][1].append(path[bead])
				#print(tmpBeads[bond])
				#print("bond")
			else:
				#print(tmpBeads[bond])
				valid = false
				#print(3)
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
		tmp2 = filterElongs(beads, path)
		for bondseq in tmp2:
			if checkElong(beads, path, bondseq, trans):
				if bondseq[0] > maxbond:
					print(bondseq)
					maxbond = bondseq[0]
					solution = [[path,bondseq]]
				elif bondseq[0] == maxbond:
					#print(bondseq[1])
					solution.append([path, bondseq])
	if len(solution) > 1:
		print("multiple")
		var currentpos = solution[0][0][1]
		var currentbonds = solution[0][1][1][currentpos]
		for bondseq in solution:
			bondseq[1][1][bondseq[0][1]].sort()
			currentbonds.sort()
			if bondseq[0][1] != currentpos or bondseq[1][1][bondseq[0][1]] != currentbonds:
				print("Nondeterministic")
				#print(solution)
				return null
		return solution[0]
	elif len(solution) == 1:
		print("single")
		return solution[0]
	else:
		print("no path...")
		return null



func fold(pos, trans):
	var hang = []
	var currentpos = pos
	var oldpos = pos
	var solution = []
	for j in range(delta+1):
		hang.append(trans[j])
	var i = 1
	while i < len(trans)-delta:
		solution = filterElongSet(generateDeltaPath(currentpos, hang), hang)
		if solution != null:
			oldpos = currentpos
			currentpos = solution[0][1]
			addBeadF(currentpos, trans[i], solution[1][1][solution[0][1]])
			addEdgeF(oldpos, currentpos)
#			print(solution[1][1][currentpos], "xxx")
			for j in range(len(solution[1][1][currentpos])):
			#	print(bond)
				addBondF(currentpos, solution[1][1][currentpos][j])
			hang.pop_front()
			hang.append(trans[i+delta-1])
			i += 1
		else:
			print("Stopped folding")
			return



func addBeadF(pos, type, bonds):
	var canvpos = shear.xform(pos*unit)
	addToGrid(canvpos, pos)
	var nodebeadf = load('res://bluedot.tscn').instance()
	nodebeadf.init(canvpos, unit*0.2, type)
	nodebeadf.name = 'bead_'+str(pos.x)+'_'+str(pos.y)
	nodebeadf.z_index = -1
	add_child(nodebeadf)
	beads[pos] = [type,[]]
	#print("-----------",bonds)
	#for i in bonds:
	#	beads[i][1].append(pos)
	BeadObjects[pos] = nodebeadf


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
	#print(beads[newPP],"xxxx")
	BeadObjects[newPP] = nodebead


func addBondF(from, to):
	print("made it")
	var nodetrans = load('res://bond.tscn').instance()
	nodetrans.initZig(shear.xform(from*unit), shear.xform(to*unit))
	#nodetrans.init(shear.xform(from*unit), shear.xform(to*unit))
	#print(beads[from][1], " === ", beads[to][1])
	beads[from][1].append(to)
	beads[to][1].append(from)
	#print(beads[from][1], " >>> ", beads[to][1])
	nodetrans.name = "bond "+str(from.x)+","+str(from.y)+"->"+str(to.x)+","+str(to.y)
	nodetrans.z_index = -3
	print(nodetrans.name)
	#print(beads)
	add_child(nodetrans)


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
								#fold(newPP, get_parent().gui.transcript.text)
								ciDemo()
								#foldNew(newPP, get_parent().gui.transcript.text.split(","))
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


func ciDemo():
	addBeadF(Vector2(0,0),"1",[])
	#beads[Vector2(0,0)] = ["1",[]]
	addBeadF(Vector2(1,0),"0",[])
	addEdgeF(Vector2(0,0), Vector2(1,0))
	addBeadF(Vector2(2,0),"2",[])
	addEdgeF(Vector2(1,0), Vector2(2,0))
	addBeadF(Vector2(3,0),"0",[])
	addEdgeF(Vector2(2,0), Vector2(3,0))
	addBeadF(Vector2(4,0),"5",[])
	addEdgeF(Vector2(3,0), Vector2(4,0))
	addBeadF(Vector2(5,0),"0",[])
	addEdgeF(Vector2(4,0), Vector2(5,0))
	addBeadF(Vector2(6,0),"6",[])
	addEdgeF(Vector2(5,0), Vector2(6,0))
	addBeadF(Vector2(6,-1),"0",[])
	addEdgeF(Vector2(6,0), Vector2(6,-1))
	addBeadF(Vector2(7,0),"0",[])
	addEdgeF(Vector2(6,-1), Vector2(7,0))	
	foldNew(Vector2(7,0), get_parent().gui.transcript.text.split(","))


func _ready():
	print(self.get_viewport_rect().size)
	self.translate(self.get_viewport_rect().size/2)
	bondCombos = genCombSet(neighborhood,2)+genCombSet(neighborhood,1)+genCombSet(neighborhood,0)
	var tmpBonds = {}
	#print(genCombSet(neighborhood,0))
	var tmp = genCombSet(neighborhood,2)+genCombSet(neighborhood,1)+genCombSet(neighborhood,0)
	rules["0"] = []
	rules["1"] = ["1"]
	rules["2"] = ["2"]
	rules["3"] = ["3"]
	rules["4"] = ["4"]
	rules["5"] = ["5"]
	rules["6"] = ["6"]
	rules["7"] = ["7"]
	rules["8"] = ["8"]
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
