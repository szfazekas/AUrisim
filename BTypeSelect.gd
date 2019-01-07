extends OptionButton

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var popup = get_children()[0]

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	add_item("0")
	add_item("1")
	add_item("2")
	add_item("3")
	add_item("4")
	add_item("5")
	add_item("6")
	add_item("7")
	add_item("8")
	#select(2)

func get_selected_id():
	for i in range(get_item_count()):
		if popup.is_item_checked(i):
			return str(i)
	return str(-1)
#func _gui_input(event):
#	select(get_selected_id())
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
