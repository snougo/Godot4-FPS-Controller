extends Node3D

@onready var anim_tree: AnimationTree = $AnimationTree

func _ready():
	pass


func _process(_delta):
	pass


func _on_visible_on_screen_notifier_3d_screen_entered():
	anim_tree.active = true


func _on_visible_on_screen_notifier_3d_screen_exited():
	anim_tree.active = false
