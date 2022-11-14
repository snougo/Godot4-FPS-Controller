extends CharacterBody3D


enum MotionState {IDLE, WALK, RUN, UPSTAIR, JUMP, JUMPING, SLIDING, FALLING}

const GRAVITY = -9.8

@export_range(0.1, 1.0, 0.1) var mouse_sensitivity: float = 0.3
@export_range(1.0, 10.0, 0.1) var walk_speed: float = 2.0
@export_range(3.0, 60.0, 0.1) var run_speed: float = 6.0
@export_range(1.0, 10.0, 0.1) var jump_height: float = 5.0
@export var double_jump: bool = false

var mouse_pos_relative: Vector2 = Vector2.ZERO
var input_dir: Vector2 = Vector2.ZERO
var motion_dir: Vector3 = Vector3.ZERO

var move_speed: float = 0

var current_state = null
var preview_state = null

var is_collided: bool = false

var jump_count: int = 0

var debug_state_enter: String
var debug_state_exit: String

@onready var fps_camera: Camera3D = $head/fps_camera
@onready var up_stair_cast: ShapeCast3D = $UpStairCast
@onready var stair_cast_1: RayCast3D = $StairCast1
@onready var stair_cast_2: RayCast3D = $StairCast2


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



func _input(event):
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		if event is InputEventMouseMotion:
			mouse_pos_relative = event.relative
			mouselook()
		
		if event is InputEventKey:
			if event.is_action_pressed("ui_cancel"):
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		
		if event is InputEventKey:
			if event.is_action_pressed("ui_accept"):
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



func _process(_delta):
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		if is_on_floor():
			get_motion_dir()
		
		motion_state_manager()
		motion_state_match()



func _physics_process(delta):
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		apply_motion(delta)



func mouselook():
	var mouse_motion_x = mouse_pos_relative.y * mouse_sensitivity * -0.01
	var mouse_motion_y = mouse_pos_relative.x * mouse_sensitivity * -0.01
	
	self.rotate_y(mouse_motion_y)
	
	fps_camera.rotate_x(mouse_motion_x)
	fps_camera.rotation.x = clamp(fps_camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))



func get_motion_dir():
	input_dir = Input.get_vector("move_right", "move_left", "move_back", "move_forward").normalized()
	motion_dir = Vector3(input_dir.x, 0, input_dir.y)
	motion_dir = motion_dir.rotated(Vector3.UP, rotation.y).normalized()



func apply_motion(delta):
	
	if not is_on_floor():
		motion_dir.x = lerpf(motion_dir.x, 0, 0.01)
		motion_dir.z = lerpf(motion_dir.z, 0, 0.01)
		velocity.y += delta * GRAVITY
	
	velocity.x = lerpf(velocity.x, motion_dir.x * move_speed, 0.1)
	velocity.z = lerpf(velocity.z, motion_dir.z * move_speed, 0.1)
	
	is_collided = move_and_slide()



func state_change(new_state):
	preview_state = current_state
	current_state = new_state
	
	if current_state != preview_state:
		
		if current_state == MotionState.IDLE:
			debug_state_enter = "idle enter"
		
		if current_state == MotionState.WALK:
			debug_state_enter = "walk enter"
			move_speed = walk_speed
		
		if current_state == MotionState.RUN:
			debug_state_enter = "run enter"
			move_speed = run_speed
		
		if current_state == MotionState.UPSTAIR:
			debug_state_enter = "upstair enter"
			floor_max_angle = deg_to_rad(90.0)
			move_speed = 1.5
		
		if current_state == MotionState.JUMP:
			debug_state_enter = "jump enter"
			velocity.y = jump_height
		
		if current_state == MotionState.JUMPING:
			debug_state_enter = "jumping enter"
		
		if current_state == MotionState.SLIDING:
			debug_state_enter = "sliding enter"
		
		if current_state == MotionState.FALLING:
			debug_state_enter = "falling enter"
		
		
		if preview_state == MotionState.IDLE:
			debug_state_exit = "idle exit"
		
		if preview_state == MotionState.WALK:
			debug_state_exit = "walk exit"
		
		if preview_state == MotionState.RUN:
			debug_state_exit = "run exit"
		
		if preview_state == MotionState.UPSTAIR:
			debug_state_exit = "upstair exit"
			floor_max_angle = deg_to_rad(45.0)
		
		if preview_state == MotionState.JUMP:
			debug_state_exit = "jump exit"
		
		if preview_state == MotionState.JUMPING:
			debug_state_exit = "jumping exit"
		
		if preview_state == MotionState.SLIDING:
			debug_state_exit = "sliding exit"
		
		if preview_state == MotionState.FALLING:
			debug_state_exit = "falling exit"



func motion_state_manager():
	
	if is_on_floor():
		
		if input_dir.length() == 0:
			state_change(MotionState.IDLE)
		else:
			if Input.get_action_strength("run"):
				state_change(MotionState.RUN)
			else:
				state_change(MotionState.WALK)
		
		if Input.get_action_strength("jump"):
			state_change(MotionState.JUMP)
		
		if stair_cast_2.is_colliding():
			if stair_cast_2.get_collider().is_in_group("stair"):
				if not stair_cast_1.is_colliding():
					state_change(MotionState.UPSTAIR)
		
		jump_count = 0
	
	else:
		if velocity.y < 0:
			if is_collided:
				state_change(MotionState.SLIDING)
			else:
				state_change(MotionState.FALLING)
		
		if velocity.y > 0:
			if not up_stair_cast.is_colliding():
				state_change(MotionState.JUMPING)



func motion_state_match():
	
	match current_state:
		
		MotionState.IDLE:
			idle()
		
		MotionState.WALK:
			walk()
		
		MotionState.RUN:
			run()
		
		MotionState.UPSTAIR:
			upstair()
		
		MotionState.JUMP:
			jump()
		
		MotionState.JUMPING:
			jumping()
		
		MotionState.SLIDING:
			sliding()
		
		MotionState.FALLING:
			falling()



func idle():
	pass



func walk():
	pass



func run():
	pass



func upstair():
	var floor_point: Vector3 = Vector3.ZERO
	var up_stair_point: Vector3 = Vector3.ZERO
	
	if get_last_slide_collision() != null:
		floor_point = get_last_slide_collision().get_position(0)
	
	if up_stair_cast.is_colliding():
		if up_stair_cast.get_collider(0).is_in_group("stair"):
			up_stair_point = up_stair_cast.get_collision_point(0)
	
	get_motion_dir()
	
	if motion_dir.length() != 0:
		velocity.y = ease((up_stair_point.y - floor_point.y), 20)
		velocity.x = lerpf(velocity.x, motion_dir.x * move_speed, 0.3)
		velocity.z = lerpf(velocity.z, motion_dir.z * move_speed, 0.3)



func jump():
	jump_count += 1



func jumping():
	if double_jump:
		if jump_count < 2:
			if Input.is_action_just_pressed("jump"):
				jump_count += 1
				velocity.y = jump_height



func sliding():
	pass



func falling():
	pass



func _on_area_3d_body_entered(_body):
	global_position = get_parent().get_node("Marker3D").global_position
