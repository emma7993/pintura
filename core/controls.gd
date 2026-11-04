class_name Controls
extends RefCounted
## Crea las acciones de teclado/control si todavía no existen
## (así cualquier escena funciona sola con F6, sin pasar por main.gd).


static func ensure() -> void:
	_action("move_left", [KEY_A, KEY_LEFT], JOY_BUTTON_DPAD_LEFT, JOY_AXIS_LEFT_X, -1.0)
	_action("move_right", [KEY_D, KEY_RIGHT], JOY_BUTTON_DPAD_RIGHT, JOY_AXIS_LEFT_X, 1.0)
	_action("move_up", [KEY_W, KEY_UP], JOY_BUTTON_DPAD_UP, JOY_AXIS_LEFT_Y, -1.0)
	_action("move_down", [KEY_S, KEY_DOWN], JOY_BUTTON_DPAD_DOWN, JOY_AXIS_LEFT_Y, 1.0)
	_action("jump", [KEY_SPACE], JOY_BUTTON_A, -1, 0.0)
	_action("attack", [KEY_J, KEY_X], JOY_BUTTON_X, -1, 0.0)         # tajo con el pincel (arriba/abajo + J)
	_action("dash", [KEY_SHIFT, KEY_K, KEY_C], JOY_BUTTON_B, -1, 0.0)
	_action("paint", [KEY_F], JOY_BUTTON_RIGHT_SHOULDER, -1, 0.0)  # pintar, tomar, mojar el pincel
	_action("interact", [KEY_E, KEY_ENTER], JOY_BUTTON_Y, -1, 0.0)


static func _action(action_name: String, keys: Array, joy_button: int, axis: int, axis_val: float) -> void:
	if InputMap.has_action(action_name):
		return
	InputMap.add_action(action_name, 0.3)
	for k in keys:
		var e := InputEventKey.new()
		e.physical_keycode = k
		InputMap.action_add_event(action_name, e)
	var b := InputEventJoypadButton.new()
	b.button_index = joy_button
	InputMap.action_add_event(action_name, b)
	if axis >= 0:
		var m := InputEventJoypadMotion.new()
		m.axis = axis
		m.axis_value = axis_val
		InputMap.action_add_event(action_name, m)
