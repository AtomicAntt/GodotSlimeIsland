extends Area2D
var health = 100

onready var world = get_tree().get_nodes_in_group("world")[0]

func hurt():
	health -= 20
	$Health.visible = true
	$Health/TextureProgress.value = health
	if health <= 0:
		world.givePlayerWood()
		queue_free()
		
