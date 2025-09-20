extends Control

func _on_window_close_requested() -> void:
	$inventory_window.visible = false
