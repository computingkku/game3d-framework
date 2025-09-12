extends CharacterModel

func init():
	animation_player = $AnimationPlayer
	weapons=[
		{"name":"มีดกระดูก","item":$Rig/Skeleton3D/RightHand/Blade,"value":1,"icon":"res://assets/icons/blade.png" },
		{"name":"ขวานปีศาจ","item":$Rig/Skeleton3D/RightHand/Axe,"value":2 ,"icon":"res://assets/icons/axe.png"},
	]
	shields=[
		{"name":"โล่กระดูก","item":$Rig/Skeleton3D/BoneAttachment3D/Skeleton_Shield_Small_A, "value":1,"icon":"res://assets/icons/skeleton_shield.png"},
		{"name":"โล่หัวกระโหลก","item":$Rig/Skeleton3D/BoneAttachment3D/Skeleton_Shield_Large_A, "value":1.2,"icon":"res://assets/icons/skeleton_shield_big.png"}, 
	]
	props=[
		{"name":"หมวกนักรบกระดูก","item":$Rig/Skeleton3D/Skeleton_Warrior_Helmet/Skeleton_Warrior_Helmet,"prop":"def","value":1,"icon":"res://assets/icons/skeleton_helmet.png" },					
	]
	
	actions["attack"]=["Unarmed_Melee_Attack_Kick","Unarmed_Melee_Attack_Punch_A","Unarmed_Melee_Attack_Punch_B"]
	actions["idle"]=["Idle","Unarmed_Idle","Idle_Combat","Idle_B"]
	actions["jump"]=["Jump_Idle"]
	actions["walk"]=["Walking_A","Walking_B"]
	actions["attack_weapon"]=["1H_Melee_Attack_Chop","1H_Melee_Attack_Slice_Diagonal","1H_Melee_Attack_Slice_Diagonal","1H_Melee_Attack_Slice_Horizontal","1H_Melee_Attack_Stab"]
	actions["idle_weapon"]=["Idle","2H_Melee_Idle"]
	actions["walk_weapon"]=["Walking_A","Walking_B"]
	actions["jump_weapon"]=["Jump_Idle"]
	actions["death"]=["Death_A","Death_B","Death_C_Skeletons"]
	
