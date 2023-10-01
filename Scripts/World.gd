extends Node2D

var grid = []
var grid_width = 200
var grid_height = 200
var density = 60
var waterRockDensity = 3
var treeDensity = 6

onready var heartContainers = $CanvasLayer/Main/PlayerUI/VBoxContainer/HBoxContainer
onready var hungerBar = $CanvasLayer/Main/PlayerUI/VBoxContainer/TextureProgress
onready var woodCount = $CanvasLayer/Main/PlayerUI/HBoxContainer/WoodCount
onready var scoreLabel = $CanvasLayer/Main/PlayerUI/ScoreLabel
onready var numFoodLabel = $CanvasLayer/Main/PlayerUI/Inventory/Slot4/FoodLabel
onready var woodCountLabel = $CanvasLayer/Main/PlayerUI/HBoxContainer/WoodCount
onready var inventoryContainer = $CanvasLayer/Main/PlayerUI/Inventory
onready var swordTexture = $CanvasLayer/Main/PlayerUI/Inventory/Slot1/Sword
onready var gameOver = $CanvasLayer/Main/GameOver
onready var newhi = $CanvasLayer/Main/GameOver/newhi

var tree = preload("res://GameObjects/Tree.tscn")
var bush = preload("res://GameObjects/BushSlime.tscn")

func _ready():
	get_tree().paused = false
	randomize()
#	seed(69420)
	# Creating 2d Arrays
	for i in grid_width:
		grid.append([])
		for j in grid_height:
			grid[i].append(0) # Set a starter value for each position
	
	makeNoiseGrid()
	
	
	# Lets iterate it twice
	iterateTileGrid()
	iterateTileGrid()
	addTrees()
	$TileMap.bake_navigation = true
	

func makeNoiseGrid():
	for i in range(grid_width):
		for j in range(grid_height):
			if i == 0 or i == grid_width-1 or j == 0 or j == grid_height-1: # Border
				# grid[i][j] = 1
				# $TileMap.set_cell(i, j, 0)
				grid[i][j] = 0 # Water is no value
				$TileMap.set_cell(i, j, 1) #Water is index 1
			elif $TileMap.get_cell(i, j) == 0: #land (index 0) this is for initial so player isnt in water initially
				grid[i][j] = 1
			elif randi()%100+1 <= density:
				grid[i][j] = 1
				$TileMap.set_cell(i, j, 0)
			else:
				grid[i][j] = 0
				$TileMap.set_cell(i, j, 1) # water

func iterateTileGrid():
	for i in range(grid_width):
		for j in range(grid_height):
			if i == 0 or i == grid_width-1 or j == 0 or j == grid_height-1: # Walls
				pass # Do nothing
			else:
				var neighbors = checkNeighbors(i, j)
				if neighbors > 4:
					$TileMap.set_cell(i, j, 0) # land
				elif neighbors < 4: #3
					$TileMap.set_cell(i, j, 1) # Water
					if randi()%100+1 <= waterRockDensity:
						$TileMap.set_cell(i, j, 2) #Decorated Water lol
				else:
					pass
	$TileMap.update_bitmask_region(Vector2(0,0), Vector2(grid_width, grid_height))
	updateArray()

func updateArray():
	for i in range(grid_width):
		for j in range(grid_height):
			if $TileMap.get_cell(i, j) == 1: #water (index 1)
				grid[i][j] = 0 #water (0 means no value)
			else:
				grid[i][j] = 1 #land (1 mean value, thats land)

func checkNeighbors(x, y):
	var left = grid[x-1][y-1] + grid[x-1][y] + grid[x-1][y+1]
	var topAndBottom = grid[x][y+1] + grid[x][y-1]
	var right = grid[x+1][y-1] + grid[x+1][y] + grid[x+1][y+1]
	return left + topAndBottom + right

func addTrees():
	for cellpos in $TileMap.get_used_cells():
		var cell = $TileMap.get_cellv(cellpos)
		if cell == 0 and randi()%100+1 <= treeDensity:
			if randi()%100+1 <= 65:
				var treeInstance = tree.instance()
				treeInstance.position = $TileMap.map_to_world(cellpos) * $TileMap.scale
				treeInstance.position.x += 8
				treeInstance.position.y += 8
				add_child(treeInstance)	
			else:
				var bushInstance = bush.instance()
				bushInstance.position = $TileMap.map_to_world(cellpos) * $TileMap.scale
				bushInstance.position.x += 8
				bushInstance.position.y += 8
				add_child(bushInstance)	
			
#	for i in range(grid_width):
#		for j in range(grid_height):
#			if $TileMap.get_cell(i, j) == 0:
#				var cellposLocal = $TileMap.map_to_world(Vector2(i,j))
#				var cellposGlobal = $TileMap.to_global(cellposLocal)
#				var cell = $TileMap.get_cellv(cellposGlobal)
#				if randi()%100+1 <= treeDensity:
#					var treeInstance = tree.instance()
#					treeInstance.position = $TileMap.map_to_world(cellposLocal) * $TileMap.scale
#					treeInstance.position.x += 8
#					treeInstance.position.y += 8
#					add_child(treeInstance)
	

func givePlayerFood():
	$Player.food += 1
	$CanvasLayer/Main/PlayerUI/Inventory/Slot4/FoodLabel.text = str($Player.food)

func givePlayerWood():
	$Player.wood += 1
	$CanvasLayer/Main/PlayerUI/HBoxContainer/WoodCount.text = str($Player.wood)

func givePlayerPoints():
	$Player.points += 50
	scoreLabel.text = "Score: "+str($Player.points)
	
func _on_Quit_pressed():
	get_tree().change_scene("res://Scenes/Main Menu.tscn")
