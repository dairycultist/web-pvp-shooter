extends CharacterBody3D

const SPEED = 5.0
const ACCELERATION = 10.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003

var is_local := false

## All players start controlled by the server; making them local deletes their
## mesh, allows them to be client-controlled, enables their camera, etc
func set_as_local():
	$Mesh.queue_free()
	$Camera.make_current()
	is_local = true

func _physics_process(delta: float) -> void:
	
	if is_local:
		_process_local(delta)
	else:
		_process_remote(delta)

func _input(event: InputEvent) -> void:
	
	if not is_local:
		return
	
	if event is InputEventMouseMotion:
		$Camera.rotation.x = clamp($Camera.rotation.x - event.screen_relative.y * MOUSE_SENSITIVITY, -PI/2, PI/2)
		global_rotation.y -= event.screen_relative.x * MOUSE_SENSITIVITY
		
		Network.send_identified("rot:" + str($Camera.rotation.x) + "," + str(global_rotation.y))

func _process_local(delta: float) -> void:
	
	velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("escape"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			$EscapeMenu.visible = false
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			$EscapeMenu.visible = true

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	velocity.x = lerp(velocity.x, direction.x * SPEED, ACCELERATION * delta)
	velocity.z = lerp(velocity.z, direction.z * SPEED, ACCELERATION * delta)

	move_and_slide()
	
	Network.send_identified("pos:" + str(global_position.x) + "," + str(global_position.y) + "," + str(global_position.z))

func _process_remote(_delta: float) -> void:
	
	# repeatedly poll the server for position and rotation information;
	# the responses aren't handled by the players but by the Network global
	Network.send(name + ";pos");
	Network.send(name + ";rot");
