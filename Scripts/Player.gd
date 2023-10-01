extends KinematicBody2D

onready var world = get_tree().get_nodes_in_group("world")[0]

var lives = 5
var hunger = 100

var wood = 0
var food = 0

var points = 0

var hasSword = false
var swordEquipped = false

var foodEquipped = false

var velocity
var speed = 100
var mousePos
export var handRadius = 12
var swordRadius = 3
var offsetX = -10
var offsetY = -2

var swordOffsetX = 0
var swordOffsetY = 4

var damage = 20
var swordDamage = 40

var invulnerable = false

var momentumArray = []
var momentumTime = 0.5

var bushSlimeChance = 50

var impacting = false # If your hand is in an object that is hittable, then true

var bushSlime = preload("res://GameObjects/BushSlime.tscn")
var heart = preload("res://Assets/Heart.png")
var emptyHeart = preload("res://Assets/EmptyHeart.png")


func _physics_process(delta):
	var mousePos = get_global_mouse_position()
	if global_position.x > mousePos.x:
		$Sprite.flip_h = true
	elif global_position.x < mousePos.x:
		$Sprite.flip_h = false
		
	var direction = (mousePos - global_position).normalized()
	$Hand.position = (direction * handRadius) + Vector2(offsetX, offsetY)
#	if mousePos.distance_to($Hand.get_global_position()) > swordRadius:	
	$Sword.rotation_degrees = rad2deg(direction.angle())
	$Sword.position = (direction * swordRadius) + Vector2(swordOffsetX, swordOffsetY)
	
#	if Input.is_action_pressed("fire"):
#		$Hand.visible = true
#		$Hand/CollisionShape2D.set_deferred("Disabled", true)
#		$Hand.position = (direction * handRadius) + Vector2(offsetX, offsetY)
#	else:
#		$Hand.visible = false
#		$Hand/CollisionShape2D.set_deferred("Disabled", false)
	
	if momentumTime * Engine.iterations_per_second == momentumArray.size():
		momentumArray.pop_front()
	
	momentumArray.append($Hand.position)
	
	velocity = Vector2()
	if Input.is_action_pressed("up"):
		velocity.y -= 1
		$AnimationPlayer.play("Walk")
	if Input.is_action_pressed("down"):
		velocity.y += 1
		$AnimationPlayer.play("Walk")		
	if Input.is_action_pressed("left"):
		velocity.x -= 1
		$AnimationPlayer.play("Walk")
	if Input.is_action_pressed("right"):
		velocity.x += 1
		$AnimationPlayer.play("Walk")
		
	
	
	if velocity == Vector2():
		$Sprite.rotation_degrees = 0
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Idle")
	
	if Input.is_action_pressed("One"):
		if hasSword:
			swordEquipped = true
			equipSword()
		for i in range(4):
			world.inventoryContainer.get_node("Slot"+str(i+1)).modulate.a = 0.5
		world.inventoryContainer.get_node("Slot1").modulate.a = 1
	if Input.is_action_pressed("two"):
		swordEquipped = false
		equipHand()
		for i in range(4):
			world.inventoryContainer.get_node("Slot"+str(i+1)).modulate.a = 0.5
		world.inventoryContainer.get_node("Slot2").modulate.a = 1
	if Input.is_action_pressed("three"):
		swordEquipped = false
		equipHand()
		for i in range(4):
			world.inventoryContainer.get_node("Slot"+str(i+1)).modulate.a = 0.5
		world.inventoryContainer.get_node("Slot3").modulate.a = 1
	if Input.is_action_pressed("four"):
		foodEquipped = true
		for i in range(4):
			world.inventoryContainer.get_node("Slot"+str(i+1)).modulate.a = 0.5
		world.inventoryContainer.get_node("Slot4").modulate.a = 1
		
	if Input.is_action_just_pressed("click"):
		print("ho")
		if food > 0:
			print("hi")
			food -= 1
			if hunger <= 80:
				hunger += 20
				var hungerBar = world.hungerBar
				hungerBar.value += 20
			elif hunger > 80:
				hunger = 100
				var hungerBar = world.hungerBar
				hungerBar.value = 100
	
	
	velocity = velocity.normalized()
	velocity = move_and_slide(velocity * speed)

