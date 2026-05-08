extends Node2D

signal score_changed(new_score: int)
signal round_ended(final_score: int)
signal time_updated(seconds: int)
signal shuffle_count_changed(remaining: int)

const BUBBLE_SCENE := preload("res://src/gameplay/bubble.tscn")

@export var grid_cols: int = 8
@export var grid_rows: int = 8
@export var bubble_size: float = 60.0
@export var min_match: int = 3
@export var offset_x: float = 30.0
@export var offset_y: float = 30.0
@export var round_seconds: float = 60.0

var _grid: Array = []
var _bubble_nodes: Array = []
var _score: int = 0
var _time_left: float = 0.0
var _running: bool = false
var _processing: bool = false
const ALL_COLORS: Array[String] = ["pink", "blue", "yellow", "green", "purple", "orange"]
var _active_colors: Array[String] = []
var _float_labels: Array[Label] = []
var _combo: int = 0
var _last_match_msec: int = 0
var _difficulty_level: int = 0
var _miss_streak: int = 0
var _next_row_spawn: float = 0.0
var _shuffle_remaining: int = 0
const COMBO_WINDOW_MSEC: int = 2000
const ROW_SPAWN_INTERVAL: float = 10.0
const COMBO_COLORS: Dictionary = {0: Color.WHITE, 1: Color(0.5, 1.0, 0.5), 2: Color(1.0, 0.9, 0.3), 3: Color(1.0, 0.5, 0.2)}
const SPECIAL_THRESHOLD: int = 5
const SHUFFLE_COUNT: int = 3


func _ready() -> void:
	$Timer.timeout.connect(_on_timer_timeout)


func _make_grid_data(color: String = "", bubble_type: String = "normal") -> Dictionary:
	return {"color": _random_color() if color == "" else color, "type": bubble_type}


func _init_grid() -> void:
	_grid.clear()
	_bubble_nodes.clear()
	for col in range(grid_cols):
		var column_data: Array = []
		var column_nodes: Array = []
		for _row in range(grid_rows):
			column_data.append(_make_grid_data())
			column_nodes.append(null)
		_grid.append(column_data)
		_bubble_nodes.append(column_nodes)


func _pick_random_colors(count: int) -> Array[String]:
	var pool := ALL_COLORS.duplicate()
	pool.shuffle()
	var result: Array[String] = []
	for i in mini(count, pool.size()):
		result.append(pool[i])
	return result


func _random_color() -> String:
	return _active_colors[randi() % _active_colors.size()]


func _create_bubble(col: int, row: int, data: Dictionary) -> Node2D:
	var b := BUBBLE_SCENE.instantiate()
	b.bubble_color = data["color"]
	b.bubble_type = data.get("type", "normal")
	b.bubble_size = bubble_size
	b.grid_pos = Vector2i(col, row)
	b.position = _grid_to_world(col, row)
	b.bubble_clicked.connect(_on_bubble_clicked)
	add_child(b)
	return b


func _refresh_visuals() -> void:
	_clear_bubble_nodes()
	for col in range(grid_cols):
		for row in range(grid_rows):
			var data: Dictionary = _grid[col][row]
			_bubble_nodes[col][row] = _create_bubble(col, row, data)


func _clear_bubble_nodes() -> void:
	for col in range(grid_cols):
		for row in range(grid_rows):
			var node: Node2D = _bubble_nodes[col][row]
			if is_instance_valid(node):
				node.queue_free()
			_bubble_nodes[col][row] = null


func _grid_to_world(col: int, row: int) -> Vector2:
	var grid_w: float = grid_cols * bubble_size
	var grid_h: float = grid_rows * bubble_size
	var screen := get_viewport().get_visible_rect().size
	return Vector2((screen.x - grid_w) / 2.0 + col * bubble_size + offset_x, (screen.y - grid_h) / 2.0 + row * bubble_size + offset_y)


func _is_valid_cell(col: int, row: int) -> bool:
	return col >= 0 and col < grid_cols and row >= 0 and row < grid_rows


