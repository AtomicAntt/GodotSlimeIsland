extends KinematicBody2D

var velocity = Vector2()
var direction = Vector2()
var speed = 0
onready var nav = $NavigationAgent2D
onready var player = get_tree().get_nodes_in_group("player")[0]
onready var world = get_tree().get_nodes_in_group("world")[0]

var attackWait = 0.8
var wanderWait = 3

var isBush = true

var health = 100

var sight = 200

enum States {WANDER, ATTACK, STUNNED, DORMANT}
var state = States.WANDER

func _ready():
	$ChargeTimer.connect("timeout", self, "charge")
	$ChargeTimer.wait_time = wanderWait + rand_range(0, 1)
	var direction = global_position.direction_to(nav.get_next_location())
	if randi()%100+1 <= 30:
		isBush = false
	
func _physics_process(delta):
	# var direction = global_position.direction_to(nav.get_next_location())
	if state != States.DORMANT:
		velocity = move_and_slide(direction * speed)
		speed = lerp(speed, 0, 0.1)
		if speed <= 160 and $AnimationPlayer.is_playing() == false:
			$AnimatedSprite.play("Idle")
#	nav.set_velocity(velocity)

	if state == States.WANDER:
		var distanceToPlayer = global_position.distance_to(player.get_global_position())
		if distanceToPlayer <= sight:
			print("detected")
			$AnimationPlayer.play("Detect")
			state = States.ATTACK
			$ChargeTimer.wait_time = 0.4
#		$ChargeTimer.wait_time = wanderWait

func charge():
#	nav.set_target_location(player.global_position)
#	direction = global_position.direction_to(nav.get_next_location())
	if state != States.DORMANT and state != States.STUNNED:
		$AnimatedSprite.play("Charge")
		$AnimationPlayer.play("Charge")

func launch():
	speed = 650

func hurt(pushDir, damage):
	if not isBush:
		state = States.STUNNED
		health -= damage
		$Health.visible = true
		$Health/TextureProgress.value = health
		if health <= 0:
			world.givePlayerPoints()
			queue_free()
		$AnimatedSprite.play("Air")
		$AnimationPlayer.play("Hurt")
	#	$CollisionShape2D.set_deferred("Disabled", false)
		$StunTimer.start()
		direction = pushDir
		launch()
	else:
		health -= damage
		$Health.visible = true
		$Health/TextureProgress.value = health
		if health <= 0:
			world.givePlayerFood()
			queue_free()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Charge" and state == States.ATTACK:
		nav.set_target_location(player.global_position)
		direction = global_position.direction_to(nav.get_next_location())
		$AnimatedSprite.play("Air")
		launch()
		$ChargeTimer.wait_time = attackWait + rand_range(0, 1)
	elif state == States.WANDER:
		var targetLocation = get_global_position() + Vector2(rand_range(-100, 100), rand_range(-100, 100))
		direction = global_position.direction_to(targetLocation)
		$AnimatedSprite.play("Air")
		launch()
		$ChargeTimer.wait_time = wanderWait + rand_range(0, 1)

func _on_Area2D_body_entered(body):
	if body.is_in_group("player") and state != States.STUNNED and state != States.DORMANT:
		body.hurt()

func _on_StunTimer_timeout():
	state = States.ATTACK
	charge()
	$ChargeTimer.wait_time = attackWait + rand_range(0, 1)
