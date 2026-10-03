extends CharacterBody3D

const SPEED = 5.0
const ACCELERATION = 10.0
const JUMP_VELOCITY = 4.5

var is_local := false

## All players start controlled by the server; making them local deletes their
## mesh, allows them to be client-controlled, enables their camera, etc
func set_as_local():
	$Mesh.queue_free()
	$Camera.make_current()
	is_local = true

func _physics_process(delta: float) -> void:
	
	if not is_local:
		return
	
	velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	velocity.x = lerp(velocity.x, direction.x * SPEED, ACCELERATION * delta)
	velocity.z = lerp(velocity.z, direction.z * SPEED, ACCELERATION * delta)

	move_and_slide()
