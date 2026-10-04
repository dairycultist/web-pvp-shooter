extends StaticBody3D

var player_id: String

var goal_position: Vector3
var goal_rotation: Vector3

func _ready() -> void:
	
	goal_position = global_position
	
	Network.tick.connect(func():
		# poll the server for position and rotation information on this remote player;
		# the responses aren't handled by the remote players but by the Network global
		Network.send(player_id + ";pos")
		Network.send(player_id + ";rot")
	)

func _physics_process(delta: float) -> void:
	
	global_position = lerp(global_position, goal_position, 10.0 * delta)
	$Camera.global_rotation.x = lerp($Camera.global_rotation.x, goal_rotation.x, 10.0 * delta)
	global_rotation.y = lerp(global_rotation.y, goal_rotation.y, 10.0 * delta)
