# web3_manager.gd (AutoLoad Singleton)
extends Node

# Signals to emit results back to Godot game
signal wallet_connected(address)
signal wallet_disconnected()
signal transaction_signed(tx_hash)
signal message_signed(signature)
signal error_occurred(error_message)

var connected_address = ""

func _ready():
	# IMPORTANT: Check if running in HTML5 export
	if OS.has_feature("html5"):
		print("Running in HTML5. Web3 available.")

		# Create Callable objects for each GDScript function
		var on_accounts_changed_callable = JavaScriptBridge.create_callback(Callable(self, "_js_on_accounts_changed"))
		var on_chain_changed_callable = JavaScriptBridge.create_callback(Callable(self, "_js_on_chain_changed"))
		var on_connect_success_callable = JavaScriptBridge.create_callback(Callable(self, "_js_on_connect_success"))
		var on_connect_error_callable = JavaScriptBridge.create_callback(Callable(self, "_js_on_connect_error"))
		var on_sign_message_success_callable = JavaScriptBridge.create_callback(Callable(self, "_js_on_sign_message_success"))
		var on_sign_message_error_callable = JavaScriptBridge.create_callback(Callable(self, "_js_on_sign_message_error"))

		# Now, construct the JavaScript string to expose these callables
		# We'll use JavaScriptBridge.eval() to run this string.
		# The trick is that the JavaScriptObject returned by create_callback
		# is automatically converted to a callable JavaScript function when embedded.
		var js_setup_code = """
			// Ensure a global object exists to hold our Godot callbacks
			window.godotCallbacks = window.godotCallbacks || {};

			// Assign the Godot Callables (which become JS functions) to global properties
			// The references (like '""" + str(on_accounts_changed_callable) + """')
			// are directly embedded into the string by GDScript.
			window.godotCallbacks.onAccountsChanged = """ + str(on_accounts_changed_callable) + """;
			window.godotCallbacks.onChainChanged = """ + str(on_chain_changed_callable) + """;
			window.godotCallbacks.onConnectSuccess = """ + str(on_connect_success_callable) + """;
			window.godotCallbacks.onConnectError = """ + str(on_connect_error_callable) + """;
			window.godotCallbacks.onSignMessageSuccess = """ + str(on_sign_message_success_callable) + """;
			window.godotCallbacks.onSignMessageError = """ + str(on_sign_message_error_callable) + """;
		"""
		# Execute the setup code. The second argument is 'use_global_execution_context'.
		# We want to put these on 'window', so true is appropriate here.
		JavaScriptBridge.eval(js_setup_code, true) # Set to true to execute in global context

	else:
		print("Not running in HTML5. Web3 functionality disabled.")

# --- GDScript functions to be called by your game ---

func connect_wallet():
	if not OS.has_feature("html5"):
		emit_signal("error_occurred", "Web3 not available outside HTML5 export.")
		return

	# Call the JavaScript function to connect MetaMask
	# No second argument to eval if not passing any variables from GDScript
	JavaScriptBridge.eval("connectMetaMask();")

func get_connected_account():
	return connected_address

func sign_message(message: String):
	if not OS.has_feature("html5"):
		emit_signal("error_occurred", "Web3 not available outside HTML5 export.")
		return
	if connected_address.empty():
		emit_signal("error_occurred", "No wallet connected to sign message.")
		return

	# To pass a string into JavaScript eval, you must manually escape it
	# and embed it into the JavaScript string literal.
	# Alternatively, you could use JavaScriptBridge.create_object("String", message)
	# and pass that object if `eval` could take objects as arguments, but it doesn't work this way.
	# Manual escaping for 'eval' is often done by wrapping in JSON.stringify() in JS.
	# Simpler: Call a JS function that takes a direct argument.
	# The safest way is to make sure your JS function expects string args and they are correctly quoted.
	# For now, let's just make sure it's wrapped in single quotes for eval.
	# If the message contains quotes or backslashes, you'd need more robust escaping.
	# For robust escaping, consider using a JSON-like string if complex data.
	# For simple string:
	var escaped_message = message.replace("'", "\\'").replace("\\", "\\\\").replace("\n", "\\n").replace("\r", "\\r");
	JavaScriptBridge.eval("signMessage('" + escaped_message + "');")

# --- Callbacks from JavaScript (Prefix with _js_ for clarity) ---

func _js_on_accounts_changed(args: Array): # Arguments from JS are always an array
	if args and args.size() > 0 and args[0] is Array and args[0].size() > 0:
		var new_address = args[0][0] # The JS 'accounts' array is the first element
		if new_address != connected_address:
			connected_address = new_address
			emit_signal("wallet_connected", connected_address)
			print("Wallet account changed to: ", connected_address)
	else:
		connected_address = ""
		emit_signal("wallet_disconnected")
		print("Wallet disconnected or accounts cleared.")

func _js_on_chain_changed(args: Array):
	if args and args.size() > 0:
		var chain_id = args[0] # Chain ID from JS
		print("Chain changed to: ", chain_id)

func _js_on_connect_success(args: Array):
	if args and args.size() > 0 and args[0] is Array and args[0].size() > 0:
		connected_address = args[0][0]
		emit_signal("wallet_connected", connected_address)
		print("MetaMask connected successfully. Address: ", connected_address)
	else:
		emit_signal("error_occurred", "MetaMask connected but no address received.")

func _js_on_connect_error(args: Array):
	var error_message = "Unknown connection error."
	if args and args.size() > 0:
		error_message = str(args[0])
	emit_signal("error_occurred", "MetaMask connection error: " + error_message)
	print("MetaMask connection error: ", error_message)

func _js_on_sign_message_success(args: Array):
	if args and args.size() > 0:
		var signature = args[0]
		emit_signal("message_signed", signature)
		print("Message signed successfully. Signature: ", signature)
	else:
		emit_signal("error_occurred", "Message signed but no signature received.")

func _js_on_sign_message_error(args: Array):
	var error_message = "Unknown signature error."
	if args and args.size() > 0:
		error_message = str(args[0])
	emit_signal("error_occurred", "MetaMask message signature error: " + error_message)
	print("MetaMask message signature error: ", error_message)
