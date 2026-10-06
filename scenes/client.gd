extends Node

func establish_multiplayer(client: ENetMultiplayerPeer) -> void:
	
	# create a new multiplayer API
	var client_multiplayer := SceneMultiplayer.new()
	client_multiplayer.multiplayer_peer = client
	
	# connect to its signals
	$Label.text += "Set up client multiplayer\n"
	
	client_multiplayer.peer_connected.connect(func(id: int):
		# spawn other peer
		$Label.text += "peer_connected id=" + str(id) + "\n"
	);
	
	client_multiplayer.peer_disconnected.connect(func(id: int):
		# delete other peer
		$Label.text += "peer_disconnected id=" + str(id) + "\n"
	);
	
	client_multiplayer.connected_to_server.connect(func():
		$Label.text += "connected_to_server\n"
	)
	
	client_multiplayer.connection_failed.connect(func():
		$Label.text += "connection_failed\n"
	)
	
	client_multiplayer.server_disconnected.connect(func():
		$Label.text += "server_disconnected\n"
	)
	
	# use the new multiplayer API for this node and its descendants
	get_tree().set_multiplayer(client_multiplayer, get_path())
