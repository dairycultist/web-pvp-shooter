extends Node

var _peer: PacketPeerUDP

func _ready() -> void:
	_peer = PacketPeerUDP.new()

## Handles establishing a connection to the server, loading the game scene, and
## setting up the player character.
func game_connect(ip: String, port: int) -> bool:
	
	_peer.bind(port + 1)
	_peer.set_dest_address(ip, port)
	
	# repeatedly send a message asking to know which player we are
	# (returning false if we get no response)
	var role := -1
	
	for i in range(0, 10):
		
		send("rolereq")
		await get_tree().create_timer(1.0).timeout
		
		var res := read_one_packet()
		
		if res.begins_with("roleset"):
			role = res.to_int() # automatically strips the prefix
			break
	
	if role == -1:
		_peer.close()
		return false
	
	# change scene
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	await get_tree().scene_changed
	
	# take control of that player
	print("Assuming role: ", role)
	get_tree().current_scene.get_node("Player" + str(role)).set_as_local()
	
	return true

func game_disconnect():
	_peer.close()
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func send(msg: String):
	_peer.put_packet(msg.to_utf8_buffer())

func read_one_packet() -> String:
	
	if _peer.get_available_packet_count() > 0:
		var array_bytes = _peer.get_packet()
		var packet_string = array_bytes.get_string_from_ascii()
		return packet_string
	
	return ""
