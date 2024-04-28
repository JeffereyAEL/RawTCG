extends CharacterBody2D

class_name tcgCard

var bMouseCollision: bool = false
var bDragging: bool = false
var bShown: bool = true
var bLerping: bool = false

var LerpDest: Vector2
var LerpTime: float
var LerpCurrTime: float
var Offset: Vector2
var CardScale: float = 27
var BaseWindowSize: Vector2
var PrevWindowSize: Vector2
var BaseCardYScale: float

func _ready():
	input_pickable = true
	BaseWindowSize = get_tree().get_root().size as Vector2
	PrevWindowSize = BaseWindowSize
	get_tree().get_root().size_changed.connect(on_window_size_changed)
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	
	$Face.scale = Vector2(5,8)
	$Back.scale = Vector2(5,8)
	$Collision.scale = Vector2(1,1)
	set_card_scale(CardScale)
	set_shown(bShown)
	BaseCardYScale = CardScale
	
	# debug
	var d = position - (BaseWindowSize / 2.0)
	tcgLogger.debug_message("%s = center 2 pos" % d)
	tcgLogger.debug_message("dist2center=%s, x,y_ration=%s" % [d.length(), d / BaseWindowSize])

func set_shown(shown: bool):
	bShown = shown
	$Face.visible = shown
	$Back.visible = !shown
	tcgLogger.debug_message("Card bShown=%s" % str(bShown))
	
func set_position_lerp(destination: Vector2, time: float):
	bLerping = true
	LerpDest = destination
	LerpTime = time
	LerpCurrTime = 0.0
	
func set_local_owner(b_local_owner: bool):
	input_pickable = b_local_owner
	
func set_card_scale(card_scale: float):
	set_scale(Vector2(card_scale, card_scale))
	CardScale = card_scale
	
func on_mouse_entered():
	tcgLogger.debug_message("Card Entered")
	bMouseCollision = true
	
func on_mouse_exited():
	tcgLogger.debug_message("Card Exited")
	bMouseCollision = false
	
func on_window_size_changed():
	var curr_size = get_tree().get_root().size as Vector2
	if curr_size.y != PrevWindowSize.y:
		set_card_scale(BaseCardYScale * (curr_size.y / BaseWindowSize.y))
		tcgLogger.debug_message("modifying scale")
	var A1 = (position / PrevWindowSize) * 2.0 - Vector2.ONE
	var A2 = A1 * (curr_size / PrevWindowSize)
	position = ((A2 + Vector2.ONE) / 2.0) * curr_size
	PrevWindowSize = curr_size
	
	##debug
	#var c2p = position - (PrevWindowSize / 2.0)
	#tcgLogger.debug_message("%s = center 2 pos" % c2p)
	#var dir2pfromc = c2p.normalized()
	#tcgLogger.debug_message("%s = dir 2 pos from center" % dir2pfromc)
	#var scale = curr_size.y / PrevWindowSize.y
	#tcgLogger.debug_message("%s = scale" % scale)
	#position = (curr_size / 2.0) + dir2pfromc * scale
	#
	#PrevWindowSize = curr_size
	#
	#var d = position - (curr_size / 2.0)
	#tcgLogger.debug_message("dist2center=%s, x,y_ration=%s" % [d.length(), d / curr_size])
	## TODO: figure out why ^^^ doesn't work (keeps clampig position v v v close to screen center on call)

func _input(event):
	if event is InputEventMouseButton:
		if !event.is_canceled():
			if !bDragging and bMouseCollision:
				if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					tcgLogger.debug_message("Handling Input")
					bDragging = true
					Offset = get_global_mouse_position() - position
					bLerping = false
					event.canceled = true
			elif bDragging:
				if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
					tcgLogger.debug_message("Handling Input")
					bDragging = false
					tcgLogger.debug_message("Card location=%s" % str(position))
			if bMouseCollision and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
				tcgLogger.debug_message("Handling Input")
				set_shown(!bShown)

func _process(delta):
	if bDragging:
		position = get_global_mouse_position() - Offset
		move_to_front()
	if bLerping:
		LerpCurrTime += delta
		position = lerp(position, LerpDest, min(LerpCurrTime / LerpTime, 1.0))
