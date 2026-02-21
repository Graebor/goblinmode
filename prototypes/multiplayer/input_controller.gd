extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("down"):
		for event: InputEvent in InputMap.action_get_events("down"):
			if event is InputEventJoypadButton:
				var joypad_event: InputEventJoypadButton = event as InputEventJoypadButton
				if Input.is_joy_button_pressed(0, joypad_event.button_index):
					print("Device: 0, Joy A")


	
