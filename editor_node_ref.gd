class_name EditorNodeRef #! singleton-module
extends Singleton.Base

#static func _static_init() -> void:
	#get_instance()


const _GET_REF_SCRIPTS = {
	4: {
		4: _NodeRefScripts.NodeRef_44,
		5: _NodeRefScripts.NodeRef_45
	}
}

const _NODE_NAME = "EditorNodeRef"
const SCRIPT = preload("res://addons/addon_lib/editor_node_ref/editor_node_ref.gd")

static func get_singleton_name():
	return "EditorNodeRef"

static func get_instance() -> EditorNodeRef:
	return _get_instance(SCRIPT)

static func call_on_ready(callable:Callable):
	_call_on_ready(SCRIPT, callable)

func _get_ready_bool() -> bool:
	return populated

static func register(key, object) -> void:
	var instance = get_instance()
	instance._register(key, object)

func _register(key, object):
	if _registry.has(key):
		printerr("EditorNodeRefs has key already: %s" % key)
		return
	_registry[key] = object

static func unregister(key) -> void:
	var instance = get_instance()
	instance._unregister(key)

func _unregister(key, quiet:=false):
	if _registry.has(key):
		_registry.erase(key)
	else:
		if not quiet:
			printerr("EditorNodeRefs doens't have key: %s" % key)

static func register_dynamic(key, update_method:Callable, _signal:Signal, callback=null, callback_pass_args:=false):
	var instance = get_instance()
	instance._register_dynamic(key, update_method, _signal, callback, callback_pass_args)

func _register_dynamic(key, method:Callable, _signal:Signal, callback=null, callback_pass_args:=false):
	if _dynamic_data.has(key):
		printerr("Already registered key: %s" % key)
		return
	
	var update_var = func():
		_registry[key] = method.call()
	
	var signal_handler = SignalHandler.create_signal_adapter(update_var, callback, callback_pass_args)
	_signal.connect(signal_handler)
	
	_dynamic_data[key] = {"signal":_signal, "handler": signal_handler}

static func unregister_dynamic(key):
	var instance = get_instance()
	instance._unregister_dynamic(key)

func _unregister_dynamic(key):
	if _dynamic_data.has(key):
		var data = _dynamic_data.get(key)
		var _signal = data.get("signal")
		var handler = data.get("handler")
		_signal.disconnect(handler)
		_dynamic_data.erase(key)
		_unregister(key)
	else:
		printerr("EditorNodeRef does not have dynamic key: %s" % key)


static func get_registered(key) -> Variant:
	var instance = get_instance()
	return instance._get_registered(key)

func _get_registered(key):
	if _registry.has(key):
		return _registry.get(key)
	else:
		print("Could not find reference for key: %s" % key)
		return null


enum Nodes {
	FILESYSTEM_POPUP,
	FILESYSTEM_CREATE_POPUP,
	FILESYSTEM_TREE,
	
	SCRIPT_EDITOR_POPUP,
	SCRIPT_EDITOR_CODE_POPUP,
	SCRIPT_EDITOR_SYNTAX_POPUP,
	SCRIPT_EDITOR_MENU_BAR,
	
	SCENE_TABS,
	SCENE_TABS_POPUP,
	SCENE_TREE_POPUP,
	SCENE_TREE_DOCK,
	
	TITLE_BAR,
	TITLE_BUTTONS,
	
	BOTTOM_PANEL,
	BOTTOM_PANEL_BUTTONS,
	
	EDITOR_LOG,
	EDITOR_LOG_FILTER,
	
	DOCKS,
	
}

var _registry:Dictionary = {}
var _dynamic_data:Dictionary = {}

signal script_editor_updated

var _get_node #:_NodeRefScripts.NodeRefBase

var populated := false

func _ready() -> void:
	var version = Engine.get_version_info()
	var major = version.major
	var minor = version.minor
	
	var script
	var major_dict = _GET_REF_SCRIPTS.get(major)
	var minor_script = major_dict.get(minor)
	if minor_script == null:
		print("Error getting version %s.%s EditorNodeRefs script, reverting to 4.4" % [major, minor])
		script = major_dict.get(4)
	else:
		script = major_dict.get(minor)
	
	_get_node = script.new()
	
	_popupulate_references.call_deferred()


func _popupulate_references() -> void:
	var root = Engine.get_main_loop().root
	while not root.is_node_ready():
		await get_tree().process_frame
	#await get_tree().process_frame
	
	var types = ["TabContainer", "SceneTreeDock", "EditorSceneTabs", "EditorBottomPanel"]
	_get_node.get_all_nodes_of_types(types)
	
	## Register
	_register(Nodes.FILESYSTEM_POPUP, _get_node.get_file_system_popup())
	_register(Nodes.FILESYSTEM_TREE, _get_node.get_file_system_tree())
	
	_register(Nodes.SCENE_TABS, _get_node.get_scene_tabs())
	_register(Nodes.SCENE_TABS_POPUP, _get_node.get_scene_tabs_popup())
	_register(Nodes.SCENE_TREE_POPUP, _get_node.get_scene_tree_popup())
	_register(Nodes.SCENE_TREE_DOCK, _get_node.get_scene_tree_dock())
	
	_register(Nodes.TITLE_BAR, _get_node.get_title_bar())
	_register(Nodes.TITLE_BUTTONS, _get_node.get_title_buttons())
	
	_register(Nodes.BOTTOM_PANEL, _get_node.get_bottom_panel())
	_register(Nodes.BOTTOM_PANEL_BUTTONS, _get_node.get_bottom_panel_buttons())
	
	_register(Nodes.EDITOR_LOG, _get_node.get_editor_log())
	_register(Nodes.EDITOR_LOG_FILTER, _get_node.get_editor_log_filter_line_edit())
	
	_register(Nodes.DOCKS, _get_node.get_docks())
	
	
	##
	_popuplate_dynamic_references()
	
	populated = true

func _popuplate_dynamic_references():
	var fs_popup = EditorNodeRef.get_registered(EditorNodeRef.Nodes.FILESYSTEM_POPUP)
	_register_dynamic(Nodes.FILESYSTEM_CREATE_POPUP, _get_node.get_file_system_create_popup, fs_popup.about_to_popup)
	
	var editor_script_changed = EditorInterface.get_script_editor().editor_script_changed
	
	_register_dynamic(Nodes.SCRIPT_EDITOR_POPUP, _get_node.get_script_editor_popup, editor_script_changed, _on_script_editor_references_updated)
	_register_dynamic(Nodes.SCRIPT_EDITOR_CODE_POPUP, _get_node.get_script_editor_code_popup, editor_script_changed)
	_register_dynamic(Nodes.SCRIPT_EDITOR_SYNTAX_POPUP, _get_node.get_script_editor_syntax_popup, editor_script_changed)
	_register_dynamic(Nodes.SCRIPT_EDITOR_MENU_BAR, _get_node.get_script_editor_menu_bar, editor_script_changed)




func _on_script_editor_references_updated():
	script_editor_updated.emit()

static func check_nodes():
	var ins = get_instance()
	for key in ins._registry.keys():
		print(get_registered(key))


class _NodeRefScripts:
	const NodeRefBase = preload("res://addons/addon_lib/editor_node_ref/editor_node_ref_versions/get_ed_node_ref_base.gd")
	const NodeRef_44 = preload("res://addons/addon_lib/editor_node_ref/editor_node_ref_versions/get_ed_node_ref_4_4.gd")
	const NodeRef_45 = preload("res://addons/addon_lib/editor_node_ref/editor_node_ref_versions/get_ed_node_ref_4_5.gd")
