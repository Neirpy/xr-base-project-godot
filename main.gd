extends Node3D

var xr_interface: XRInterface
var webxr_interface

func _ready():
	webxr_interface = XRServer.find_interface("WebXR")
	if webxr_interface:
		# On vérifie si le navigateur supporte l'immersion VR/AR
		webxr_interface.session_supported.connect(_on_webxr_session_supported)
	
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

func _on_webxr_session_supported(session_mode, supported):
	if supported:
		print("WebXR supporté !")
		# Ici, tu dois créer un bouton "Entrer en AR" sur ton UI 2D
		# Car le WebXR exige un clic utilisateur pour démarrer.

func _on_session_begun():
	var frame_rate = xr_interface.get_display_refresh_rate()

	# Sync physics with refresh rate
	Engine.physics_ticks_per_second = frame_rate
