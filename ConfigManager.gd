extends Node

var show_fps := false
var volume := 1.0

func save():
	var config = ConfigFile.new()
	config.set_value("settings", "show_fps", show_fps)
	config.set_value("settings", "volume", volume)
	config.save("user://settings.cfg")

func load():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		show_fps = config.get_value("settings", "show_fps", false)
		volume = config.get_value("settings", "volume", 1.0)
