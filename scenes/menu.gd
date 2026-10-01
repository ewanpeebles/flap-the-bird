extends Control

var highScoreNode: Label
var quitNode: Button

func quitPressed():
	EventBus.mainMenu_quit.emit()

func playPressed():
	EventBus.mainMenu_beginGame.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	highScoreNode = get_node("%HighScoreLabel")
	quitNode = get_node("%Quit")
	if not Globals.hasQuit: # Some platforms do not support quitting easily; they will
		quitNode.queue_free()

	size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	highScoreNode.text = "High Score: " + str(Globals.highScore)