func start_round() -> void:
	_score = 0
	_time_left = round_seconds
	_running = true
	for col: Array in _bubble_nodes:
		for node: Node2D in col:
			if is_instance_valid(node):
				node.queue_free()
	_combo = 0
	_last_match_msec = 0
	_difficulty_level = 0
	_miss_streak = 0
	_next_row_spawn = 15.0
	_shuffle_remaining = SHUFFLE_COUNT
	_active_colors = _pick_random_colors(3)
	_init_grid()
	_refresh_visuals()
	score_changed.emit(_score)
	time_updated.emit(int(_time_left))
	shuffle_count_changed.emit(_shuffle_remaining)
	$Timer.start()


func _on_timer_timeout() -> void:
	if not _running:
		return
	_time_left = maxf(_time_left - 1.0, 0.0)
	time_updated.emit(int(_time_left))
	_next_row_spawn -= 1.0
	if _next_row_spawn <= 0.0:
		_spawn_row()
		_next_row_spawn = ROW_SPAWN_INTERVAL
	if _time_left <= 0.0:
		_end_round()


func _spawn_row() -> void:
	var overflow_count := 0
	for col in range(grid_cols):
		var bottom: Node2D = _bubble_nodes[col][grid_rows - 1]
		if is_instance_valid(bottom):
			bottom.play_pop_animation()
			_bubble_nodes[col][grid_rows - 1] = null
			_grid[col][grid_rows - 1] = null
			overflow_count += 1

	for col in range(grid_cols):
		for row in range(grid_rows - 2, -1, -1):
			_grid[col][row + 1] = _grid[col][row]
			_grid[col][row] = null
			var node: Node2D = _bubble_nodes[col][row]
			_bubble_nodes[col][row + 1] = node
			_bubble_nodes[col][row] = null
			if is_instance_valid(node):
				node.grid_pos = Vector2i(col, row + 1)
				var tw_move := create_tween()
				tw_move.tween_property(node, "position", _grid_to_world(col, row + 1), 0.35).set_ease(Tween.EASE_OUT)

		_grid[col][0] = _make_grid_data()
		var b := _create_bubble(col, 0, _grid[col][0])
		b.position = _grid_to_world(col, 0) + Vector2(0, -bubble_size)
		_bubble_nodes[col][0] = b
		var tw := create_tween()
		tw.tween_property(b, "position", _grid_to_world(col, 0), 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)

	if overflow_count > 0:
		var penalty := overflow_count
		_add_time(-penalty)
		_show_floating_text(Vector2(200, 250), "溢出 %d个 -%ds!" % [overflow_count, penalty], Color(1.0, 0.2, 0.2))
	_show_floating_text(Vector2(200, 200), "行上升!", Color(1.0, 0.5, 0.2))


func _end_round() -> void:
	_running = false
	$Timer.stop()
	round_ended.emit(_score)


func _on_bubble_clicked(bubble: Node2D) -> void:
	if _processing or not _running:
		return

	var orig_scale = bubble.scale
	var tween = create_tween()
	tween.tween_property(bubble, "scale", orig_scale * 1.1, 0.08).set_ease(Tween.EASE_OUT)
	tween.tween_property(bubble, "scale", orig_scale, 0.08).set_ease(Tween.EASE_IN)

	var grid_pos := _find_bubble_grid_pos(bubble)
	if grid_pos.x < 0:
		return

	var data: Dictionary = _grid[grid_pos.x][grid_pos.y]
	var btype: String = data.get("type", "normal")

	if btype == "bomb":
		_process_bomb(grid_pos)
	elif btype == "rainbow":
		_process_rainbow(grid_pos)
	else:
		var group := _find_connected(grid_pos, data["color"])
		if group.size() >= min_match:
			_process_match(group)
		else:
			_show_invalid(bubble)


