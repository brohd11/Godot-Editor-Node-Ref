
# This is the 4.4 functionality, change what must be in other versions

static func get_script_editor_code_popup():
	return null

static func get_script_editor_popup():
	return null

static func get_file_system_popup():
	return EditorInterface.get_file_system_dock().get_child(2)

static func get_file_system_create_popup():
	return EditorInterface.get_file_system_dock().get_child(2).get_child(3)

static func get_scene_tabs_popup():
	return null

static func get_scene_tree_popup():
	return null

static func get_2d_editor_popup():
	return null
