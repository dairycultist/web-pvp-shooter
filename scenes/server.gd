extends Node
class_name Server

func _enter_tree() -> void:
	
	if Network.server.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		return # no local server
	
	var api := SceneMultiplayer.new()
	api.multiplayer_peer = Network.server
	
	api.peer_connected.connect(_on_peer_connected)
	api.peer_disconnected.connect(_on_peer_disconnected)
	
	# use the new multiplayer API for this node and its descendants
	# this has to happen before its descendants have a chance to run
	# their _ready functions
	get_tree().set_multiplayer(api, get_path())

func _on_peer_connected(id: int):
	# handle client connection
	print("peer_connected id=" + str(id) + "\n")

func _on_peer_disconnected(id: int):
	# handle client disconnection
	print("peer_disconnected id=" + str(id) + "\n")
