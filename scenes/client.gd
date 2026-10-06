extends Node
class_name Client

func on_peer_connected(id: int):
	# spawn other peer
	$Label.text += "peer_connected id=" + str(id) + "\n"

func on_peer_disconnected(id: int):
	# delete other peer
	$Label.text += "peer_disconnected id=" + str(id) + "\n"

func on_connected_to_server():
	$Label.text += "connected_to_server\n"

func on_connection_failed():
	$Label.text += "connection_failed\n"

func on_server_disconnected():
	$Label.text += "server_disconnected\n"
	#Network.leave_server()
