extends Node

signal LocalMessage(type_id: int, contents: String)
signal NetworkMessage(owner_id: int, contents: String)

const ERROR: int = -3
const DEBUG: int = -2
const SERVER: int = -1

var Messages: Array[tcgMessage]

func debug_message(contents: String):
	print("Debug(%s): %s" % [str(tcgNetworkManager.get_local_id()), contents])
	Messages.append(tcgMessage.new(DEBUG, contents))
	LocalMessage.emit(DEBUG, contents)

func error_message(contents: String):
	print("Error(%s): %s" % [str(tcgNetworkManager.get_local_id()), contents])
	Messages.append(tcgMessage.new(ERROR, contents))
	LocalMessage.emit(ERROR, contents)
	
@rpc("any_peer", "call_local", "reliable")
func network_message(peer_id: int, contents: String):
	print("Network(%s): %s" % [str(tcgNetworkManager.get_local_id()), contents])
	var id = tcgNetworkManager.get_local_id() 
	Messages.append(tcgMessage.new(id, contents))
	NetworkMessage.emit(id, contents)

@rpc("any_peer", "call_local", "reliable")
func network_event(peer_id: int, contents: String):
	if peer_id == tcgNetworkManager.get_local_id():
		return
	print("Network(%s): %s" % [str(tcgNetworkManager.get_local_id()), contents])
	var id = tcgNetworkManager.get_local_id() 
	Messages.append(tcgMessage.new(id, contents))
	NetworkMessage.emit(id, contents)
	
