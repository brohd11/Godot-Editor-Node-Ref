class_name EditorNodeRef
extends Node

const _GET_REF_SCRIPTS = {
	4:{
		4:_NodeRefScripts.NodeRef_44
	}
}

const _NODE_NAME = "EditorNodeRefs"

static func get_instance():
	var root = Engine.get_main_loop().root
	var _instance = root.get_node_or_null(_NODE_NAME)
	
	if not is_instance_valid(_instance):
		_instance = new()
		_instance.name = _NODE_NAME
		root.add_child(_instance)
	
	return _instance


enum Nodes {
	FILESYSTEM_POPUP,
	FILESYSTEM_CREATE_POPUP,
	SCRIPT_EDITOR_POPUP,
	SCRIPT_EDITOR_CODE_POPUP,
	SCENE_TABS_POPUP,
	SCENE_TREE_POPUP,
}

var current_version_script:_NodeRefScripts.NodeRefBase

var _registry:Dictionary = {}

func _ready() -> void:
	var version = Engine.get_version_info()
	var major = version.major
	var minor = version.minor
	
	var major_dict = _GET_REF_SCRIPTS.get(major)
	var minor_script = major_dict.get(minor)
	if minor_script == null:
		print("Error getting version %s.%s EditorNodeRefs script, reverting to 4.4" % [major, minor])
		current_version_script = major_dict.get(4)
	else:
		current_version_script = major_dict.get(minor)
	
	_popupulate_references()
	EditorInterface.get_script_editor().editor_script_changed.connect(_get_script_editor_references)


func register(key, object):
	if _registry.has(key):
		printerr("EditorNodeRefs has key already: %s" % key)
		return
	_registry[key] = object

func unregister(key, quiet:=false):
	if _registry.has(key):
		_registry.erase(key)
	else:
		if not quiet:
			printerr("EditorNodeRefs doens't have key: %s" % key)

func get_registered(key):
	if _registry.has(key):
		return _registry.get(key)
	else:
		print("Could not find reference for key: %s" % key)
		return null



func _popupulate_references():
	_get_script_editor_references(null)
	
	register(Nodes.FILESYSTEM_POPUP, current_version_script.get_file_system_popup())
	register(Nodes.FILESYSTEM_CREATE_POPUP, current_version_script.get_file_system_create_popup())
	register(Nodes.SCENE_TABS_POPUP, current_version_script.get_scene_tabs_popup())
	register(Nodes.SCENE_TREE_POPUP, current_version_script.get_scene_tree_popup())
	


func _get_script_editor_references(new_script):
	unregister(Nodes.SCRIPT_EDITOR_POPUP, true)
	unregister(Nodes.SCRIPT_EDITOR_CODE_POPUP, true)
	
	register(Nodes.SCRIPT_EDITOR_POPUP, null)
	register(Nodes.SCRIPT_EDITOR_CODE_POPUP, null)






class _NodeRefScripts:
	const NodeRefBase = preload("res://addons/addon_lib/editor_node_ref/editor_node_ref_versions/get_ed_node_ref_base.gd")
	const NodeRef_44 = preload("res://addons/addon_lib/editor_node_ref/editor_node_ref_versions/get_ed_node_ref_4_4.gd")
