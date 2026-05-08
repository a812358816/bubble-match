extends Node

## 排行榜：保存到文件，显示前 5 名

const SAVE_PATH := "user://highscores.save"
const MAX_ENTRIES := 5

var scores: Array = []  # [{name: String, score: int}]


func _ready() -> void:
	_load()


func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		scores = _default_scores()
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text := f.get_as_text()
	f.close()
	scores = JSON.parse_string(text)
	if scores == null:
		scores = _default_scores()


func _save() -> void:
	scores.sort_custom(func(a, b): return a.score > b.score)
	if scores.size() > MAX_ENTRIES:
		scores = scores.slice(0, MAX_ENTRIES)
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(scores))
	f.close()


func _default_scores() -> Array:
	return [
		{"name": "星星", "score": 0},
		{"name": "月亮", "score": 0},
		{"name": "花花", "score": 0},
		{"name": "糖果", "score": 0},
		{"name": "彩虹", "score": 0}
	]


func is_high_score(score: int) -> bool:
	if score <= 0:
		return false
	if scores.size() < MAX_ENTRIES:
		return true
	return score > scores[MAX_ENTRIES - 1].score


func add_score(player_name: String, score: int) -> void:
	scores.append({"name": player_name, "score": score})
	_save()


func get_rank_text() -> String:
	var lines: Array[String] = []
	for i in scores.size():
		var e: Dictionary = scores[i]
		var medal := ""
		match i:
			0: medal = "🥇"
			1: medal = "🥈"
			2: medal = "🥉"
			_: medal = "  %d" % (i + 1)
		lines.append("%s  %s  %d分" % [medal, e.name, e.score])
	return "\n".join(lines)
