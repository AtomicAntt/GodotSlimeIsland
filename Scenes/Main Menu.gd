extends Control

func _ready():
	get_tree().paused = false
	Global.loadGame()
	if Global.getPlayerData() != null:
		$LabelGlobal.text = "Highscore: "+str(Global.getPlayerData()["Points"])
	elif Global.getPlayerData() == null:
		print("no")


func _on_Button_pressed():
	$AudioStreamPlayer.stop()
	get_tree().change_scene("res://Scenes/World.tscn")
