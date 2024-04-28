extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	tcgLogger.NetworkMessage.connect(on_network_message)
	tcgLogger.LocalMessage.connect(on_local_message)
	$Network/DebubToggle.pressed.connect(on_debug_toggled)
	
func on_local_message(type_id: int, contents: String):
	var new_label = Label.new()
	new_label.label_settings = LabelSettings.new()
	var id
	if type_id == tcgLogger.ERROR:
		new_label.label_settings.font_color = Color.CRIMSON
		id = "ERROR"
	if type_id == tcgLogger.DEBUG:
		new_label.label_settings.font_color = Color.WEB_GREEN
		id = "DEBUG"
		
	new_label.text = "(" + id + "): " + contents
	$"Network/Debug Log/MessageBox".add_child(new_label)
		
func on_network_message(peer_id: int, contents: String):
	var new_label = Label.new()
	new_label.label_settings = LabelSettings.new()
	var name: String
	if peer_id == tcgLogger.SERVER:
		name = "SERVER"
	else:
		name = tcgNetworkManager.ConnectedPlayers[peer_id].Name
		if peer_id == tcgNetworkManager.HostId:
			name += " (HOST)"
	new_label.text = "%s : %s" % [name, contents]
	$"Network/Debug Log/MessageBox".add_child(new_label)

func on_debug_toggled():
	tcgLogger.debug_message("debug_visibility_toggled")
	$"Network/Debug Log".visible = !$"Network/Debug Log".visible
