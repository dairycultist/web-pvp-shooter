extends CharacterBody3D

const SPEED = 5.0
const ACCELERATION = 10.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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

	var input_dir := Vector2.ZERO

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:

		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	velocity.x = lerp(velocity.x, direction.x * SPEED, ACCELERATION * delta)
	velocity.z = lerp(velocity.z, direction.z * SPEED, ACCELERATION * delta)

	move_and_slide()
	
	# visual
	var head_bone_idx: int = $Model/Armature/Skeleton3D.find_bone("Head")
	$Model/Armature/Skeleton3D.set_bone_pose_rotation(head_bone_idx, $Camera.quaternion)
	
	if not is_on_floor():
		$Model/AnimationPlayer.play("Jump", 0.15)
	elif input_dir:
		$Model/AnimationPlayer.play("Run", 0.3)
	else:
		$Model/AnimationPlayer.play("Idle", 0.3)

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		$Camera.rotation.x = clamp($Camera.rotation.x - event.screen_relative.y * MOUSE_SENSITIVITY, -PI/2, PI/2)
		global_rotation.y -= event.screen_relative.x * MOUSE_SENSITIVITY
