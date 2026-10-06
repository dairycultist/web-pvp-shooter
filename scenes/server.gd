extends Node
class_name Server

func on_peer_connected(id: int):
	# handle client connection
	$Label.text += "peer_connected id=" + str(id) + "\n"

func on_peer_disconnected(id: int):
	# handle client disconnection
	$Label.text += "peer_disconnected id=" + str(id) + "\n"
