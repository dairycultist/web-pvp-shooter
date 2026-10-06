extends Node

func establish_multiplayer(client: MultiplayerPeer) -> void:
	
	# create a new multiplayer API
	var client_multiplayer := SceneMultiplayer.new()
	client_multiplayer.multiplayer_peer = client
	
	# connect to its signals
	client_multiplayer.peer_connected.connect(_on_peer_connected);
	client_multiplayer.peer_disconnected.connect(_on_peer_disconnected);
	client_multiplayer.connected_to_server.connect(_on_connected_to_server)
	client_multiplayer.connection_failed.connect(_on_connection_failed)
	client_multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	# use the new multiplayer API for this node and its descendants
	get_tree().set_multiplayer(client_multiplayer, get_path())

func _on_peer_connected(id: int):
	# spawn other peer
	$Label.text += "peer_connected id=" + str(id) + "\n"

func _on_peer_disconnected(id: int):
	# delete other peer
	$Label.text += "peer_disconnected id=" + str(id) + "\n"

func _on_connected_to_server():
	$Label.text += "connected_to_server\n"

func _on_connection_failed():
	$Label.text += "connection_failed\n"

func _on_server_disconnected():
	$Label.text += "server_disconnected\n"
	#Network.leave_server()
