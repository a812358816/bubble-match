extends Node2D

signal bubble_clicked(bubble: Node2D)

@export var bubble_color: String = "pink"
@export var bubble_size: float = 60.0
@export var bubble_type: String = "normal"

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
		draw_circle(Vector2.ZERO, radius + 4.0, Color.WHITE)
		draw_circle(Vector2.ZERO, radius + 2.0, Color.BLACK)

	if bubble_type == "rainbow":
		_draw_rainbow(radius)
	elif bubble_type == "bomb":
		_draw_bomb(radius)
	else:
		_draw_normal(radius)


func _draw_normal(radius: float) -> void:
	var c: Color = COLORS.get(bubble_color, Color.WHITE)
	draw_circle(Vector2(2, 2), radius, Color(0, 0, 0, 0.15))
	draw_circle(Vector2.ZERO, radius, c)
	draw_circle(Vector2(-radius * 0.25, -radius * 0.3), radius * 0.28, Color(1, 1, 1, 0.4))


func _draw_bomb(radius: float) -> void:
	var c: Color = Color(0.2, 0.2, 0.2)
	draw_circle(Vector2(2, 2), radius, Color(0, 0, 0, 0.25))
	draw_circle(Vector2.ZERO, radius, c)
	draw_circle(Vector2(-radius * 0.25, -radius * 0.3), radius * 0.28, Color(1, 1, 1, 0.3))
	# 火焰星形
	var r := radius * 0.55
	var pts := PackedVector2Array()
	for i in 6:
		var angle := deg_to_rad(i * 60.0 - 90.0)
		pts.append(Vector2(cos(angle) * r, sin(angle) * r))
		angle += deg_to_rad(30.0)
		pts.append(Vector2(cos(angle) * r * 0.35, sin(angle) * r * 0.35))
	draw_colored_polygon(pts, Color(1.0, 0.55, 0.1))


func _draw_rainbow(radius: float) -> void:
	draw_circle(Vector2(2, 2), radius, Color(0, 0, 0, 0.15))
	draw_circle(Vector2.ZERO, radius, Color.WHITE)
	var ring_colors := [Color.RED, Color.ORANGE, Color.YELLOW, Color.GREEN, Color.BLUE, Color.PURPLE]
	for i in 6:
		var a1 := deg_to_rad(i * 60.0 - 90.0)
		var a2 := a1 + deg_to_rad(60.0)
		var pts := PackedVector2Array()
		pts.append(Vector2.ZERO)
		for j in 11:
			var a = a1 + (a2 - a1) * j / 10.0
			pts.append(Vector2(cos(a) * radius, sin(a) * radius))
		draw_colored_polygon(pts, ring_colors[i])
	draw_circle(Vector2(-radius * 0.25, -radius * 0.3), radius * 0.28, Color(1, 1, 1, 0.5))
	# 问号
	var font := ThemeDB.fallback_font
	var fsize := int(radius * 0.8)
	draw_string(font, Vector2(-fsize * 0.3, fsize * 0.35), "?", HORIZONTAL_ALIGNMENT_CENTER, fsize, fsize, Color.BLACK)


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
