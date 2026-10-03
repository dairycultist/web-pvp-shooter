extends Button

@export var label: Label

func _ready() -> void:
	button_down.connect(_on_button_down)

func _on_button_down():
	disabled = true
	text = "Attempting to connect..."
	if not await Network.game_connect("127.0.0.1", 19132):
		label.text = "No response from server."
		text = "Connect"
		disabled = false
