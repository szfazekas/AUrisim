extends Panel


onready var delBtn = $DelBtn
onready var delLab = $DelLabel
onready var folBtn = $FollowBtn
onready var folLab = $FollowLabel
onready var bondBtn = $BondBtn
onready var foldBtn = $Fold
onready var btSelect = $BTypeSelect
onready var transcript = $Transcript
onready var stepcheck = $StepCheck
onready var stepBtn = $StepperBtn
onready var arityBox = $ArityDelta/ArityBox
onready var deltaBox = $ArityDelta/DeltaBox


# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Transcript_text_changed(new_text):
	get_parent().canvas.transcript = new_text.split(",")
