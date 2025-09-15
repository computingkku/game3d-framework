extends CharacterModel

func init():
	animation_player = $AnimationPlayer
	weapon_collision = $"Rig/Skeleton3D/2H_Sword/WeaponArea/CollisionShape3D"
	load_data("knight")
