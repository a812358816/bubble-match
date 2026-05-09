extends Node

@onready var _bubble_match: Node2D = $BubbleMatch
@onready var _ui: Control = $UILayer/GameUI
@onready var _time_label: Label = $UILayer/GameUI/TimeLabel
@onready var _score_label: Label = $UILayer/GameUI/ScoreLabel
@onready var _start_btn: Button = $UILayer/GameUI/StartButton
@onready var _shuffle_btn: Button = $UILayer/GameUI/ShuffleButton
@onready var _game_over_panel: Panel = $UILayer/GameUI/GameOverPanel
@onready var _final_score_label: Label = $UILayer/GameUI/GameOverPanel/FinalScoreLabel
@onready var _restart_btn: Button = $UILayer/GameUI/GameOverPanel/RestartButton
@onready var _leaderboard_label: Label = $UILayer/GameUI/GameOverPanel/LeaderboardLabel
@onready var _rank_btn: Button = $UILayer/GameUI/RankButton
@onready var _rank_panel: Panel = $UILayer/GameUI/RankPanel
@onready var _rank_list_label: Label = $UILayer/GameUI/RankPanel/RankListLabel
@onready var _rank_back_btn: Button = $UILayer/GameUI/RankPanel/RankBackButton

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
	# Time label badge
	var time_bg := StyleBoxFlat.new()
	time_bg.bg_color = Color(0.82, 0.55, 0.9, 0.82)
	time_bg.set_corner_radius_all(16)
	time_bg.shadow_color = Color(0.45, 0.2, 0.55, 0.3)
	time_bg.shadow_size = 3
	time_bg.shadow_offset = Vector2(0, 2)
	time_bg.content_margin_left = 16
	time_bg.content_margin_right = 16
	time_bg.content_margin_top = 8
	time_bg.content_margin_bottom = 8
	_time_label.add_theme_stylebox_override("normal", time_bg)

	# Score label badge
	var score_bg := StyleBoxFlat.new()
	score_bg.bg_color = Color(0.82, 0.55, 0.9, 0.82)
	score_bg.set_corner_radius_all(16)
	score_bg.shadow_color = Color(0.45, 0.2, 0.55, 0.3)
	score_bg.shadow_size = 3
	score_bg.shadow_offset = Vector2(0, 2)
	score_bg.content_margin_left = 16
	score_bg.content_margin_right = 16
	score_bg.content_margin_top = 8
	score_bg.content_margin_bottom = 8
	_score_label.add_theme_stylebox_override("normal", score_bg)






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
	_shuffle_btn.text = "↻ 洗牌 (3)"
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
		_time_label.add_theme_color_override("font_color", Color(1.0, 0.22, 0.32))
		_time_pulse_tween = create_tween().set_loops()
		_time_pulse_tween.tween_property(_time_label, "modulate:a", 0.4, 0.3)
		_time_pulse_tween.tween_property(_time_label, "modulate:a", 1.0, 0.3)
	elif seconds <= 30:
		_time_label.add_theme_color_override("font_color", Color(1.0, 0.65, 0.25))
	else:
		_time_label.add_theme_color_override("font_color", Color(0.45, 0.92, 0.55))


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
	_shuffle_btn.text = "↻ 洗牌 (%d)" % remaining
	_shuffle_btn.disabled = remaining <= 0
	_shuffle_btn.visible = true
