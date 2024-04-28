extends Node

signal ServerEstablished()
signal PlayerConnected(peer_id: int)
signal NewPlayerSynced()

# static variables
const ADDRESS: String = "127.0.0.1"
const PORT: int = 9999
const SERVER_ID: int = 1

# class variables
var HostId: int
var ConnectedPlayers: Dictionary # PeerId : tcgPlayer
var Peer: ENetMultiplayerPeer

func get_local_id() -> int:
	if Peer == null:
		return 0
	return Peer.get_unique_id()

@rpc("authority", "reliable")
func set_host_id(host_id: int):
	HostId = host_id
	
# Called when the node enters the scene tree for the first time.
func _ready():
	# set up listeners for server event delegates
	multiplayer.connected_to_server.connect(on_server_connect_success)
	multiplayer.connection_failed.connect(on_server_connect_failure)
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	
@rpc("any_peer", "call_remote", "reliable")
func add_player(player_name: String, deck_name: String, local_id: int = -1):
	if local_id == -1:
		local_id = get_local_id()
		
	if ConnectedPlayers.has(local_id):
		tcgLogger.debug_message("Wasted call to add_player()")
		return
		
	var new_player = tcgPlayer.new(player_name, deck_name, local_id)
	ConnectedPlayers[local_id] = new_player
	tcgLogger.network_event(tcgLogger.SERVER, "Player \"%s\" joined - id:%s" % [player_name, str(local_id)])

@rpc("any_peer", "reliable")
func sync_player_to_server(player_name: String, deck_name: String, local_id: int):
	for p in ConnectedPlayers.values():
		add_player.rpc_id(local_id, p.Name, p.DeckName, p.PeerId)
		add_player.rpc_id(p.PeerId, player_name, deck_name, local_id)
	add_player(player_name, deck_name, local_id)
	set_host_id.rpc_id(local_id, HostId)
	NewPlayerSynced.emit()

func host_server(player_name: String, deck_name: String):
	Peer = ENetMultiplayerPeer.new()
	var error = Peer.create_server(PORT, 2)
	if error != OK:
		tcgLogger.error_message(str(error))
		return
	add_player(player_name, deck_name, get_local_id())
	# TODO: compression if needed - Peer.get_host().compress(COMPRESSION_CODE)
	multiplayer.set_multiplayer_peer(Peer)
	
	tcgLogger.debug_message("Sever established, waiting for opponent")
	HostId = get_local_id()
	ServerEstablished.emit()
	
func join_server(player_name: String, deck_name: String):
	Peer = ENetMultiplayerPeer.new()
	var error = Peer.create_client(ADDRESS, PORT)
	if error != OK:
		tcgLogger.error_message(str(error))
		return
	add_player(player_name, deck_name, get_local_id())
	# TODO: compression if needed - Peer.get_host().compress(COMPRESSION_CODE)
	multiplayer.set_multiplayer_peer(Peer)
	
func on_server_connect_success():
	tcgLogger.debug_message("Found Server")
	
func on_server_connect_failure():
	tcgLogger.debug_message("Lost Server")

# authority calls this when a peer connects
func on_peer_connected(peer_id: int):
	tcgLogger.debug_message("Peer connected: %s" % str(peer_id))
	if peer_id == SERVER_ID:
		tcgLogger.debug_message("server connected to a client")
		var local_p = ConnectedPlayers[get_local_id()]
		sync_player_to_server.rpc_id(SERVER_ID, local_p.Name, local_p.DeckName, get_local_id())
		
func on_peer_disconnected(peer_id: int):
	tcgLogger.debug_message("Lost Peer: %s" % str(peer_id))
