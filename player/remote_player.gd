extends StaticBody3D

var player_id: String:
	set(value):
		player_id = value
		$PlayerID.text = value

var goal_position: Vector3
var goal_rotation: Vector3

var curr_head_pitch: float

func _ready() -> void:
	
	goal_position = global_position
	
	Network.tick.connect(func():
		# poll the server for position and rotation information on this remote player;
		# the responses aren't handled by the remote players but by the Network global
		Network.send(player_id + ";pos")
		Network.send(player_id + ";rot")
	)

func _physics_process(delta: float) -> void:
	
	var head_bone_idx: int = $Model/Armature/Skeleton3D.find_bone("Head")
	
	curr_head_pitch = lerp(curr_head_pitch, goal_rotation.x, 10.0 * delta)
	$Model/Armature/Skeleton3D.set_bone_pose_rotation(head_bone_idx, Quaternion(Vector3.RIGHT, curr_head_pitch))
	
	if global_position.distance_to(goal_position) > 0.1:
		$Model/AnimationPlayer.play("Run", 0.3)
	else:
		$Model/AnimationPlayer.play("Idle", 0.3)
	
	global_position = lerp(global_position, goal_position, 10.0 * delta)
	global_rotation.y = lerp(global_rotation.y, goal_rotation.y, 10.0 * delta)
	
	
