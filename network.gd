extends Node

# This script provides helpers for hosting, joining, and leaving a server
# (and potentially other network-related stuff if needed; the actual server
# and client code will just be focused on game logic).

# TODO pick up from here https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html#remote-procedure-calls

var _server := ENetMultiplayerPeer.new()
var _client := ENetMultiplayerPeer.new()

func host_server(port: int) -> Error:

	# create a local server
	var result := _server.create_server(port, 8)
	
	if result != Error.OK:
		return result
	
	# create a client to connect to the local server
	result = _client.create_client("127.0.0.1", port)
	
	if result != Error.OK:
		_server.close()
		return result
	
	# set up scene with client/server information
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	await get_tree().scene_changed
	var scene := get_tree().current_scene
	
	_init_server_node(scene.get_node("Server"))
	_init_client_node(scene.get_node("Client"))
	
	return Error.OK

func join_server(address: String, port: int) -> Error:
	
	# create a client to connect to the remote server
	var result := _client.create_client(address, port)
	
	if result != Error.OK:
		return result
	
	# set up scene with client information
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	await get_tree().scene_changed
	var scene := get_tree().current_scene
	
	_init_client_node(scene.get_node("Client"))
	
	return Error.OK

func leave_server() -> void:
	
	get_tree().change_scene_to_file("res://scenes/title.tscn")
	await get_tree().scene_changed
	_client.close()
	_server.close()

func _init_server_node(node: Server):
	
	var server_api := SceneMultiplayer.new()
	server_api.multiplayer_peer = _server
	
	server_api.peer_connected.connect(node.on_peer_connected)
	server_api.peer_disconnected.connect(node.on_peer_disconnected)
	
	# use the new multiplayer API for the server node and its descendants
	get_tree().set_multiplayer(server_api, node.get_path())

func _init_client_node(node: Client):
	
	var client_api := SceneMultiplayer.new()
	client_api.multiplayer_peer = _client
	
	client_api.peer_connected.connect(node.on_peer_connected)
	client_api.peer_disconnected.connect(node.on_peer_disconnected)
	client_api.connected_to_server.connect(node.on_connected_to_server)
	client_api.connection_failed.connect(node.on_connection_failed)
	client_api.server_disconnected.connect(node.on_server_disconnected)
	
	# use the new multiplayer API for the client node and its descendants
	get_tree().set_multiplayer(client_api, node.get_path())
