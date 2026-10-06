extends Button

enum ClientType {
	HOST,
	REMOTE
}

@export var client_type: ClientType

@export var ip_input: LineEdit
@export var port_input: LineEdit
@export var username_input: LineEdit
@export var failure_label: Label

func _ready() -> void:
	button_down.connect(_on_button_down)
	
	# ensure you can't enter invalid characters in the username field
	username_input.text_changed.connect(func (new_text):
		var column := username_input.caret_column
		username_input.text = RegEx.create_from_string("[^A-Za-z0-9]+").sub(new_text, "", true)
		username_input.set_caret_column(column)
	)

func _on_button_down():
	
	disabled = true
	text = "Attempting to connect..."
	failure_label.text = ""
	
	var ip := "0.0.0.0" if client_type == ClientType.HOST else ip_input.text.strip_edges() if ip_input.text else "127.0.0.1"
	var port := port_input.text.to_int() if port_input.text else 19132
	var username := username_input.text
	
	if username == "":
		failure_label.text = "Username must not be empty."
	else:
		pass
		# if joining a server:
		# - instance the game scene
		# - configure root/client's peer to be a client
		# - swap to that scene

		# if creating a server:
		# - instance the game scene
		# - configure root/server's peer to be a server 
		# - configure root/client's peer to be a client
		# - swap to that scene

		## Create client.
		#var peer = ENetMultiplayerPeer.new()
		#peer.create_client(IP_ADDRESS, PORT)
		#multiplayer.multiplayer_peer = peer
		#
		## Create server.
		#var peer = ENetMultiplayerPeer.new()
		#peer.create_server(PORT, MAX_CLIENTS)
		#multiplayer.multiplayer_peer = peer
		
		#if res == Error.ERR_CANT_CONNECT:
			#failure_label.text = "No response from server."
		#elif res == Error.ERR_ALREADY_EXISTS:
			#failure_label.text = "Server exists but username is taken."
		#elif res == Error.ERR_UNAVAILABLE:
			#failure_label.text = "Server is full (8 players max)."
	
	text = "Connect" if client_type == ClientType.REMOTE else "Start server"
	disabled = false
