extends Resource
class_name DamageEvent

@export var amount: float = 0.0
@export var hit_point: Vector3 = Vector3.ZERO
@export var hit_normal: Vector3 = Vector3.UP
@export var knockback: Vector3 = Vector3.ZERO
@export var is_crit: bool = false
@export var tags: PackedStringArray = [&"slash", &"physical"]
var source: Node
