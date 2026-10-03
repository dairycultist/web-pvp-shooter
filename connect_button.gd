extends Button

@export var ip_text: TextEdit
@export var port_text: TextEdit
@export var failure_label: Label

func _ready() -> void:
	button_down.connect(_on_button_down)

func _on_button_down():
	
	disabled = true
	text = "Attempting to connect..."
	failure_label.text = ""
	
	var ip := ip_text.text if ip_text.text else "127.0.0.1"
	var port := port_text.text.to_int() if port_text.text else 19132
	
	if not await Network.game_connect(ip, port):
		failure_label.text = "No response from server."
		text = "Connect"
		disabled = false
