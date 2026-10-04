extends Node

const LOCAL_PLAYER_SCENE := preload("res://player/local_player.tscn")
const REMOTE_PLAYER_SCENE := preload("res://player/remote_player.tscn")

const TPS := 20.0
var _tick_timer: float # for syncing with the server
var _players_timer: float # for checking if any players joined/left
signal tick

var _peer: PacketPeerUDP
var _player_id := ""
var _current_scene: Node
var _packet_processor_thread: Thread
var _remote_players: Dictionary[String, Node3D]

func _ready() -> void:
	_peer = PacketPeerUDP.new()

## Handles establishing a connection to the server, loading the game scene, and
## setting up the player character.
func game_connect(ip: String, port: int, player_id: String) -> Error:
	
	_peer.bind(port + 1)
	_peer.set_dest_address(ip, port)
	
	# repeatedly send a message asking to connect with the given player id
	for i in range(0, 10):
		
		send(":conn:" + player_id)
		await get_tree().create_timer(1.0).timeout
		
		var res := _read_one_packet()
		if res == "OK":
			_player_id = player_id
			break
		if res == "TAKEN":
			return Error.ERR_ALREADY_EXISTS
	
	# could not reach server
	if _player_id == "":
		_peer.close()
		return Error.ERR_CANT_CONNECT
	
	# change scene
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	await get_tree().scene_changed
	_current_scene = get_tree().current_scene
	
	# spawn local player
	var local_player := LOCAL_PLAYER_SCENE.instantiate()
	local_player.player_id = player_id
	_current_scene.add_child(local_player)
	local_player.global_position.y = 5.0
	
	# begin processing incoming packets
	_packet_processor_thread = Thread.new()
	_packet_processor_thread.start(_process_packets)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	return Error.OK

func game_disconnect():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_peer.close()
	_player_id = ""
	_current_scene = null
	_remote_players.clear()
	_packet_processor_thread.wait_to_finish()
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func send(msg: String):
	_peer.put_packet(msg.to_utf8_buffer())

## Sends a message prefixed with the player id of the client.
func send_identified(msg: String):
	send(_player_id + ":" + msg)

func _process(delta: float) -> void:
	
	if _player_id == "":
		return
	
	_tick_timer -= delta
	_players_timer -= delta
	
	if _tick_timer < 0.0:
		_tick_timer = 1.0 / Network.TPS
		tick.emit()
	
	if _players_timer < 0.0:
		_players_timer = 5.0 # yeah it's hardcoded
		send(_player_id + ";players")

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
			var player = _remote_players.get(msg_parts[1])
			if player:
				var xyz = msg_parts[2].split(",")
				player.goal_position = Vector3(xyz[0].to_float(), xyz[1].to_float(), xyz[2].to_float())
		"rot":
			var player = _remote_players.get(msg_parts[1])
			if player:
				var py = msg_parts[2].split(",")
				player.goal_rotation = Vector3(py[0].to_float(), py[1].to_float(), 0.0)
		"players":
			var reported_player_ids = msg_parts[1].split(",")
			
			_current_scene.get_node("PlayerListLabel").text = "[b]" + _player_id + "[/b][br]" + "[br]".join(reported_player_ids)
			
			for id in reported_player_ids:
				if not _remote_players.has(id):
					_create_remote_player(id)
			
			for id in _remote_players.keys():
				if not reported_player_ids.has(id):
					_remote_players.get(id).queue_free()

func _create_remote_player(player_id: String) -> Node3D:

	var remote_player := REMOTE_PLAYER_SCENE.instantiate()
	remote_player.player_id = player_id
	_current_scene.add_child(remote_player)
	_remote_players.set(player_id, remote_player)
	
	return remote_player

func _read_one_packet() -> String:
	
	if _peer.get_available_packet_count() > 0:
		var array_bytes = _peer.get_packet()
		var packet_string = array_bytes.get_string_from_ascii()
		return packet_string
	
	return ""
