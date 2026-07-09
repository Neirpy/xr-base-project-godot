extends Node3D

var xr_interface: XRInterface
var webxr_interface
var vr_supported = false

func _ready():
	# We assume this node has a button as a child.
	# This button is for the user to consent to entering immersive VR mode.

	webxr_interface = XRServer.find_interface("WebXR")
	if webxr_interface:
		# WebXR uses a lot of asynchronous callbacks, so we connect to various
		# signals in order to receive them.
		webxr_interface.session_supported.connect(self._webxr_session_supported)
		webxr_interface.session_started.connect(self._webxr_session_started)
		webxr_interface.session_ended.connect(self._webxr_session_ended)
		webxr_interface.session_failed.connect(self._webxr_session_failed)

		# This returns immediately - our _webxr_session_supported() method
		# (which we connected to the "session_supported" signal above) will
		# be called sometime later to let us know if it's supported or not.
		webxr_interface.is_session_supported("immersive-vr")
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		var vp : Viewport = get_viewport()

		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		vp.use_xr = true

		# Enable VRS (foveated rendering).
		# Vulkan only, for Compatibility see project settings.
		vp.vrs_mode = Viewport.VRS_XR

		# Connect to OpenXR events
		xr_interface.connect("session_begun", _on_session_begun)
		
		print("OpenXR initialised successfully")
	else:
		print("OpenXR not initialized, please check if your headset is connected")

func _on_session_begun():
	var frame_rate = xr_interface.get_display_refresh_rate()

	# Sync physics with refresh rate
	Engine.physics_ticks_per_second = frame_rate

func _webxr_session_supported(session_mode, supported):
	if session_mode == 'immersive-vr':
		vr_supported = supported

func _on_button_pressed():
	if not vr_supported:
		OS.alert("Your browser doesn't support VR")
		return

	# We want an immersive VR session, as opposed to AR ('immersive-ar') or a
	# simple 3DoF viewer ('viewer').
	webxr_interface.session_mode = 'immersive-vr'
	# 'bounded-floor' is room scale, 'local-floor' is a standing or sitting
	# experience (it puts you 1.6m above the ground if you have 3DoF headset),
	# whereas as 'local' puts you down at the XROrigin.
	# This list means it'll first try to request 'bounded-floor', then
	# fallback on 'local-floor' and ultimately 'local', if nothing else is
	# supported.
	webxr_interface.requested_reference_space_types = 'bounded-floor, local-floor, local'
	# In order to use 'local-floor' or 'bounded-floor' we must also
	# mark the features as required or optional. By including 'hand-tracking'
	# as an optional feature, it will be enabled if supported.
	webxr_interface.required_features = 'local-floor'
	webxr_interface.optional_features = 'bounded-floor, hand-tracking'

	# This will return false if we're unable to even request the session,
	# however, it can still fail asynchronously later in the process, so we
	# only know if it's really succeeded or failed when our
	# _webxr_session_started() or _webxr_session_failed() methods are called.
	if not webxr_interface.initialize():
		OS.alert("Failed to initialize")
		return

func _webxr_session_started():
	$Button.visible = false
	# This tells Godot to start rendering to the headset.
	get_viewport().use_xr = true
	# This will be the reference space type you ultimately got, out of the
	# types that you requested above. This is useful if you want the game to
	# work a little differently in 'bounded-floor' versus 'local-floor'.
	print("Reference space type: ", webxr_interface.reference_space_type)
	# This will be the list of features that were successfully enabled
	# (except on browsers that don't support this property).
	print("Enabled features: ", webxr_interface.enabled_features)

func _webxr_session_ended():
	$Button.visible = true
	# If the user exits immersive mode, then we tell Godot to render to the web
	# page again.
	get_viewport().use_xr = false

func _webxr_session_failed(message):
	OS.alert("Failed to initialize: " + message)