func _process_bomb(pos: Vector2i) -> void:
	_processing = true
	var affected: Array[Vector2i] = []
	for dc in range(-1, 2):
		for dr in range(-1, 2):
			var nc := pos.x + dc
			var nr := pos.y + dr
			if _is_valid_cell(nc, nr) and _grid[nc][nr] != null:
				affected.append(Vector2i(nc, nr))

	for p in affected:
		var node: Node2D = _bubble_nodes[p.x][p.y]
		if is_instance_valid(node):
			node.play_pop_animation()
			_bubble_nodes[p.x][p.y] = null
		_grid[p.x][p.y] = null

	await get_tree().create_timer(0.3).timeout
	AudioManager.play_pop(affected.size())

	var bonus := clampi(affected.size() - 2, 1, 5)
	_add_time(bonus)
	_show_floating_text(_grid_to_world(pos.x, pos.y), "◆ 炸弹 +%ds" % bonus, Color(1.0, 0.5, 0.1))

	_combo = 1
	_last_match_msec = Time.get_ticks_msec()
	_miss_streak = 0

	_check_difficulty()
	_apply_gravity()
	_fill_empty()
	_score += affected.size() * 10
	score_changed.emit(_score)
	_processing = false


func _process_rainbow(pos: Vector2i) -> void:
	_processing = true
	# 找到当前数量最多的颜色
	var color_counts: Dictionary = {}
	for col in range(grid_cols):
		for row in range(grid_rows):
			if _grid[col][row] != null and _grid[col][row].get("type", "normal") == "normal":
				var c: String = _grid[col][row]["color"]
				color_counts[c] = color_counts.get(c, 0) + 1
	var target_color: String = ""
	var max_count := 0
	for c in color_counts:
		if color_counts[c] > max_count:
			max_count = color_counts[c]
			target_color = c

	var affected: Array[Vector2i] = []
	for col in range(grid_cols):
		for row in range(grid_rows):
			if _grid[col][row] != null and _grid[col][row].get("type", "normal") == "normal" and _grid[col][row]["color"] == target_color:
				affected.append(Vector2i(col, row))
	affected.append(pos)  # 彩虹自身也消除

	for p in affected:
		var node: Node2D = _bubble_nodes[p.x][p.y]
		if is_instance_valid(node):
			node.play_pop_animation()
			_bubble_nodes[p.x][p.y] = null
		_grid[p.x][p.y] = null

	await get_tree().create_timer(0.3).timeout
	AudioManager.play_pop(affected.size())

	var bonus: int = clampi(affected.size() / 3, 2, 8)
	_add_time(bonus)
	_show_floating_text(_grid_to_world(pos.x, pos.y), "◇ 彩虹 +%ds" % bonus, Color(1.0, 0.3, 0.8))

	_combo = 1
	_last_match_msec = Time.get_ticks_msec()
	_miss_streak = 0

	_check_difficulty()
	_apply_gravity()
	_fill_empty()
	_score += affected.size() * 15
	score_changed.emit(_score)
	_processing = false


func _find_bubble_grid_pos(bubble: Node2D) -> Vector2i:
	return bubble.grid_pos


func _find_connected(start: Vector2i, target_color: String) -> Array[Vector2i]:
	var visited: Array = []
	var result: Array[Vector2i] = []
	var stack: Array[Vector2i] = [start]

	for col in range(grid_cols):
		visited.append([])
		for _row in range(grid_rows):
			visited[col].append(false)

	while stack.size() > 0:
		var cur: Vector2i = stack.pop_back()
		var c: int = cur.x
		var r: int = cur.y

		if not _is_valid_cell(c, r) or visited[c][r]:
			continue
		visited[c][r] = true

		if _grid[c][r] != null and _grid[c][r]["color"] == target_color and _grid[c][r].get("type", "normal") == "normal":
			result.append(cur)
			for d in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
				stack.append(cur + d)

	return result


