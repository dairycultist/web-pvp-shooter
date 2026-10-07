extends Node

func _ready() -> void:
	
	if multiplayer.is_server():
		return
	
	$ChatEntry.text_submitted.connect(func(new_text: String):
		
		send_message.rpc(new_text, get_parent().username)
		
		$ChatEntry.text = ""
	)

@rpc("any_peer", "call_local", "reliable", 0)
func send_message(msg: String, username: String = ""):
	
	if multiplayer.is_server():
		return # the server needs a node to consume the RPC
	
	if username:
		$ChatMessages.text += "\n[color=yellow][" + username + "][/color] " + msg
	else:
		$ChatMessages.text += "\n[color=yellow]" + msg + "[/color]"
