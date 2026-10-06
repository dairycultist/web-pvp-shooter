extends Node

# all this script does is provide 3 global functions, one for hosting a server,
# one for joining a server, and one for disconnecting (from either)

func host_server(port: int) -> Error:

	# create a local server
	var server := ENetMultiplayerPeer.new()
	var result := server.create_server(port, 8)
	
	if result != Error.OK:
		return result
	
	# create a client to connect to the local server
	var client := ENetMultiplayerPeer.new()
	result = client.create_client("127.0.0.1", port)
	
	if result != Error.OK:
		server.close()
		return result
	
	# set up scene with client/server information
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	await get_tree().scene_changed
	var scene := get_tree().current_scene
	
	scene.get_node("Server").multiplayer.multiplayer_peer = server
	scene.get_node("Client").multiplayer.multiplayer_peer = client
	
	return Error.OK

func join_server(address: String, port: int) -> Error:
	
	# create a client to connect to the remote server
	var client := ENetMultiplayerPeer.new()
	var result := client.create_client(address, port)
	
	if result != Error.OK:
		return result
	
	# set up scene with client information
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	await get_tree().scene_changed
	var scene := get_tree().current_scene
	
	scene.get_node("Client").establish_multiplayer(client)
	
	return Error.OK

func leave_server() -> void:
	print("not implemented")
	#ENetMultiplayerPeer.new().close()
