extends Node3D

func establish_multiplayer(client: ENetMultiplayerPeer) -> void:
	
	multiplayer.multiplayer_peer = client
	
	multiplayer.peer_connected.connect(func(id: int):
		# spawn other peer
		print("peer_connected", id)
	);
	
	multiplayer.peer_disconnected.connect(func(id: int):
		# delete other peer
		print("peer_disconnected", id)
	);
	
	multiplayer.connected_to_server.connect(func():
		print("connected_to_server")
	)
	
	multiplayer.connection_failed.connect(func():
		print("connection_failed")
	)
	
	multiplayer.server_disconnected.connect(func():
		print("server_disconnected")
	)
