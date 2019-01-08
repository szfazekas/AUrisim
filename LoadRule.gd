extends FileDialog

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	mode = self.MODE_OPEN_FILE
	add_filter("*.rules*; AUrisim rule set")
	# Called when the node is added to the scene for the first time.
	# Initialization here

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_LoadRuleBtn_pressed():
	popup()
