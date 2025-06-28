extends Node

signal recommendations_received(recommendations_text)

var _js_api = null
var _connection_timer: Timer
var _connection_attempts = 0
const MAX_CONNECTION_ATTEMPTS = 10 # Try to connect for 5 seconds

# This is the function that our Next.js app will call.
func display_recommendations(recommendations: String):
	print("GameAPI received recommendations from Next.js!")
	print(recommendations)
	recommendations_received.emit(recommendations)

func _ready():
	# Create a timer to handle the connection attempts.
	_connection_timer = Timer.new()
	add_child(_connection_timer)
	_connection_timer.wait_time = 0.5 # Check every 500ms
	_connection_timer.timeout.connect(_attempt_to_connect_bridge)
	_connection_timer.start()

func _attempt_to_connect_bridge():
	_connection_attempts += 1
	print("GodotAPI: Attempting to connect to JavaScript bridge (Attempt %d)..." % _connection_attempts)

	# Try to get the interface created by Next.js
	_js_api = JavaScriptBridge.get_interface("godotApi")

	if _js_api:
		# Success! The JavaScript object is ready.
		print("GodotAPI: Bridge connected successfully!")
		_js_api.display_recommendations = Callable(self, "display_recommendations")
		_connection_timer.stop() # Stop trying
	elif _connection_attempts >= MAX_CONNECTION_ATTEMPTS:
		# Failure. We tried enough times.
		print("ERROR (GameAPI.gd): Could not connect to JavaScript bridge after %d attempts." % MAX_CONNECTION_ATTEMPTS)
		_connection_timer.stop()
