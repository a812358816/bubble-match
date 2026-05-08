extends Node

@onready var _bubble_match: Node2D = $BubbleMatch
@onready var _ui: Control = $GameUI
@onready var _time_label: Label = $GameUI/TimeLabel
@onready var _score_label: Label = $GameUI/ScoreLabel
@onready var _start_btn: Button = $GameUI/StartButton
@onready var _shuffle_btn: Button = $GameUI/ShuffleButton
@onready var _game_over_panel: Panel = $GameUI/GameOverPanel
@onready var _final_score_label: Label = $GameUI/GameOverPanel/FinalScoreLabel
@onready var _restart_btn: Button = $GameUI/GameOverPanel/RestartButton
@onready var _leaderboard_label: Label = $GameUI/GameOverPanel/LeaderboardLabel
@onready var _rank_btn: Button = $GameUI/RankButton
@onready var _rank_panel: Panel = $GameUI/RankPanel
@onready var _rank_list_label: Label = $GameUI/RankPanel/RankListLabel
@onready var _rank_back_btn: Button = $GameUI/RankPanel/RankBackButton

var _time_pulse_tween: Tween


func _ready() -> void:
	_setup_ui()
	_bubble_match.score_changed.connect(_on_score_changed)
	_bubble_match.time_updated.connect(_on_time_updated)
	_bubble_match.round_ended.connect(_on_round_ended)
	_bubble_match.shuffle_count_changed.connect(_on_shuffle_count_changed)
	_start_btn.pressed.connect(_on_start_pressed)
	_shuffle_btn.pressed.connect(_on_shuffle_pressed)
	_restart_btn.pressed.connect(_on_restart_pressed)
	_rank_btn.pressed.connect(_on_rank_pressed)
	_rank_back_btn.pressed.connect(_on_rank_back_pressed)
	_show_start_screen()


func _setup_ui() -> void:
	# Button icons — generated programmatically
	for btn in [_start_btn, _shuffle_btn, _rank_btn, _restart_btn, _rank_back_btn]:
		btn.icon_max_width = 24
	_start_btn.icon = _make_icon("play")
	_shuffle_btn.icon = _make_icon("shuffle")
	_rank_btn.icon = _make_icon("rank")
	_restart_btn.icon = _make_icon("restart")
	_rank_back_btn.icon = _make_icon("back")

	# Time label badge
	var time_bg := StyleBoxFlat.new()
	time_bg.bg_color = Color(0.12, 0.06, 0.22, 0.88)
	time_bg.set_corner_radius_all(12)
	time_bg.content_margin_left = 14
	time_bg.content_margin_right = 14
	time_bg.content_margin_top = 6
	time_bg.content_margin_bottom = 6
	_time_label.add_theme_stylebox_override("normal", time_bg)

	# Score label badge
	var score_bg := StyleBoxFlat.new()
	score_bg.bg_color = Color(0.12, 0.06, 0.22, 0.88)
	score_bg.set_corner_radius_all(12)
	score_bg.content_margin_left = 14
	score_bg.content_margin_right = 14
	score_bg.content_margin_top = 6
	score_bg.content_margin_bottom = 6
	_score_label.add_theme_stylebox_override("normal", score_bg)


