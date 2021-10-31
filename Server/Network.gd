extends Node

onready var Server = get_node('/root/Server')

var eNet : NetworkedMultiplayerENet

const DEFAULT_PORT = 8686
const MAX_CLIENTS = 8
var ip_address : String

func _ready():
	# get n
	self.ip_address = get_IP()
	
	# Initialize eNet
	eNet = NetworkedMultiplayerENet.new()
	eNet.create_server(DEFAULT_PORT, MAX_CLIENTS)
	
	# Connect peer functions
	eNet.connect("peer_connected", self, "_Peer_Connected")
	eNet.connect("peer_disconnected", self, "_Peer_Disconnected")
	
	# set network peer to created eNet
	get_tree().set_network_peer(eNet)

func _Peer_Connected(peer_id):
	print("Peer connected: {peer_id}".format({"peer_id":peer_id}))
	Server.add_client(peer_id)

func _Peer_Disconnected(peer_id):
	print("Peer disconnected: {peer_id}".format({"peer_id":peer_id}))
	Server.remove_client(peer_id)

func get_IP():
	# This get IP function is only tested on Linux. May be different for Windows servers
	return IP.get_local_addresses()[0]

remote func rec_message(message):
	message['sender_id'] = get_tree().get_rpc_sender_id() # Duplicate?
	Server.add_message(message)
	#debug # rpc_id(message['sender_id'],"rec_message",{"message_type":"Test"})
