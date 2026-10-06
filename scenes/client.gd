extends Node
class_name Client

func on_peer_connected(id: int):
	
	if id == 1: # ignore the server peer
		return
	
	# spawn other peer
	print("peer_connected id=" + str(id) + "\n")

func on_peer_disconnected(id: int):
	
	if id == 1: # ignore the server peer
		return
	
	# delete other peer
	print("peer_disconnected id=" + str(id) + "\n")

func on_connected_to_server():
	print("connected_to_server\n")

func on_connection_failed():
	Network.leave_server("Server did not respond.")

func on_server_disconnected():
	Network.leave_server("Server shut down by itself.")
