extends Button

func _ready() -> void:
	button_down.connect(_on_button_down)

func _on_button_down():
	Network.game_connect("127.0.0.1", 19132)
	Network.send("hamburger")
