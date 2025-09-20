extends Window

@onready var model: Node3D = $SubViewport/Model
var _model :Node3D = null
func _ready() -> void:
	if model.get_child_count()>0:
		_model = model.get_child(0)
		_model.play("MeleeLib/TPose")

var rot = 0.0
func _process(delta: float) -> void:
	rot += delta * 30
	if rot > 360 : rot=0
	if _model:
		_model.rotation_degrees.y = rot
