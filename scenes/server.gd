extends Node

func establish_multiplayer(server: MultiplayerPeer) -> void:
	
	# create a new multiplayer API
	var server_multiplayer := SceneMultiplayer.new()
	server_multiplayer.multiplayer_peer = server
	
	# connect to its signals
	server_multiplayer.peer_connected.connect(_on_peer_connected);
	server_multiplayer.peer_disconnected.connect(_on_peer_disconnected);
	
	# use the new multiplayer API for this node and its descendants
	get_tree().set_multiplayer(server_multiplayer, get_path())

func _on_peer_connected(id: int):
	# handle client connection
	$Label.text += "peer_connected id=" + str(id) + "\n"

func _on_peer_disconnected(id: int):
	# handle client disconnection
	$Label.text += "peer_disconnected id=" + str(id) + "\n"
