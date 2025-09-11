extends CharacterModel

#All Animations
#"1H_Melee_Attack_Chop"
#"1H_Melee_Attack_Slice_Diagonal"
#"1H_Melee_Attack_Slice_Horizontal"
#"1H_Melee_Attack_Stab"
#"1H_Ranged_Aiming"
#"1H_Ranged_Reload"
#"1H_Ranged_Shoot"
#"1H_Ranged_Shooting"
#"2H_Melee_Attack_Chop"
#"2H_Melee_Attack_Slice"
#"2H_Melee_Attack_Spin"
#"2H_Melee_Attack_Spinning"
#"2H_Melee_Attack_Stab"
#"2H_Melee_Idle"
#"2H_Ranged_Aiming"
#"2H_Ranged_Reload"
#"2H_Ranged_Shoot"
#"2H_Ranged_Shooting"
#"Block"
#"Block_Attack"
#"Block_Hit"
#"Blocking"
#"Cheer"
#"Death_A"
#"Death_A_Pose"
#"Death_B"
#"Death_B_Pose"
#"Dodge_Backward"
#"Dodge_Forward"
#"Dodge_Left"
#"Dodge_Right"
#"Dualwield_Melee_Attack_Chop"
#"Dualwield_Melee_Attack_Slice"
#"Dualwield_Melee_Attack_Stab"
#"Hit_A"
#"Hit_B"
#"Idle"
#"Interact"
#"Jump_Full_Long"
#"Jump_Full_Short"
#"Jump_Idle"
#"Jump_Land"
#"Jump_Start"
#"Lie_Down"
#"Lie_Idle"
#"Lie_Pose"
#"Lie_StandUp"
#"PickUp"
#"Running_A"
#"Running_B"
#"Running_Strafe_Left"
#"Running_Strafe_Right"
#"Sit_Chair_Down"
#"Sit_Chair_Idle"
#"Sit_Chair_Pose"
#"Sit_Chair_StandUp"
#"Sit_Floor_Down"
#"Sit_Floor_Idle"
#"Sit_Floor_Pose"
#"Sit_Floor_StandUp"
#"Spellcast_Long"
#"Spellcast_Raise"
#"Spellcast_Shoot"
#"Spellcasting"
#"T-Pose"
#"Throw"
#"Unarmed_Idle"
#"Unarmed_Melee_Attack_Kick"
#"Unarmed_Melee_Attack_Punch_A"
#"Unarmed_Melee_Attack_Punch_B"
#"Unarmed_Pose"
#"Use_Item"
#"Walking_A"
#"Walking_B"
#"Walking_Backwards"
#"Walking_C"

func init():
	animation_player = $AnimationPlayer
	weapons=[
		{"name":"ดาบสั้น","item":$"Rig/Skeleton3D/1H_Sword/1H_Sword","value":1,"icon":"res://assets/icons/sword1.png" },
		{"name":"ดาบยาว","item":$"Rig/Skeleton3D/2H_Sword/2H_Sword","value":2 ,"icon":"res://assets/icons/sword2.png"},
	]
	shields=[
		{"name":"ดาบธรรมดา","item":$"Rig/Skeleton3D/1H_Sword_Offhand/1H_Sword_Offhand", "value":0.5,"icon":"res://assets/icons/sword1.png"},
		{"name":"โล่กลมธรรมดา","item":$Rig/Skeleton3D/Round_Shield/Round_Shield, "value":1,"icon":"res://assets/icons/round_shield.png"},
		{"name":"โล่กลาง","item":$Rig/Skeleton3D/Badge_Shield/Badge_Shield, "value":1.2,"icon":"res://assets/icons/bshield.png"}, 
		{"name":"โล่เหลี่ยม","item":$Rig/Skeleton3D/Rectangle_Shield/Rectangle_Shield,"value":1.4,"icon":"res://assets/icons/rshield.png"},
		{"name":"โล่หนาม","item":$Rig/Skeleton3D/Spike_Shield/Spike_Shield, "value":1.6,"icon":"res://assets/icons/spike_shield.png"},
	]
	props=[
		{"name":"หมวกอัศวินเหล็ก","item":$Rig/Skeleton3D/Knight_Helmet/Knight_Helmet,"prop":"def","value":1,"icon": "res://assets/icons/helmet.png"},			
		{"name":"ผ้าคลุมอัศวิน","item":$Rig/Skeleton3D/Knight_Cape,"prop":"def","value":1,"icon": "res://assets/icons/cape.png"},			
	]
	
	actions["attack"]=["Unarmed_Melee_Attack_Kick","Unarmed_Melee_Attack_Punch_A","Unarmed_Melee_Attack_Punch_B"]
	actions["idle"]=["Idle","Unarmed_Idle"]
	actions["jump"]=["Jump_Idle"]
	actions["walk"]=["Walking_A","Walking_B"]
	actions["attack_weapon"]=["1H_Melee_Attack_Chop","1H_Melee_Attack_Slice_Diagonal","1H_Melee_Attack_Slice_Diagonal","1H_Melee_Attack_Slice_Horizontal","1H_Melee_Attack_Stab"]
	actions["idle_weapon"]=["Idle","2H_Melee_Idle"]
	actions["walk_weapon"]=["Walking_A","Walking_B"]
	actions["jump_weapon"]=["Jump_Idle"]
	actions["death"]=["Death_A","Death_B"]
	
