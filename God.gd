extends PanelContainer

signal god_clicked(god)

var god_name: String
var strength: int
var speed: int
var intelligence: int
var is_busy: bool = false
var is_selected: bool = false

@onready var icon_label = $MarginContainer/VBoxContainer/IconLabel
@onready var name_label = $MarginContainer/VBoxContainer/NameLabel
@onready var stats_label = $MarginContainer/VBoxContainer/StatsLabel

func setup(p_name: String, p_strength: int, p_speed: int, p_intelligence: int):
	god_name = p_name
	strength = p_strength
	speed = p_speed
	intelligence = p_intelligence

func _ready():
	if icon_label:
		update_display()

	# Make it clickable
	gui_input.connect(_on_gui_input)

func update_display():
	# Simple icon (just use first letter or emoji)
	icon_label.text = "👤"  # Generic person icon
	name_label.text = god_name

	# Color-coded stats
	stats_label.clear()
	stats_label.push_color(Color.RED)
	stats_label.add_text("STR: %d  " % strength)
	stats_label.pop()
	stats_label.push_color(Color.BLUE)
	stats_label.add_text("SPD: %d  " % speed)
	stats_label.pop()
	stats_label.push_color(Color.GREEN)
	stats_label.add_text("INT: %d" % intelligence)
	stats_label.pop()

	if is_busy:
		name_label.text = "%s (BUSY)" % god_name
		modulate = Color(0.5, 0.5, 0.5, 1.0)  # Gray out when busy
	else:
		modulate = Color(1.0, 1.0, 1.0, 1.0)

	# Visual feedback for selection
	if is_selected and not is_busy:
		add_theme_stylebox_override("panel", get_selected_style())
	else:
		remove_theme_stylebox_override("panel")

func get_selected_style():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.3, 0.5, 0.8, 1.0)
	style.border_color = Color(1.0, 1.0, 0.0, 1.0)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	return style

func set_busy(busy: bool):
	is_busy = busy
	update_display()

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_busy:
			is_selected = true
			update_display()
			god_clicked.emit(self)

func deselect():
	is_selected = false
	update_display()
