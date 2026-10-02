extends CharacterBody2D

const JUMP_VELOCITY = -400.0
const DIE_VELOCITY = -400.0
const SELF_SIZE = Vector2(48, 48)

var animSprite: AnimatedSprite2D

var hasGravity = false
var update = false
var celebrating = false
var celebTime = 0.0

func begin():
	update = true
	hasGravity = true
	velocity.y = JUMP_VELOCITY

func goToIdle():
	animSprite.play("idle")

func celebrate():
	celebrating = true
	celebTime = 1.0
	animSprite.play("celebrate")

func freezeAndStare():
	update = false
	hasGravity = false
	velocity.y = 0
	animSprite.play("die")

func dropToOutside():
	hasGravity = true
	velocity.y = DIE_VELOCITY

func _ready() -> void:
	# Get children.
	animSprite = get_node("%AnimatedSprite2D")
	# Setup animations
	animSprite.play("idle")
	animSprite.animation_finished.connect(goToIdle)

	EventBus.inGame_playerStart.connect(begin)
	EventBus.inGame_newBest.connect(celebrate)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if hasGravity:
		velocity += get_gravity() * delta

	if update:
		# Handle jump.
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			if not celebrating:
				animSprite.play("flap")
		if celebrating:
			celebTime = clampf(celebTime - delta, 0, 1)
			

		# Ensure in-bounds
		var viewport = get_viewport_rect()
		if position.y < 0 - SELF_SIZE.y or position.y > viewport.size.y + SELF_SIZE.y:
			EventBus.inGame_flappyBirdDied.emit()

		
	move_and_slide()
