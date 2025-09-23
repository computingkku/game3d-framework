extends CanvasLayer

@onready var progress_bar: ProgressBar = $ProgressBar

func _ready() -> void:
	self.visible = true

var t = 0.0
func _process(delta: float) -> void:
	t = t+delta
	progress_bar.value = t*50
	if(t>2.0):
		queue_free()
