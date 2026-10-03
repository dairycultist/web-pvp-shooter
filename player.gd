extends CharacterBody3D

const SPEED = 5.0
const ACCELERATION = 10.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003

var is_local := false
var sync_tick_timer := 0.0 # enforces Network.TPS

# only used by remote players
var goal_position: Vector3
var goal_rotation: Vector3

func _ready() -> void:
	goal_position = global_position

## All players start controlled by the server; making them local deletes their
## mesh, allows them to be client-controlled, enables their camera, etc
func set_as_local():
	$Mesh.queue_free()
	$Camera.make_current()
	is_local = true

func _physics_process(delta: float) -> void:
	
	sync_tick_timer -= delta
	
	var is_sync_tick := false
	if sync_tick_timer < 0.0:
		sync_tick_timer = 1.0 / Network.TPS
		is_sync_tick = true
	
	if is_local:
		_process_local(delta, is_sync_tick)
	else:
		_process_remote(delta, is_sync_tick)

func _input(event: InputEvent) -> void:
	
	if not is_local:
		return
	
	if event is InputEventMouseMotion:
		$Camera.rotation.x = clamp($Camera.rotation.x - event.screen_relative.y * MOUSE_SENSITIVITY, -PI/2, PI/2)
		global_rotation.y -= event.screen_relative.x * MOUSE_SENSITIVITY

func _process_local(delta: float, is_sync_tick: bool) -> void:
	
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
	
	if is_sync_tick:
		Network.send_identified("pos:" + str(global_position.x) + "," + str(global_position.y) + "," + str(global_position.z))
		Network.send_identified("rot:" + str($Camera.rotation.x) + "," + str(global_rotation.y))

func _process_remote(delta: float, is_sync_tick: bool) -> void:
	
	global_position = lerp(global_position, goal_position, 10.0 * delta)
	$Camera.global_rotation.x = lerp($Camera.global_rotation.x, goal_rotation.x, 10.0 * delta)
	global_rotation.y = lerp(global_rotation.y, goal_rotation.y, 10.0 * delta)
	
	# repeatedly poll the server for position and rotation information;
	# the responses aren't handled by the players but by the Network global
	if is_sync_tick:
		Network.send(name + ";pos");
		Network.send(name + ";rot");
