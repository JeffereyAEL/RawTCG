extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	tcgLogger.LocalMessage.connect(on_local_message)
	tcgLogger.NetworkMessage.connect(on_network_message)
	$Network/NetworkingButtons/InitButtons/HostBtn.pressed.connect(host)
	$Network/NetworkingButtons/InitButtons/JoinBtn.pressed.connect(join)
	$Network/NetworkingButtons/startBtn.pressed.connect(start_game)
	tcgNetworkManager.NewPlayerSynced.connect(on_new_player_synced)
	tcgNetworkManager.ServerEstablished.connect(on_connected_to_server)
	multiplayer.connected_to_server.connect(on_connected_to_server)
	$Network/NetworkingButtons/startBtn.hide()
	tcgLogger.debug_message("tcg_lobby._ready()")
	
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
	$Debug/DebugConsole.add_child(new_label)
		
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
	$Debug/DebugConsole.add_child(new_label)
	
func host():
	var player_name: String = $Network/PlayerInfo/Values/PlayerNameInput.text
	var deck_name: String = $Network/PlayerInfo/Values/DeckNameInput.text
	if player_name.is_empty():
		tcgLogger.error_message("You need to give your Player a name")
		return
	if deck_name.is_empty():
		tcgLogger.error_message("You need to give your Deck a name")
		return
		
	tcgNetworkManager.host_server(player_name, deck_name)
	
func join():
	var player_name: String = $Network/PlayerInfo/Values/PlayerNameInput.text
	var deck_name: String = $Network/PlayerInfo/Values/DeckNameInput.text
	if player_name.is_empty():
		tcgLogger.error_message("You need to give your Player a name")
		return
	if deck_name.is_empty():
		tcgLogger.error_message("You need to give your Deck a name")
		return
		
	tcgNetworkManager.join_server(player_name, deck_name)

func start_game():
	# TODO: networkmanager load / unload scene prefab()
	# TODO: create arena scene
	# TODO: create cards and card physcs and shit
	pass
	
func on_connected_to_server():
	var local_id: int = tcgNetworkManager.get_local_id()
	$Network/PlayerInfo/Values/IdDisplay.text = str(local_id)
	$Network/NetworkingButtons/InitButtons.hide()
	if multiplayer.is_server():
		$Network/NetworkingButtons/startBtn.show()
		
func on_new_player_synced():
	if tcgNetworkManager.ConnectedPlayers.size() >= 2:
		$Network/NetworkingButtons/startBtn.disabled = false
		
