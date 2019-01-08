extends Node2D

var beads = get_parent().beads
var arity = get_parent().arity
var delta = get_parent().delta


# class member variables go here, for example:
# var a = 2
# var b = "textvar"


func valid(path, bondset, sol, index, trans):
	var tmpBeads ={}
	for bead in path:
		for dir in neighborhood:
			if beads.has(bead+dir):
				tmpBeads[bead+dir] = [beads[bead+dir][0], beads[bead+dir][1].duplicate()]
	for i in range(1, index+2):
		tmpBeads[path[i]] = [trans[i],[]]
		for bond in bondset[sol[i-1]]:
			tmpBeads[path[i]][1].append(bond)
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
	return true

func backtrackFast(path, trans, bondset):
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


func generateDeltaPathFast(path, trans):
	#var prolong = [{}]
	var dpath = [[path]]
	for i in range(delta + 1 - len(path)):
		#prolong.append({})
		dpath.append([])
		for j in dpath[i]:
			for dir in neighborhood:
				if not(beads.has(j[-1]+dir) or j.has(j[-1]+dir)):
					#prolong[i][j[-1]+dir] = trans[i]
					dpath[i+1].append(j+[j[-1]+dir]) 
	#print(dpath[-1])
	return dpath[-1]


func findFirstFast(pos, trans):
	var det = true
	var bondset = []
	var tmp = []
	var maxstrength = -1
	var solutions = []
	for i in range(arity+1):
		bondset = bondset + genCombSet(neighborhood, i)
	var tmppath
	var tmptrans
	var paths = generateDeltaPath([pos], trans)
	for path in paths:
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
			pass
		else:
			print("single")
			pass
		return [solutions[0][0], solutions[0][1][0]]
		#return [solutions[0][0][1], solutions[0][1][0][0]]
	else:
		#print("nondeterministic")
		return []


func findNextFast(pos, trans):
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
			pass
		else:
			print("single")
			pass
		return [solutions[0][0], solutions[0][1][0]]
		#return [solutions[0][0][1], solutions[0][1][0][0]]
	else:
		#print("nondeterministic")
		return []


func foldFast(pos, trans):
	var bondset = []
	var beadpos = pos
	var ntrans = trans
	for i in range(arity+1):
		bondset = bondset + genCombSet(neighborhood, i)
	var tmp1
	var tmp2
	while len(ntrans) >= delta +1:
		tmp2 = []
		tmp1 = findFirst(beadpos, ntrans)
		#print("this*** ",tmp1)
		if tmp1 != []:
			if get_parent().gui.stepcheck.pressed:
				for i in range(1,len(tmp1[0])):
					tmp2 = []
					for j in bondset[tmp1[1][i-1]]:
						addBondTemp(tmp1[0][i], tmp1[0][i] + j)
					addBeadTemp(tmp1[0][i], ntrans[i],[])
					addEdgeTemp(tmp1[0][i-1],tmp1[0][i])
				update()	
				yield(get_parent().gui.stepBtn,"pressed")
				for i in TempObjects:
					self.remove_child(i)
			#print(bondset[tmp1[1]], "latest")
			for i in bondset[tmp1[1][0]]:
				tmp2.append(tmp1[0][1] + i)
			#print(tmp2, beads[tmp2[0]])
			addBeadF(tmp1[0][1], ntrans[1], tmp2)
			for j in tmp2:
				#addBondF(Vector2(0,-1), Vector2(-1,-2))
				#print(tmp1[0], " --> ", j)
				addBondF(tmp1[0][1], j)
			addEdgeF(beadpos, tmp1[0][1])
			ntrans.remove(0)
			beadpos = tmp1[0][1]
			#update()
			yield(get_tree(), "idle_frame")
		else:
			#print("nondeterministic")
			return




func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
