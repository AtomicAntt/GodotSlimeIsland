extends "res://Scripts/RockSlime.gd"

func _ready():
	if randi()%100+1 <= 30:
		isBush = false
		if randi()%100+1 <= 33:
			state = States.WANDER
		else:	
			state = States.DORMANT
			$AnimatedSprite.play("Bush")
	else:
		state = States.DORMANT
		$AnimatedSprite.play("Bush")
	
#	$CollisionShape2D.disabled = true
