extends Node

var savePath = "user://slimeisland.dat"
var playerData = null

func save(points):
	var data = {
		"Points" : points
	}
	
	var file = File.new()
	var error = file.open(savePath, File.WRITE)
	if error == OK:
		file.store_var(data)
		file.close()

func loadGame():
	var file = File.new()
	if file.file_exists(savePath):
		var error = file.open(savePath, File.READ)
		if error == OK:
			var playerData = file.get_var()
			file.close()
			print(playerData)

func getPlayerData():
	return playerData
	
