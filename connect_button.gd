extends Button

@export var ip_text: TextEdit
@export var port_text: TextEdit
@export var player_id_text: TextEdit
@export var failure_label: Label

func _ready() -> void:
	button_down.connect(_on_button_down)

func _on_button_down():
	
	disabled = true
	text = "Attempting to connect..."
	failure_label.text = ""
	
	var ip := ip_text.text if ip_text.text else "127.0.0.1"
	var port := port_text.text.to_int() if port_text.text else 19132
	var username := player_id_text.text.replace(":", "").replace(";", "").replace(",", "").replace(" ", "").substr(0, 10) if player_id_text.text else "imdumb"
	
	var res := await Network.game_connect(ip, port, username)
	
	if res == Error.ERR_CANT_CONNECT:
		failure_label.text = "No response from server."
	elif res == Error.ERR_ALREADY_EXISTS:
		failure_label.text = "Server exists but username is taken."
	text = "Connect"
	disabled = false
