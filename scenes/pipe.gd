extends Node2D

const PIPE_WIDTH = 100
const MOVE_SPEED = -300

signal removeMe(index)

var update = true # Only spawned if playing

var myIndex = -1
var flappyPos: Vector2
var isClaimed = false

var upperArea: Area2D
var upperCol: CollisionShape2D
var upperRender: Panel

var lowerArea: Area2D
var lowerCol: CollisionShape2D
var lowerRender: Panel


func killFlappy():
	EventBus.inGame_flappyBirdDied.emit()

func onFlappyDeath():
	update = false

func setup(safezone: Rect2, myNewIndex, flappyNewPos):
	myIndex = myNewIndex
	flappyPos = flappyNewPos
	var viewRect = get_viewport_rect()

	upperArea = get_node("%UpperArea")
	upperCol = get_node("%UpperCollision")
	upperRender = get_node("%UpperRender")
	lowerArea = get_node("%LowerArea")
	lowerCol = get_node("%LowerCollision")
	lowerRender = get_node("%LowerRender")

	var upperPos := Vector2(viewRect.size.x, 0)
	var upperSize := Vector2(PIPE_WIDTH, safezone.position.y)
	var upperShape := RectangleShape2D.new()
	upperShape.size = upperSize

	upperCol.position = upperPos + (upperSize / 2)
	upperCol.shape = upperShape
	upperRender.position = upperPos
	upperRender.size = upperSize
	
	var lowerStart = safezone.position.y + safezone.size.y

	var lowerPos := Vector2(viewRect.size.x, lowerStart)
	var lowerSize := Vector2(PIPE_WIDTH, viewRect.size.y - lowerStart)
	var lowerShape := RectangleShape2D.new()
	lowerShape.size = lowerSize

	lowerCol.position = lowerPos + (lowerSize / 2)
	lowerCol.shape = lowerShape
	lowerRender.position = lowerPos
	lowerRender.size = lowerSize

	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# upperCol = get_node("%UpperCollision")
	# upperRender = get_node("%UpperRender")
	# lowerCol = get_node("%LowerCollision")
	# lowerRender = get_node("%LowerRender")
	EventBus.inGame_flappyBirdDied.connect(onFlappyDeath)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if update:
		for area in upperArea.get_overlapping_areas():
			killFlappy()
		for area in lowerArea.get_overlapping_areas():
			killFlappy()
		upperCol.position.x += MOVE_SPEED * delta
		upperRender.position.x += MOVE_SPEED * delta
		lowerCol.position.x += MOVE_SPEED * delta
		lowerRender.position.x += MOVE_SPEED * delta
		if upperCol.position.x < flappyPos.x and not isClaimed:
			EventBus.inGame_flappyPassedPipe.emit()
			isClaimed = true
		if upperCol.position.x < 0 - upperCol.shape.size.x:
			removeMe.emit(myIndex)
			queue_free()
