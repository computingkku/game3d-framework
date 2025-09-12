extends CharacterBody3D

@export var data : MonsterData
@export var model_scene : PackedScene 
@onready var model: CharacterModel = $Skeleton_Warrior
@export var equip_weapon  = -1
@export var equip_shield  = -1
@export var equip_props :Array[int] = [0] 

func _ready() -> void:
	if model_scene: 
		$Skeleton_Warrior.queue_free()
		model = model_scene.instantiate()
		add_child(model)	
	model.play("idle")
	model.equip_weapon = equip_weapon
	model.equip_shield = equip_shield
	model.equip_props = equip_props
	model._update_state()
	$OmniLight3D/GPUParticles3D.emitting = true
	pass	

func _physics_process(delta: float) -> void:
	model.play("idle")
