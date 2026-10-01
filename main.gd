extends Node2D

const SAVE_FILE = "user://flappy.save"

var mainMenu: Control
var mainMenuRes: Resource

var game: Node2D
var gameRes: Resource

func saveData():
	var saveDict = {
		"highScore": Globals.highScore
	}
	var saveRaw = JSON.stringify(saveDict)
	var saveFile = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	saveFile.store_line(saveRaw)

func loadData():
	if not FileAccess.file_exists(SAVE_FILE):
		return
	var saveFile = FileAccess.open(SAVE_FILE, FileAccess.READ)
	var json = JSON.new()
	var result = json.parse(saveFile.get_line())
	if result == OK:
		Globals.highScore = int(json.data.highScore)

func reloadMainMenu():
	remove_child(game)
	game.queue_free()
	mainMenu = mainMenuRes.instantiate()
	add_child(mainMenu)

func beginGame():
	remove_child(mainMenu)
	mainMenu.queue_free()
	game = gameRes.instantiate()
	add_child(game)

func quitGame():
	saveData()
	get_tree().quit()

# Handle mobile closes
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		saveData()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set global flag if game is on mobile or web
	if OS.has_feature("mobile") or OS.has_feature("web"):
		Globals.hasQuit = false # True by default

	mainMenuRes = preload("res://scenes/menu.tscn")
	mainMenu = mainMenuRes.instantiate()
	add_child(mainMenu)

	gameRes = preload("res://scenes/game.tscn")

	EventBus.mainMenu_beginGame.connect(beginGame)
	EventBus.mainMenu_quit.connect(quitGame)
	EventBus.universal_triggerSave.connect(saveData)
	EventBus.inGame_goToMainMenu.connect(reloadMainMenu)

	loadData()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
