extends Sprite2D

var speed = 1.0;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("set_speed"):
		speed += 0.2
		material.set_shader_parameter("speed", speed)
