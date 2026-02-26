extends Node3D

var xr_interface: XRInterface

func _ready() -> void:
	var interfaces = ["visionOS", "OpenXR", "WebXR"]
	
	for name in interfaces:
		xr_interface = XRServer.find_interface(name)
		if xr_interface and xr_interface.initialize():
			print("XR: Interface ", name, " initialisée.")
			break

	if xr_interface:
		get_viewport().use_xr = true
		
		
		match xr_interface.get_name():
			"visionOS":
				_setup_visionos()
			"OpenXR":
				_setup_openxr()
			"WebXR":
				_setup_webxr()
	else:
		print("XR: Aucune interface compatible trouvée.")

# --- Spécificités visionOS ---
func _setup_visionos() -> void:
	
	print("Config spécifique visionOS active.")
	
func _setup_openxr() -> void:
	xr_interface.session_begun.connect(_on_openxr_session_begun)

func _on_openxr_session_begun() -> void:
	var rate = xr_interface.get_display_refresh_rate()
	if rate > 0:
		Engine.physics_ticks_per_second = roundi(rate)

func _setup_webxr() -> void:
	xr_interface.session_started.connect(func(): print("WebXR démarré"))
	xr_interface.session_failed.connect(func(reason): print("WebXR échec: ", reason))
