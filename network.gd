extends Node

var _peer: PacketPeerUDP
var _player_id := ""

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
		
		var res := read_one_packet()
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
	
	# take control of that player
	get_tree().current_scene.get_node(_player_id).set_as_local()
	
	return true

func game_disconnect():
	_peer.close()
	_player_id = ""
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func send(msg: String):
	_peer.put_packet(msg.to_utf8_buffer())

## Sends a message prefixed with the player id of the client.
func send_identified(msg: String):
	send(_player_id + ":" + msg)

func _physics_process(_delta: float) -> void:
	
	if _player_id == "":
		return
	
	var msg_parts = Network.read_one_packet().split(":")
	
	match msg_parts[0]:
		"pos":
			var player = get_tree().current_scene.get_node(msg_parts[1])
			if player:
				var xyz = msg_parts[2].split(",")
				player.global_position.x = xyz[0].to_float()
				player.global_position.y = xyz[1].to_float()
				player.global_position.z = xyz[2].to_float()

func read_one_packet() -> String:
	
	if _peer.get_available_packet_count() > 0:
		var array_bytes = _peer.get_packet()
		var packet_string = array_bytes.get_string_from_ascii()
		return packet_string
	
	return ""
