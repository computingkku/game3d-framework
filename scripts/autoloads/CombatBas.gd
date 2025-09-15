extends Node
signal hit_confirmed(attacker, victim, event)     # ยืนยันโดน
signal died(victim, event)
signal status_applied(target, status_effect)

func _ready():
	randomize()
