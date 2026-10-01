extends Node2D

const HIGHEST_POSSIBLE_BIRD_INCREASE = -100
const PIPE_BUFFER_DIFFICULTY_SCALING = 0.05
const PIPE_BUFFER_DIFFICULTY_CLAMP = 0.5
const PIPE_SAFEZONE_DIFFICULTY_SCALING = Vector2(1, 1)
const PIPE_SAFEZONE_DIFFICULTY_CLAMP = Vector2(100, 100)
const SCREEN_EDGE_SAFE_BUFFER = 30

var update = false
var atStart = true

# Children
var flappyBird: CharacterBody2D
var animNode: AnimationPlayer
var uiNode: Control
var clickPrompt: Label
var pipeCounter: Label

var pipeCount := 0

# Scenes to preload
var pipe: Resource

# Pipe generation info
var pipesList: Array
var timeSinceLastPipe = 999.0
var pipeCreationThreshold = 2.0
var lastPipeHeight = 0
var pipeSafezone = Vector2(200, 200)

var pipeProbabilityCurve: Curve

func begin():
	update = true

func goToMainMenu():
	EventBus.inGame_goToMainMenu.emit()

func flappyDied():
	update = false
	animNode.play("player_death")
	if pipeCount > Globals.highScore:
		Globals.highScore = pipeCount
	EventBus.universal_triggerSave.emit()

func removePipe(toRemove: int):
	pipesList.remove_at(toRemove)

func newPipe(gapPos: Vector2, flappyPos: Vector2):
	# Instantiate one pipe for testing
	var thePipe = pipe.instantiate() as Node2D
	var safeZone = Rect2(gapPos, pipeSafezone)
	add_child(thePipe)
	thePipe.setup(safeZone, len(pipesList), flappyPos)
	thePipe.removeMe.connect(removePipe)
	pipesList.append(thePipe)

func pipePass():
	pipeCount += 1
	pipeCounter.text = "Pipes: " + str(pipeCount)
	# pipeCounter.set_position()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	flappyBird = get_node("%FlappyBird")
	animNode = get_node("%AnimationPlayer")
	uiNode = get_node("%UI")
	clickPrompt = get_node("%Prompt")
	pipeCounter = get_node("%PipeCounter")

	uiNode.size = get_viewport_rect().size

	EventBus.inGame_flappyBirdDied.connect(flappyDied)
	EventBus.inGame_flappyPassedPipe.connect(pipePass)
	EventBus.inGame_playerStart.connect(begin)

	pipe = preload("res://scenes/pipe.tscn")
	pipeProbabilityCurve = load("res://curves/pipe_gen_probability.tres")

	lastPipeHeight = get_viewport_rect().size.y / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	uiNode.size = get_viewport_rect().size # Ensure UI node is properly scaled
	if update:
		if timeSinceLastPipe >= pipeCreationThreshold:
			# Randomly generate a pipe position that can 
			# var randsize = floor(randf() * (get_viewport_rect().size.y - pipeSafezone.y))
			var randsize = lastPipeHeight + (
				(pipeProbabilityCurve.sample(randf()) * 2 - 1)
				* HIGHEST_POSSIBLE_BIRD_INCREASE
				* (pipeSafezone.y / PIPE_SAFEZONE_DIFFICULTY_CLAMP.y)
				* (pipeCreationThreshold / 2)
			)
			# Stop pipes generating too hgih
			randsize = abs(randsize - pipeSafezone.y)
			# Stop pipes generating too low
			var viewRect = get_viewport_rect()
			var maxDistFromBottom = viewRect.size.y - pipeSafezone.y
			if randsize > maxDistFromBottom:
				randsize = maxDistFromBottom - (randsize - maxDistFromBottom)
			newPipe(Vector2(0, randsize), flappyBird.position)
			lastPipeHeight = randsize
			timeSinceLastPipe = 0
			pipeCreationThreshold -= PIPE_BUFFER_DIFFICULTY_SCALING
			pipeCreationThreshold = clampf(pipeCreationThreshold, PIPE_BUFFER_DIFFICULTY_CLAMP, 3.0)
			pipeSafezone -= PIPE_SAFEZONE_DIFFICULTY_SCALING
			pipeSafezone = pipeSafezone.clamp(PIPE_SAFEZONE_DIFFICULTY_CLAMP, Vector2(300, 300))
		else:
			timeSinceLastPipe += delta
	elif atStart:
		if Input.is_anything_pressed():
			atStart = false
			EventBus.inGame_playerStart.emit()
			clickPrompt.visible = false
