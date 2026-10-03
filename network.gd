extends Node

var _peer: PacketPeerUDP

func _ready() -> void:
	_peer = PacketPeerUDP.new()
	_peer.bind(19132)

## Handles establishing a connection to the server, loading the game scene, and
## setting up the player character.
func game_connect(ip: String, port: int):
	_peer.set_dest_address(ip, port)
	get_tree().change_scene_to_file("res://game.tscn")
	await get_tree().scene_changed
	print("done!")

func game_disconnect():
	pass

func send(msg: String):
	_peer.put_packet(msg.to_utf8_buffer())

func read_one_packet():
	
	if _peer.get_available_packet_count() > 0:
		var array_bytes = _peer.get_packet()
		var packet_string = array_bytes.get_string_from_ascii()
		print("Received message: ", packet_string)
