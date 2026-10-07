extends Node

# This script provides helpers for hosting, joining, and leaving a server.
# DON'T use this to get information about the network; use the local
# "multiplayer" property instead (because the host has both the server and
# the client, and this property tells you which one a given node is).

# The server and client code focus on game logic.

# TODO pick up from here https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html#remote-procedure-calls

var server := ENetMultiplayerPeer.new()
var client := ENetMultiplayerPeer.new()

func host_server(scene: PackedScene, port: int) -> Error:

	# create a local server
	var result := server.create_server(port, 8)
	
	if result != Error.OK:
		return result
	
	# create a client to connect to the local server
	result = client.create_client("127.0.0.1", port)
	
	if result != Error.OK:
		server.close()
		return result
	
	# load the scene
	get_tree().change_scene_to_file("res://scenes/empty_networked_scene.tscn")
	await get_tree().scene_changed
	
	var server_scene := scene.instantiate()
	server_scene.get_node("ClientOnly").queue_free()
	get_tree().current_scene.get_node("Server").add_child(server_scene)
	
	var client_scene := scene.instantiate()
	get_tree().current_scene.get_node("Client").add_child(client_scene)
	
	return Error.OK

func join_server(scene: PackedScene, address: String, port: int) -> Error:
	
	# create a client to connect to the remote server
	var result := client.create_client(address, port)
	
	if result != Error.OK:
		return result
	
	# load the scene
	get_tree().change_scene_to_file("res://scenes/empty_networked_scene.tscn")
	await get_tree().scene_changed
	
	var client_scene := scene.instantiate()
	get_tree().current_scene.get_node("Client").add_child(client_scene)
	
	return Error.OK

func leave_server(reason: String = "") -> void:
	
	get_tree().change_scene_to_file("res://scenes/empty_networked_scene.tscn")
	await get_tree().scene_changed
	client.close()
	server.close()
	
	get_tree().current_scene.get_node("DisconnectReasonLabel").text = reason
