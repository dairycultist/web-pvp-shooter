extends Node
class_name Client

func _enter_tree() -> void:
	
	var api := SceneMultiplayer.new()
	api.multiplayer_peer = Network.client
	
	api.peer_connected.connect(_on_peer_connected)
	api.peer_disconnected.connect(_on_peer_disconnected)
	api.connected_to_server.connect(_on_connected_to_server)
	api.connection_failed.connect(_on_connection_failed)
	api.server_disconnected.connect(_on_server_disconnected)
	
	# use the new multiplayer API for this node and its descendants
	# this has to happen before its descendants have a chance to run
	# their _ready functions
	get_tree().set_multiplayer(api, get_path())

func _on_peer_connected(id: int):
	
	if id == 1: # ignore the server peer
		return
	
	# spawn other peer
	print("peer_connected id=" + str(id) + "\n")

func _on_peer_disconnected(id: int):
	
	if id == 1: # ignore the server peer
		return
	
	# delete other peer
	print("peer_disconnected id=" + str(id) + "\n")

func _on_connected_to_server():
	print("connected_to_server\n")

func _on_connection_failed():
	Network.leave_server("Server did not respond.")

func _on_server_disconnected():
	Network.leave_server("Server shut down by itself.")
