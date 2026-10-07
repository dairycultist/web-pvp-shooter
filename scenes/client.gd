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

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("escape"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			$EscapeMenu.visible = false
			$Chat/ChatEntry.release_focus()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			$EscapeMenu.visible = true
			$Chat/ChatEntry.grab_focus()

func _on_peer_connected(_id: int):
	pass

func _on_peer_disconnected(_id: int):
	pass

func _on_connected_to_server():
	pass

func _on_connection_failed():
	Network.leave_server("Server did not respond.")

func _on_server_disconnected():
	Network.leave_server("Server shut down by itself.")
