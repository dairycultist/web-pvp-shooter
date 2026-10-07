extends Node

func _ready() -> void:
	
	if multiplayer.is_server():
		return
	
	$ChatEntry.text_submitted.connect(func(new_text: String):
		
		send_message.rpc(get_parent().username, new_text)
		
		$ChatEntry.text = ""
	)

@rpc("any_peer", "call_local", "reliable", 0)
func send_message(username: String, msg: String):
	
	if multiplayer.is_server():
		return # the server needs a node to consume the RPC
	
	$ChatMessages.text += "\n[color=yellow][" + username + "][/color] " + msg
