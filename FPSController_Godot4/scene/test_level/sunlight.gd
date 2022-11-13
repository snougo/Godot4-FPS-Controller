extends DirectionalLight3D



func _ready():
	pass



func _process(delta):
	
	if Input.is_action_pressed("ui_left"):
		rotate_x(0.05 * delta)
	
	if Input.is_action_pressed("ui_right"):
		rotate_x(-0.05 * delta)



