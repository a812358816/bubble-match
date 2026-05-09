extends Node2D

signal bubble_clicked(bubble: Node2D)

@export var bubble_color: String = "pink"
@export var bubble_size: float = 60.0
@export var bubble_type: String = "normal"

var _actual_bubble_size: float = 60.0

const COLORS := {
	"pink": Color("#FF69B4"),
	"blue": Color("#4169E1"),
	"yellow": Color("#FFD700"),
	"green": Color("#32CD32"),
	"purple": Color("#9370DB"),
	"orange": Color("#FF8C00")
}

var grid_pos: Vector2i = Vector2i(-1, -1)
var _highlighted: bool = false


func _ready() -> void:
	var shape := CircleShape2D.new()
	shape.radius = bubble_size / 2.0

	var collision := CollisionShape2D.new()
	collision.shape = shape

	var area := Area2D.new()
	area.add_child(collision)
	area.input_event.connect(_on_input_event)
	add_child(area)

	queue_redraw()


func _draw() -> void:
	var radius: float = bubble_size / 2.0

	if _highlighted:
		draw_circle(Vector2.ZERO, radius + 5.0, Color(1, 1, 1, 0.7))
		draw_circle(Vector2.ZERO, radius + 2.0, Color(1, 0.85, 0.3))

	if bubble_type == "rainbow":
		_draw_rainbow(radius)
	elif bubble_type == "bomb":
		_draw_bomb(radius)
	else:
		_draw_normal(radius)


func _draw_normal(radius: float) -> void:
	var c: Color = COLORS.get(bubble_color, Color.WHITE)

	# Soft shadow
	draw_circle(Vector2(3, 5), radius, Color(0, 0, 0, 0.08))

	# Outer rim (slightly darker)
	draw_circle(Vector2.ZERO, radius, c.darkened(0.18))

	# Base color
	draw_circle(Vector2.ZERO, radius * 0.93, c)

	# Inner light band
	draw_circle(Vector2.ZERO, radius * 0.62, c.lightened(0.18))

	# Bright center
	draw_circle(Vector2.ZERO, radius * 0.32, c.lightened(0.38))

	# Soft highlight top-left
	draw_circle(Vector2(-radius * 0.22, -radius * 0.28), radius * 0.32, Color(1, 1, 1, 0.3))
	# Sharp highlight dot
	draw_circle(Vector2(-radius * 0.18, -radius * 0.24), radius * 0.12, Color(1, 1, 1, 0.55))


func _draw_bomb(radius: float) -> void:
	# Shadow
	draw_circle(Vector2(3, 5), radius, Color(0, 0, 0, 0.1))

	# Dark metallic body
	draw_circle(Vector2.ZERO, radius, Color(0.08, 0.08, 0.1))
	draw_circle(Vector2.ZERO, radius * 0.9, Color(0.18, 0.18, 0.22))
	draw_circle(Vector2.ZERO, radius * 0.55, Color(0.28, 0.28, 0.32))

	# Gloss highlight
	draw_circle(Vector2(-radius * 0.2, -radius * 0.25), radius * 0.28, Color(1, 1, 1, 0.2))
	draw_circle(Vector2(-radius * 0.15, -radius * 0.22), radius * 0.1, Color(1, 1, 1, 0.35))

	# Fire star
	var r := radius * 0.55
	var pts := PackedVector2Array()
	for i in 6:
		var angle := deg_to_rad(i * 60.0 - 90.0)
		pts.append(Vector2(cos(angle) * r, sin(angle) * r))
		angle += deg_to_rad(30.0)
		pts.append(Vector2(cos(angle) * r * 0.35, sin(angle) * r * 0.35))
	draw_colored_polygon(pts, Color(1.0, 0.45, 0.05))
	# Inner flame
	var r2 := radius * 0.35
	var pts2 := PackedVector2Array()
	for i in 6:
		var angle := deg_to_rad(i * 60.0 - 90.0)
		pts2.append(Vector2(cos(angle) * r2, sin(angle) * r2))
		angle += deg_to_rad(30.0)
		pts2.append(Vector2(cos(angle) * r2 * 0.35, sin(angle) * r2 * 0.35))
	draw_colored_polygon(pts2, Color(1.0, 0.8, 0.15))


func _draw_rainbow(radius: float) -> void:
	# Shadow
	draw_circle(Vector2(3, 5), radius, Color(0, 0, 0, 0.08))
	# White base
	draw_circle(Vector2.ZERO, radius, Color(0.96, 0.96, 1.0))
	draw_circle(Vector2.ZERO, radius * 0.7, Color(1, 1, 1))

	# Ring segments
	var ring_colors := [
		Color(1.0, 0.25, 0.3), Color(1.0, 0.55, 0.1),
		Color(1.0, 0.85, 0.15), Color(0.3, 0.85, 0.25),
		Color(0.2, 0.55, 0.95), Color(0.45, 0.25, 0.9),
	]
	for i in 6:
		var a1 := deg_to_rad(i * 60.0 - 90.0)
		var a2 := a1 + deg_to_rad(60.0)
		var pts := PackedVector2Array()
		pts.append(Vector2.ZERO)
		for j in 11:
			var a = a1 + (a2 - a1) * j / 10.0
			pts.append(Vector2(cos(a) * radius, sin(a) * radius))
		draw_colored_polygon(pts, ring_colors[i])

	# Highlight
	draw_circle(Vector2(-radius * 0.2, -radius * 0.28), radius * 0.3, Color(1, 1, 1, 0.35))
	draw_circle(Vector2(-radius * 0.15, -radius * 0.22), radius * 0.1, Color(1, 1, 1, 0.6))

	# Question mark
	var font := ThemeDB.fallback_font
	var fsize := int(radius * 0.75)
	draw_string(font, Vector2(-fsize * 0.3, fsize * 0.32), "?", HORIZONTAL_ALIGNMENT_CENTER, fsize, fsize, Color(0.15, 0.15, 0.15))


func play_pop_animation() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.25, 1.25), 0.08)
	tween.tween_property(self, "modulate:a", 0.5, 0.08)
	tween.chain().tween_property(self, "scale", Vector2.ZERO, 0.12)
	tween.chain().tween_callback(queue_free)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("bubble_clicked", self)
