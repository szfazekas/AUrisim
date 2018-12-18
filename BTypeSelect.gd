extends OptionButton

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	add_item("1")
	add_item("2")
	add_item("3")
	add_item("4")
	select(2)

#func _gui_input(event):
#	select(get_selected_id())
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
