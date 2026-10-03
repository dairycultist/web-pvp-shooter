extends Node

const TPS := 20.0

var _peer: PacketPeerUDP
var _player_id := ""
var _current_scene: Node
var _packet_processor_thread: Thread

func _ready() -> void:
	_peer = PacketPeerUDP.new()

## Handles establishing a connection to the server, loading the game scene, and
## setting up the player character.
func game_connect(ip: String, port: int) -> bool:
	
	_peer.bind(port + 1)
	_peer.set_dest_address(ip, port)
	
	# repeatedly send a message asking to know which player we are
	# (returning false if we get no response)
	for i in range(0, 10):
		
		send(";reqid")
		await get_tree().create_timer(1.0).timeout
		
		var res := _read_one_packet()
		if res.begins_with("="):
			_player_id = res.substr(1)
			break
	
	# could not reach server
	if _player_id == "":
		_peer.close()
		return false
	
	# change scene
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	await get_tree().scene_changed
	_current_scene = get_tree().current_scene
	
	# take control of that player
	_current_scene.get_node(_player_id).set_as_local()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# begin processing incoming packets
	_packet_processor_thread = Thread.new()
	_packet_processor_thread.start(_process_packets)
	
	return true

func game_disconnect():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_peer.close()
	_player_id = ""
	_current_scene = null
	_packet_processor_thread.wait_to_finish()
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func send(msg: String):
	_peer.put_packet(msg.to_utf8_buffer())

## Sends a message prefixed with the player id of the client.
func send_identified(msg: String):
	send(_player_id + ":" + msg)

func _process_packets() -> void:
	
	var msg_parts
	
	while true:
		
		if _player_id == "":
			continue
		
		msg_parts = Network._read_one_packet().split(":")
		
		call_deferred("_process_packet", msg_parts)

func _process_packet(msg_parts) -> void:
	
	match msg_parts[0]:
		"pos":
			var player = _current_scene.get_node(msg_parts[1])
			if player:
				var xyz = msg_parts[2].split(",")
				player.goal_position = Vector3(xyz[0].to_float(), xyz[1].to_float(), xyz[2].to_float())
		"rot":
			var player = _current_scene.get_node(msg_parts[1])
			if player:
				var py = msg_parts[2].split(",")
				player.goal_rotation = Vector3(py[0].to_float(), py[1].to_float(), 0.0)

func _read_one_packet() -> String:
	
	if _peer.get_available_packet_count() > 0:
		var array_bytes = _peer.get_packet()
		var packet_string = array_bytes.get_string_from_ascii()
		return packet_string
	
	return ""
