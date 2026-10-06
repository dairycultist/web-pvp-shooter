extends Node

func establish_multiplayer(server: ENetMultiplayerPeer) -> void:
	
	# create a new multiplayer API
	var server_multiplayer := SceneMultiplayer.new()
	server_multiplayer.multiplayer_peer = server
	
	# connect to its signals
	$Label.text += "Set up server multiplayer\n"
	
	server_multiplayer.peer_connected.connect(func(id: int):
		# handle client connection
		$Label.text += "peer_connected id=" + str(id) + "\n"
	);
	
	server_multiplayer.peer_disconnected.connect(func(id: int):
		# handle client disconnection
		$Label.text += "peer_disconnected id=" + str(id) + "\n"
	);
	
	# use the new multiplayer API for this node and its descendants
	get_tree().set_multiplayer(server_multiplayer, get_path())
