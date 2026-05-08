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


func _ready() -> void:
	# Emoji fallback — ensures 🔀🏆🥇🥈🥉💣🌈 render correctly
	if _ui.theme.default_font:
		var emoji_font := load("res://assets/fonts/emoji.ttf") as FontFile
		if emoji_font:
			_ui.theme.default_font.fallbacks = [emoji_font]
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
	_shuffle_btn.text = "🔀 洗牌 (2)"
	_time_label.visible = true
	_score_label.visible = true
	_game_over_panel.visible = false
	_bubble_match.start_round()


func _on_restart_pressed() -> void:
	AudioManager.play_click()
	_game_over_panel.visible = false
	_bubble_match.start_round()


func _on_score_changed(new_score: int) -> void:
	_score_label.text = "⭐ %d" % new_score


func _on_time_updated(seconds: int) -> void:
	_time_label.text = "⏱ %d" % seconds


func _on_round_ended(final_score: int) -> void:
	AudioManager.play_game_over()
	_final_score_label.text = "得分：%d" % final_score

	if Leaderboard.is_high_score(final_score):
		Leaderboard.add_score("玩家", final_score)
	_leaderboard_label.text = "🏆 排行榜\n" + Leaderboard.get_rank_text()

	_game_over_panel.visible = true
	_start_btn.visible = false


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
	if remaining > 0:
		_shuffle_btn.text = "🔀 洗牌 (%d)" % remaining
		_shuffle_btn.visible = true
	else:
		_shuffle_btn.visible = false