func _process_match(group: Array[Vector2i]) -> void:
	_processing = true

	for pos in group:
		var node: Node2D = _bubble_nodes[pos.x][pos.y]
		if is_instance_valid(node):
			var orig_modulate = node.modulate
			node.modulate = Color(1.2, 1.2, 0.9)
			var tween = create_tween()
			tween.tween_property(node, "modulate", orig_modulate, 0.18)

	# 计算中心位置用于放置特殊气泡
	var center_x: float = 0.0
	var center_y: float = 0.0
	for pos in group:
		center_x += pos.x
		center_y += pos.y
	center_x /= group.size()
	center_y /= group.size()
	var center_col := int(round(center_x))
	var center_row := int(round(center_y))
	center_col = clampi(center_col, 0, grid_cols - 1)
	center_row = clampi(center_row, 0, grid_rows - 1)

	var should_drop_special := _roll_special_drop(group.size())

	for pos in group:
		var node: Node2D = _bubble_nodes[pos.x][pos.y]
		if is_instance_valid(node):
			node.play_pop_animation()
			_bubble_nodes[pos.x][pos.y] = null
		_grid[pos.x][pos.y] = null

	await get_tree().create_timer(0.3).timeout

	AudioManager.play_pop(group.size())

	var now_msec := Time.get_ticks_msec()
	if _last_match_msec > 0 and now_msec - _last_match_msec < COMBO_WINDOW_MSEC:
		_combo += 1
	else:
		_combo = 1
	_last_match_msec = now_msec
	_miss_streak = 0

	var bonus := 0
	match group.size():
		3: bonus = 2
		4, 5: bonus = 3
		_: bonus = 5
	_add_time(bonus)
	var color: Color
	match group.size():
		3: color = Color(0.3, 1.0, 0.3)
		4, 5: color = Color(1.0, 0.9, 0.3)
		_: color = Color(1.0, 0.5, 0.2)
	_show_floating_text(_grid_to_world(group[0].x, group[0].y), "+%ds" % bonus, color)

	_check_difficulty()

	_apply_gravity()

	# 在大组消除位置放置特殊气泡
	if should_drop_special and not _has_special_on_grid():
		# 如果目标位置没被 gravity 清空，找最近的空位
		if _grid[center_col][center_row] != null:
			var found := false
			for r in range(grid_rows):
				if _grid[center_col][r] == null:
					center_row = r
					found = true
					break
			if not found:
				center_row = grid_rows - 1

		var special_type := "bomb" if randi() % 2 == 0 else "rainbow"
		var special_color := _random_color()
		_grid[center_col][center_row] = {"color": special_color, "type": special_type}
		var b := _create_bubble(center_col, center_row, _grid[center_col][center_row])
		b.position = _grid_to_world(center_col, center_row) + Vector2(0, -80)
		_bubble_nodes[center_col][center_row] = b
		var tw := create_tween()
		tw.tween_property(b, "position", _grid_to_world(center_col, center_row), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
		_show_floating_text(_grid_to_world(center_col, center_row), "特殊!" if special_type == "bomb" else "彩虹!",
			Color(1.0, 0.5, 0.1) if special_type == "bomb" else Color(1.0, 0.3, 0.8))

	_fill_empty()
	var combo_mult := 1.0 + (_combo - 1) * 0.5
	var earned := int(group.size() * 10 * combo_mult)
	_score += earned
	if _combo >= 2:
		_show_floating_text(_grid_to_world(group[0].x, group[0].y) + Vector2(0, -55), "x%d!" % _combo, COMBO_COLORS.get(mini(_combo, 3), Color.WHITE))
	score_changed.emit(_score)
	_processing = false


func _show_invalid(bubble: Node2D) -> void:
	AudioManager.play_invalid()
	_combo = 0
	_miss_streak += 1
	var penalty := 2
	_add_time(-penalty)
	_show_floating_text(bubble.position, "-%ds" % penalty, Color(1.0, 0.3, 0.3))
	var tween := create_tween()
	var orig_x: float = bubble.position.x
	tween.tween_property(bubble, "position:x", orig_x - 4.0, 0.04)
	tween.tween_property(bubble, "position:x", orig_x + 4.0, 0.04)
	tween.tween_property(bubble, "position:x", orig_x - 3.0, 0.04)
	tween.tween_property(bubble, "position:x", orig_x + 3.0, 0.04)
	tween.tween_property(bubble, "position:x", orig_x, 0.04)


func _add_time(delta: int) -> void:
	_time_left = maxf(_time_left + delta, 0.0)
	time_updated.emit(int(_time_left))


func _check_difficulty() -> void:
	var target_level: int = 0
	if _score >= 400:
		target_level = 3
	elif _score >= 200:
		target_level = 2
	elif _score >= 80:
		target_level = 1
	if target_level > _difficulty_level:
		_difficulty_level = target_level
		var target_colors := mini(3 + target_level, 4)
		while _active_colors.size() < target_colors:
			for c in ALL_COLORS:
				if c not in _active_colors:
					_active_colors.append(c)
					_show_floating_text(Vector2(200, 100), "新颜色!", Color(1.0, 0.8, 0.2))
					break


func _has_special_on_grid() -> bool:
	for col in range(grid_cols):
		for row in range(grid_rows):
			if _grid[col][row] != null and _grid[col][row].get("type", "normal") != "normal":
				return true
	return false


func _roll_special_drop(group_size: int) -> bool:
	if group_size < 5:
		return false
	var chance: float = 0.0
	match group_size:
		5: chance = 0.25
		6: chance = 0.50
		_: chance = 1.0
	return randf() < chance


func do_shuffle() -> void:
	if _shuffle_remaining <= 0 or not _running or _processing:
		return
	_shuffle_remaining -= 1
	shuffle_count_changed.emit(_shuffle_remaining)

	# 收集所有非空气泡的颜色
	var colors: Array[String] = []
	for col in range(grid_cols):
		for row in range(grid_rows):
			if _grid[col][row] != null:
				colors.append(_grid[col][row]["color"])
	colors.shuffle()

	# 随机重分配颜色，所有气泡转为 normal
	var idx := 0
	for col in range(grid_cols):
		for row in range(grid_rows):
			if _grid[col][row] != null:
				_grid[col][row]["color"] = colors[idx]
				_grid[col][row]["type"] = "normal"
				idx += 1

	# 重新创建全部视觉节点
	_clear_bubble_nodes()
	for col in range(grid_cols):
		for row in range(grid_rows):
			if _grid[col][row] != null:
				_bubble_nodes[col][row] = _create_bubble(col, row, _grid[col][row])

	_show_floating_text(Vector2(200, 150), "↻ 洗牌 (%d)" % _shuffle_remaining, Color(0.6, 0.8, 1.0))


func _show_floating_text(world_pos: Vector2, text: String, clr: Color) -> void:
	var label := _acquire_float_label()
	label.text = text
	label.add_theme_color_override("font_color", clr)
	label.position = world_pos + global_position - Vector2(40, 40)
	label.scale = Vector2(0.3, 0.3)
	label.modulate.a = 1.0
	label.visible = true

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "scale", Vector2(1.5, 1.5), 0.12).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.chain().tween_property(label, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_property(label, "position:y", label.position.y - 60.0, 0.7).set_delay(0.22)
	tween.tween_property(label, "modulate:a", 0.0, 0.5).set_delay(0.3)
	tween.chain().tween_callback(func(): label.visible = false)


func _acquire_float_label() -> Label:
	for lbl in _float_labels:
		if not lbl.visible:
			lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			return lbl
	var lbl := Label.new()
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 48)
	lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	lbl.add_theme_constant_override("outline_size", 3)
	lbl.size = Vector2(80, 40)
	lbl.visible = false
	get_tree().current_scene.add_child(lbl)
	_float_labels.append(lbl)
	return lbl


func _apply_gravity() -> void:
	for col in range(grid_cols):
		var write_row: int = grid_rows - 1
		for row in range(grid_rows - 1, -1, -1):
			if _grid[col][row] != null:
				if write_row != row:
					_grid[col][write_row] = _grid[col][row]
					_grid[col][row] = null
					var node: Node2D = _bubble_nodes[col][row]
					_bubble_nodes[col][write_row] = node
					_bubble_nodes[col][row] = null
					if is_instance_valid(node):
						node.grid_pos = Vector2i(col, write_row)
						var tw := create_tween()
						tw.tween_property(node, "position", _grid_to_world(col, write_row), 0.2).set_ease(Tween.EASE_OUT)
				write_row -= 1


func _fill_empty() -> void:
	for col in range(grid_cols):
		for row in range(grid_rows):
			if _grid[col][row] == null:
				_grid[col][row] = _make_grid_data()
				var b := _create_bubble(col, row, _grid[col][row])
				b.position = _grid_to_world(col, row) + Vector2(0, -60)
				_bubble_nodes[col][row] = b
				var tw := create_tween()
				tw.tween_property(b, "position", _grid_to_world(col, row), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
