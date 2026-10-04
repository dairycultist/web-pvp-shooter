extends CharacterBody3D

const SPEED = 5.0
const ACCELERATION = 10.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003

var player_id: String

func _ready() -> void:
	
	Network.tick.connect(func():
		Network.send_identified(
			"xyzpy:"
			+ str(global_position.x) + ","
			+ str(global_position.y) + ","
			+ str(global_position.z) + ","
			+ str($Camera.rotation.x) + ","
			+ str(global_rotation.y))
	)
	
	$Chat/ChatEntry.text_changed.connect(func(new_text: String):
		$Chat/ChatEntry.text = new_text.replace(":", "").replace(";", "").replace(",", "").substr(0, 10)
		$Chat/ChatEntry.set_caret_column($Chat/ChatEntry.text.length())
	)
	
	$Chat/ChatEntry.text_submitted.connect(func(new_text: String):
		Network.send_identified("chat:" + new_text)
		$Chat/ChatEntry.clear()
	)

func _physics_process(delta: float) -> void:
	
	velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("escape"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			$EscapeMenu.visible = false
			$Chat/ChatEntry.release_focus()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			$EscapeMenu.visible = true
			$Chat/ChatEntry.grab_focus()

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	velocity.x = lerp(velocity.x, direction.x * SPEED, ACCELERATION * delta)
	velocity.z = lerp(velocity.z, direction.z * SPEED, ACCELERATION * delta)

	move_and_slide()

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		$Camera.rotation.x = clamp($Camera.rotation.x - event.screen_relative.y * MOUSE_SENSITIVITY, -PI/2, PI/2)
		global_rotation.y -= event.screen_relative.x * MOUSE_SENSITIVITY
