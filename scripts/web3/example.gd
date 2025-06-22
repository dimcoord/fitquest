# main.gd
extends Control

@onready var connect_button = $ConnectButton
@onready var address_label = $AddressLabel
@onready var sign_message_button = $SignMessageButton
@onready var status_label = $StatusLabel

func _ready():
    Web3Manager.wallet_connected.connect(_on_wallet_connected)
    Web3Manager.wallet_disconnected.connect(_on_wallet_disconnected)
    Web3Manager.message_signed.connect(_on_message_signed)
    Web3Manager.error_occurred.connect(_on_error_occurred)

    connect_button.pressed.connect(Web3Manager.connect_wallet)
    sign_message_button.pressed.connect(_on_sign_message_pressed)

    _update_ui() # Initial UI update

func _on_wallet_connected(address: String):
    _update_ui()
    status_label.text = "Connected: " + address.left(6) + "..." + address.right(4)

func _on_wallet_disconnected():
    _update_ui()
    status_label.text = "Disconnected."

func _on_message_signed(signature: String):
    status_label.text = "Message Signed! Signature: " + signature.left(10) + "..."

func _on_error_occurred(message: String):
    status_label.text = "Error: " + message
    printerr("Godot Web3 Error: ", message)

func _on_sign_message_pressed():
    if Web3Manager.get_connected_account().empty():
        status_label.text = "Please connect wallet first!"
        return
    var message_to_sign = "Hello from my Godot game! Time: " + str(Time.get_unix_time_from_system())
    Web3Manager.sign_message(message_to_sign)

func _update_ui():
    var address = Web3Manager.get_connected_account()
    if address.empty():
        address_label.text = "Wallet not connected"
        connect_button.text = "Connect MetaMask"
        sign_message_button.disabled = true
    else:
        address_label.text = "Connected: " + address.left(6) + "..." + address.right(4)
        connect_button.text = "Wallet Connected"
        sign_message_button.disabled = false