extends Object

class_name tcgPlayer

# private class variables
var Name: String
var DeckName: String
var PeerId: int
# var Deck: tcgDeck

func _init(name: String, deck_name: String, peer_id: int):
	Name = name
	DeckName = deck_name
	PeerId = peer_id
	
