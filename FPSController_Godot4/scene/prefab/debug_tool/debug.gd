extends Control


@export_node_path(CharacterBody3D) var target_node: NodePath

var target : CharacterBody3D

@onready var fps_label: Label = $PanelContainer/MarginContainer/VBoxContainer/fps
@onready var state_enter_label: Label = $PanelContainer/MarginContainer/VBoxContainer/state_enter
@onready var state_exit_label: Label = $PanelContainer/MarginContainer/VBoxContainer/state_exit
@onready var velocity_label: Label = $PanelContainer/MarginContainer/VBoxContainer/velocity
@onready var on_floor_label: Label = $PanelContainer/MarginContainer/VBoxContainer/on_floor


func _ready():
	var refresh_rate = DisplayServer.screen_get_refresh_rate()
	Engine.max_fps = int(refresh_rate)
	target = get_node(target_node)



func _process(_delta):
	
	fps_label.text = str(Engine.get_frames_per_second())
	
	state_enter_label.text = target.debug_state_enter
	state_exit_label.text = target.debug_state_exit
	
	var speed := Vector2(target.velocity.x, target.velocity.z).length()
	velocity_label.text = str(snapped(speed, 0.01))
	
	on_floor_label.text = "is on floor: " + str(target.is_on_floor())
