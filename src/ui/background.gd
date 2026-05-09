extends Node2D

## 梦幻背景：柔和渐变 + 漂浮泡泡粒子

const MAX_PARTICLES := 20
const SPAWN_INTERVAL := 2.8

@export var gradient_top := Color(0.992, 0.882, 0.941)
@export var gradient_bottom := Color(0.91, 0.835, 0.961)

class Particle:
	var pos: Vector2
	var size: float
	var color: Color
	var speed: float
	var alpha: float
	var offset: float

var _particles: Array = []
var _timer: float = 0.0
var _screen_size: Vector2

var _pastels := [
	Color(1.0, 0.82, 0.9),
	Color(0.85, 0.78, 1.0),
	Color(0.82, 0.92, 1.0),
	Color(1.0, 0.9, 0.75),
	Color(0.88, 1.0, 0.9),
]


func _ready() -> void:
	_screen_size = get_viewport().get_visible_rect().size
	for _i in MAX_PARTICLES:
		var p := _make_particle()
		p.pos.y = randf() * _screen_size.y
		_particles.append(p)
	get_viewport().size_changed.connect(_on_resize)


func _on_resize() -> void:
	_screen_size = get_viewport().get_visible_rect().size


func _process(delta: float) -> void:
	_timer += delta
	if _timer >= SPAWN_INTERVAL:
		_timer = 0.0

	for p: Particle in _particles:
		p.pos.y -= p.speed * delta
		p.pos.x += sin(Time.get_ticks_msec() * 0.0008 + p.offset) * 10.0 * delta
		p.alpha -= 0.1 * delta
		if p.pos.y < -60.0 or p.alpha <= 0.0:
			_reset_particle(p)

	queue_redraw()


func _draw() -> void:
	# 柔和纵向渐变
	var steps := 24
	var row_h: float = _screen_size.y / steps
	for i in steps:
		var t := float(i) / float(steps - 1)
		var c := gradient_top.lerp(gradient_bottom, t)
		draw_rect(Rect2(0, i * row_h, _screen_size.x, row_h + 1), c)

	# 漂浮粒子
	for p: Particle in _particles:
		var c := p.color
		draw_circle(p.pos, p.size, Color(c.r, c.g, c.b, p.alpha * 0.1))
		draw_circle(p.pos, p.size * 0.55, Color(c.r, c.g, c.b, p.alpha * 0.18))
		draw_circle(p.pos, p.size * 0.22, Color(1, 1, 1, p.alpha * 0.3))


func _make_particle() -> Particle:
	var p := Particle.new()
	_reset_particle(p)
	p.pos.y = randf() * _screen_size.y
	return p


func _reset_particle(p: Particle) -> void:
	p.pos = Vector2(randf() * _screen_size.x, _screen_size.y + randf() * 50.0 + 20.0)
	p.size = randf() * 22.0 + 6.0
	p.color = _pastels[randi() % _pastels.size()]
	p.speed = randf() * 20.0 + 10.0
	p.alpha = randf() * 0.35 + 0.08
	p.offset = randf() * TAU
