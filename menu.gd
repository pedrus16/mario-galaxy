extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_host_button_pressed():
	game.host()

func _on_join_button_pressed():
	game.join($CenterContainer/VBoxContainer/IPInput.text)
