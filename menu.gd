extends Control

signal host_clicked
signal join_clicked(address: String)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_host_button_pressed():
	host_clicked.emit()

func _on_join_button_pressed():
	join_clicked.emit($CenterContainer/VBoxContainer/IPInput.text)
