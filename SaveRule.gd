extends FileDialog

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	mode = MODE_SAVE_FILE
	add_filter("*.rules; AUrisim rulefile")


func _on_SaveRuleBtn_pressed():
	popup() # replace with function body
