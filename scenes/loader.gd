extends Control

const MAIN_SCENE := "res://scenes/main.tscn"

@onready var progress_bar: ProgressBar = $Center/VBox/ProgressBar
@onready var status_label: Label = $Center/VBox/Status

var _requested := false

func _ready() -> void:
	# Fullscreen stretch
	set_process(true)
	status_label.text = "Loading..."
	progress_bar.value = 0
	# Start threaded load
	var err := ResourceLoader.load_threaded_request(MAIN_SCENE)
	if err != OK:
		status_label.text = "Failed to start loading (" + str(err) + ")"
	else:
		_requested = true

func _process(_delta: float) -> void:
	if not _requested:
		return
	var prog: Array[float] = []
	var st := ResourceLoader.load_threaded_get_status(MAIN_SCENE, prog)
	match st:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if prog.size() > 0:
				progress_bar.value = clamp(prog[0] * 100.0, 0.0, 100.0)
		ResourceLoader.THREAD_LOAD_FAILED:
			status_label.text = "Load failed. Retrying..."
			_requested = false
			# Fallback to blocking load
			var packed := load(MAIN_SCENE)
			if packed:
				get_tree().change_scene_to_packed(packed)
		ResourceLoader.THREAD_LOAD_LOADED:
			var packed := ResourceLoader.load_threaded_get(MAIN_SCENE)
			if packed:
				get_tree().change_scene_to_packed(packed)
