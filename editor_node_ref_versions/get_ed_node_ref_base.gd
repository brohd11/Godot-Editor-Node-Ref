
# This is the 4.4 functionality, change what must be in other versions

var node_types_dict = {}
##
func get_all_nodes_of_types(types:Array) -> Dictionary:
	var root = Engine.get_main_loop().root
	var dict = {}
	for type in types:
		dict[type] = []
	var nodes = _get_all_nodes_of_types_recursive(root, types, dict)
	node_types_dict = nodes
	return nodes
#private
func _get_all_nodes_of_types_recursive(node:Node, type_array:Array, node_dict:Dictionary) -> Dictionary:
	for n in node.get_children(true):
		var type = n.get_class()
		if type in type_array:
			node_dict[type].append(n)
		_get_all_nodes_of_types_recursive(n, type_array, node_dict)
	return node_dict






##
func get_script_editor_code_popup(): # Dynamic
	var current = EditorInterface.get_script_editor().get_current_editor()
	if current == null:
		return null
	return current.get_child(1)
##
func get_script_editor_popup(): # Dynamic
	return EditorInterface.get_script_editor().get_child(1)
##
func get_script_editor_menu_bar(): # Dynamic
	var menu_bars_hbox = EditorInterface.get_script_editor().get_child(0).get_child(0)
	var menu_hboxes = menu_bars_hbox.get_children()
	var menu_hbox:HBoxContainer
	for child in menu_hboxes:
		if child.visible and child is HBoxContainer:
			menu_hbox = child
			break
	if not is_instance_valid(menu_hbox):
		#print("Could not get current script editor menu bar.")
		pass
	return menu_hbox
##
func get_script_editor_syntax_popup(): # Dynamic
	var menu_hbox:HBoxContainer = get_script_editor_menu_bar()
	if not is_instance_valid(menu_hbox):
		return
	var menu_popup:PopupMenu
	var menu_buttons = menu_hbox.get_children()
	for button:MenuButton in menu_buttons:
		if button.text == "Edit":
			menu_popup = button.get_popup()
			break
	if not is_instance_valid(menu_popup):
		#print("Could not find edit menu popup.")
		return
	var syntax_popup = menu_popup.get_child(menu_popup.get_child_count() - 1)
	return syntax_popup





##
func get_file_system_popup():
	return EditorInterface.get_file_system_dock().get_child(2)
##
func get_file_system_create_popup():
	var fs_popup = EditorNodeRef.get_registered(EditorNodeRef.Nodes.FILESYSTEM_POPUP)
	var popup = fs_popup.get_child(0)
	return popup
#private func
func _populate_filesystem_popup():
	var fs_popup = EditorNodeRef.get_registered(EditorNodeRef.Nodes.FILESYSTEM_POPUP)
	var tree = get_file_system_tree() as Tree
	tree.item_mouse_selected.emit(Vector2.ZERO, 2)
	fs_popup.hide()
##
func get_file_system_tree():
	var nodes = EditorInterface.get_file_system_dock().get_child(3).find_children("*", "Tree", true, false)
	return nodes[0] # this has a check in the original if popup menu has moved




##
func get_scene_tabs_popup():
	var scene_tabs = get_scene_tabs()
	var popup = scene_tabs.get_child(0).get_child(0).get_child(1)
	return popup
##
func get_scene_tree_popup():
	return node_types_dict.get("SceneTreeDock")[0].get_child(15)
##
func get_scene_tabs():
	var main_screen = EditorInterface.get_editor_main_screen()
	var main_screen_parent = main_screen.get_parent().get_parent()
	for c in main_screen_parent.get_children():
		if c.get_class() == "EditorSceneTabs":
			return c
##
func get_scene_tree_dock():
	return node_types_dict.get("SceneTreeDock")[0]
##





func get_docks():
	var tab_containers = node_types_dict.get("TabContainer", [])
	var docks = []
	for tab in tab_containers:
		if tab.name.begins_with("DockSlot"):
			docks.append(tab)
	return docks
##





##
func get_title_bar():
	return EditorInterface.get_base_control().get_child(0).get_child(0)
##
func get_title_buttons():
	var system = OS.get_name()
	if system == "macOS":
		return get_title_bar().get_child(3)
	else:
		return get_title_bar().get_child(2)
##



##
func get_bottom_panel() -> Control:
	return node_types_dict.get("EditorBottomPanel")[0]
##
func get_bottom_panel_buttons():
	var bp_v = _get_bottom_panel_vbox()
	var bp_children = bp_v.get_children()
	bp_children.reverse()
	var hbox = null
	for control in bp_children:
		var nested_children = control.get_children()
		for nc in nested_children:
			if nc.get_class() == "EditorToaster":
				hbox = control
				break
		if is_instance_valid(hbox):
			break
	var buttons_hbox = hbox.get_child(1).get_child(0, true)
	return buttons_hbox
# private
func _get_bottom_panel_vbox():
	return get_bottom_panel().get_child(0)
# private func
func _bottom_panel_get_panel(_class_name):
	var bottom_panel_vbox = _get_bottom_panel_vbox()
	for p in bottom_panel_vbox.get_children():
		if p.get_class() == _class_name:
			return p
	push_error("Could not find %s" % _class_name)
##
func get_editor_log_filter_line_edit():
	var editor_log = _bottom_panel_get_panel("EditorLog")
	var vbox = editor_log.get_child(1)
	var line_edit = vbox.get_child(1)
	return line_edit



func get_2d_editor_popup():
	return null