func _make_icon(type: String) -> Texture2D:
	var s := 24
	var img := Image.create(s, s, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var w := Color.WHITE

	match type:
		"play":
			_fill_triangle(img, Vector2i(7, 5), Vector2i(7, s - 5), Vector2i(s - 5, s / 2), w)
		"shuffle":
			_fill_triangle(img, Vector2i(16, 5), Vector2i(16, 12), Vector2i(5, 12), w)
			_fill_triangle(img, Vector2i(8, 19), Vector2i(8, 12), Vector2i(19, 12), w)
		"rank":
			for i in range(3):
				var y := 5 + i * 7
				_fill_triangle(img, Vector2i(s / 2, y), Vector2i(s / 2 + 6, y + 5), Vector2i(s / 2 - 6, y + 5), w)
		"restart":
			_draw_ring(img, Vector2i(s / 2, s / 2), 8, 2, w)
			_fill_triangle(img, Vector2i(s / 2 + 5, 5), Vector2i(s / 2 + 5, 12), Vector2i(s / 2 + 11, 8), w)
		"back":
			_fill_triangle(img, Vector2i(7, s / 2), Vector2i(s - 6, 5), Vector2i(s - 6, s - 5), w)

	return ImageTexture.create_from_image(img)


func _fill_triangle(img: Image, p1: Vector2i, p2: Vector2i, p3: Vector2i, color: Color) -> void:
	var min_y := mini(mini(p1.y, p2.y), p3.y)
	var max_y := maxi(maxi(p1.y, p2.y), p3.y)
	for y in range(maxi(0, min_y), mini(img.get_height(), max_y + 1)):
		var x_left := 999
		var x_right := -999
		for pair in [[p1, p2], [p2, p3], [p3, p1]]:
			var a: Vector2i = pair[0]
			var b: Vector2i = pair[1]
			if (a.y <= y and b.y > y) or (b.y <= y and a.y > y):
				var t := float(y - a.y) / float(b.y - a.y) if b.y != a.y else 0.0
				var x := int(a.x + t * float(b.x - a.x))
				x_left = mini(x_left, x)
				x_right = maxi(x_right, x)
		for x in range(maxi(0, x_left), mini(img.get_width(), x_right + 1)):
			img.set_pixel(x, y, color)


func _draw_ring(img: Image, center: Vector2i, radius: int, thickness: int, color: Color) -> void:
	for y in range(maxi(0, center.y - radius - thickness), mini(img.get_height(), center.y + radius + thickness + 1)):
		for x in range(maxi(0, center.x - radius - thickness), mini(img.get_width(), center.x + radius + thickness + 1)):
			var dx := float(x - center.x)
			var dy := float(y - center.y)
			var dist := sqrt(dx * dx + dy * dy)
			var inner := float(radius - thickness)
			if dist >= inner - 0.5 and dist <= float(radius) + 0.5:
				img.set_pixel(x, y, color)


func _show_start_screen() -> void:
	_ui.visible = true
	_start_btn.visible = true
	_rank_btn.visible = true
	_shuffle_btn.visible = false
	_time_label.visible = false
	_score_label.visible = false
	_game_over_panel.visible = false
	_rank_panel.visible = false


func _on_start_pressed() -> void:
	AudioManager.play_click()
	_start_btn.visible = false
	_rank_btn.visible = false
	_shuffle_btn.visible = true
	_shuffle_btn.disabled = false
	_shuffle_btn.text = "洗牌 (3)"
	_time_label.visible = true
	_score_label.visible = true
	_game_over_panel.visible = false
	_bubble_match.start_round()


func _on_restart_pressed() -> void:
	AudioManager.play_click()
	_game_over_panel.visible = false
	_bubble_match.start_round()


func _on_score_changed(new_score: int) -> void:
	_score_label.text = "★ %d" % new_score


func _on_time_updated(seconds: int) -> void:
	_time_label.text = "%d 秒" % seconds

	if _time_pulse_tween and _time_pulse_tween.is_valid():
		_time_pulse_tween.kill()

	if seconds <= 10:
		_time_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25))
		_time_pulse_tween = create_tween().set_loops()
		_time_pulse_tween.tween_property(_time_label, "modulate:a", 0.4, 0.35)
		_time_pulse_tween.tween_property(_time_label, "modulate:a", 1.0, 0.35)
	elif seconds <= 30:
		_time_label.add_theme_color_override("font_color", Color(1.0, 0.75, 0.2))
	else:
		_time_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))


func _on_round_ended(final_score: int) -> void:
	AudioManager.play_game_over()
	_final_score_label.text = "得分：%d" % final_score

	if Leaderboard.is_high_score(final_score):
		Leaderboard.add_score("玩家", final_score)
	_leaderboard_label.text = "排行榜\n" + Leaderboard.get_rank_text()

	_game_over_panel.visible = true
	_start_btn.visible = false

	if _time_pulse_tween and _time_pulse_tween.is_valid():
		_time_pulse_tween.kill()
	_time_label.modulate.a = 1.0


func _on_rank_pressed() -> void:
	AudioManager.play_click()
	_rank_list_label.text = Leaderboard.get_rank_text()
	_rank_panel.visible = true
	_start_btn.visible = false
	_rank_btn.visible = false


func _on_rank_back_pressed() -> void:
	AudioManager.play_click()
	_rank_panel.visible = false
	_start_btn.visible = true
	_rank_btn.visible = true


func _on_shuffle_pressed() -> void:
	AudioManager.play_click()
	_bubble_match.do_shuffle()


func _on_shuffle_count_changed(remaining: int) -> void:
	_shuffle_btn.text = "洗牌 (%d)" % remaining
	_shuffle_btn.disabled = remaining <= 0
	_shuffle_btn.visible = true