func calculateMomentumValue():
	var magnitude = 0
	for i in range(momentumArray.size()):
		if i < momentumArray.size()-1:
			magnitude += momentumArray[i].distance_to(momentumArray[i+1])
	return magnitude
		

func _on_Hand_area_entered(area):
#	print(calculateMomentumValue())
	if area.is_in_group("tree") and impacting == false and calculateMomentumValue() >= 7 and not swordEquipped:
		impacting = true
		area.hurt()
		world.woodCount.text = str(wood)
		area.get_node("AnimationPlayer").play("hurt")
	if area.is_in_group("bush") and impacting == false and calculateMomentumValue() >= 7 and not swordEquipped:
		impacting = true
#		if randi()%100+1 <= bushSlimeChance:
#			var slimeInstance = bushSlime.instance()
#			slimeInstance.position = area.position
#			world.add_child(slimeInstance)
#			area.queue_free()
#		else:
#			impacting = true
#			print("got a bush")
#			area.get_node("AnimationPlayer").play("hurt")
		var entity = area.get_owner()
		if area.is_in_group("bush"):
#			print("yep")
			entity.hurt(global_position.direction_to($Hand.global_position), damage)
			if entity.isBush == true:
				entity.get_node("AnimationPlayer").play("Hurt")
				world.numFoodLabel.text = str(food)

func _on_Hand_area_exited(area):
	impacting = false

func hurt():
	if not invulnerable:
		lives -= 1
		var heartContainer = world.heartContainers
		heartContainer.get_node("Heart"+ str(lives+1)).texture = emptyHeart
		$HurtAnimationPlayer.play("Hurt")
		invulnerable = true
		if lives <= 0:
			get_tree().paused = true
			world.gameOver.visible = true
			if Global.playerData == null:
				world.newhi.visible = true				
				Global.save(points)
			else:
				if Global.playerData["Points"] < points:
					world.newhi.visible = true
					Global.save(points)

func _on_HurtAnimationPlayer_animation_finished(anim_name):
	if anim_name == "Hurt":
		invulnerable = false

func _on_HungerTimer_timeout():
	hunger -= 1
	var hungerBar = world.hungerBar
	hungerBar.value -= 1

func equipSword():
	$Hand.visible = false
	$Sword.visible = true
	$Hand.monitoring = false
	$Sword.monitoring = true

func equipHand():
	$Hand.visible = true
	$Sword.visible = false
	$Hand.monitoring = true
	$Sword.monitoring = false

func _on_Sword_area_entered(area):
	if area.is_in_group("tree") and impacting == false and calculateMomentumValue() >= 7 and swordEquipped:
		impacting = true
		area.hurt()
		world.woodCount.text = str(wood)
		area.get_node("AnimationPlayer").play("hurt")
	if area.is_in_group("bush") and impacting == false and calculateMomentumValue() >= 7 and swordEquipped:
		impacting = true
#		if randi()%100+1 <= bushSlimeChance:
#			var slimeInstance = bushSlime.instance()
#			slimeInstance.position = area.position
#			world.add_child(slimeInstance)
#			area.queue_free()
#		else:
#			impacting = true
#			print("got a bush")
#			area.get_node("AnimationPlayer").play("hurt")
		var entity = area.get_owner()
		if area.is_in_group("bush"):
#			print("yep")
			entity.hurt(global_position.direction_to($Hand.global_position), swordDamage)
			if entity.isBush == true:
				entity.get_node("AnimationPlayer").play("Hurt")
				world.numFoodLabel.text = str(food)


func _on_Sword_area_exited(area):
	impacting = false

func _on_Button_pressed():
	if wood >= 10:
		wood -= 10
		hasSword = true
		world.woodCountLabel.text = str(wood)
		world.swordTexture.visible = true

func gameOver():
	pass
