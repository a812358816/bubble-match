extends Node

## 代码合成音效，按消除数量分层

const RATE := 44100


func _gen_wav(samples: PackedFloat32Array) -> AudioStreamWAV:
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = RATE
	s.stereo = false
	var b := PackedByteArray()
	for v in samples:
		v = clampf(v, -1.0, 1.0)
		var i := int(v * 32767)
		b.append(i & 0xFF)
		b.append((i >> 8) & 0xFF)
	s.data = b
	return s


func _play(samples: PackedFloat32Array) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = _gen_wav(samples)
	p.finished.connect(p.queue_free)
	add_child(p)
	p.play()


# ── 消除音效（按数量分层）──

func play_pop(count: int) -> void:
	match count:
		3: _play(_pop_small())
		4, 5: _play(_pop_medium())
		_: _play(_pop_big())


func _pop_small() -> PackedFloat32Array:
	# 轻快单音啵：高音弯低
	var s := _tone(800.0, 0.07, 0.45, 800.0, 500.0)
	return _env(s, 0.003, 0.067)


func _pop_medium() -> PackedFloat32Array:
	# 双音叠加 + 泛音
	var base := _tone(650.0, 0.12, 0.5, 650.0, 380.0)
	base = _env(base, 0.005, 0.115)

	var harm := _tone(1300.0, 0.08, 0.2, 1300.0, 950.0)
	harm = _env(harm, 0.003, 0.077)

	var click := _noise_burst(0.03, 0.25)
	return _lay(_lay(base, harm), click)


func _pop_big() -> PackedFloat32Array:
	# 多层：低音 + 基音 + 泛音 + 闪烁高音 + 噪声
	var low := _tone(400.0, 0.18, 0.35, 400.0, 200.0)
	low = _env(low, 0.008, 0.172)

	var base := _tone(700.0, 0.15, 0.45, 700.0, 350.0)
	base = _env(base, 0.005, 0.145)

	var harm := _tone(1400.0, 0.10, 0.25, 1400.0, 900.0)
	harm = _env(harm, 0.004, 0.096)

	var sparkle := _tone(2400.0, 0.12, 0.12, 2400.0, 3200.0)
	sparkle = _trem(sparkle, 60.0)
	sparkle = _env(sparkle, 0.03, 0.09)

	var noise := _noise_burst(0.04, 0.2)

	return _lay(_lay(_lay(_lay(low, base), harm), sparkle), noise)


# ── 不够3个 ──

func play_invalid() -> void:
	var s1 := _tone(280.0, 0.1, 0.3, 280.0, 220.0)
	s1 = _env(s1, 0.005, 0.095)

	var s2 := _tone(240.0, 0.1, 0.3, 240.0, 190.0)
	s2 = _env(s2, 0.005, 0.095)

	_play(_seq([s1, s2], 120))


# ── 按钮 ──

func play_click() -> void:
	var s := _tone(1200.0, 0.012, 0.35)
	s = _env(s, 0.001, 0.011)
	_play(s)


# ── 游戏结束 ──

func play_game_over() -> void:
	var notes := [523.0, 659.0, 784.0, 1047.0]  # C E G C 上行
	var parts: Array[PackedFloat32Array] = []
	for i in notes.size():
		var t := _tone(notes[i], 0.2, 0.3, notes[i], notes[i] * 1.05)
		t = _env(t, 0.01, 0.15)
		parts.append(t)

	var chord := _seq(parts, 200)
	# 末尾加铃声
	var ring := _tone(1400.0, 0.6, 0.1)
	ring = _env(ring, 0.05, 0.5)
	ring = _trem(ring, 20.0)
	chord = _lay(chord, _pad_silence(ring, parts.size() * 200))
	_play(chord)


# ── 声音原语 ──

func _tone(freq: float, dur: float, amp: float, from_freq := 0.0, to_freq := 0.0) -> PackedFloat32Array:
	## 生成带弯音的正弦波。from_freq/to_freq 为 0 则不弯音
	var n := int(RATE * dur)
	var a := PackedFloat32Array()
	a.resize(n)
	var phase: float = 0.0
	var f0 := from_freq if from_freq > 0.0 else freq
	var f1 := to_freq if to_freq > 0.0 else freq
	for i in n:
		var r := float(i) / float(n - 1) if n > 1 else 0.0
		var f := f0 + (f1 - f0) * r
		phase += f / RATE
		var v := sin(2.0 * PI * phase)
		v += _tri(phase * 2.0) * 0.15
		a[i] = v * amp
	return a


func _tri(phase: float) -> float:
	var p := fmod(phase / TAU, 1.0)
	return 4.0 * abs(p - 0.5) - 1.0


func _env(s: PackedFloat32Array, attack: float, release: float) -> PackedFloat32Array:
	var n := s.size()
	var a_n := mini(int(RATE * attack), n)
	var r_start := maxi(n - int(RATE * release), 0)
	for i in n:
		if i < a_n:
			s[i] *= float(i) / float(a_n)
		elif i >= r_start and r_start < n:
			var rr := float(i - r_start) / float(n - r_start)
			s[i] *= maxf(1.0 - rr, 0.0)
	return s


func _noise_burst(dur: float, amp: float) -> PackedFloat32Array:
	var n := int(RATE * dur)
	var a := PackedFloat32Array()
	a.resize(n)
	for i in n:
		a[i] = (randf() * 2.0 - 1.0) * amp * (1.0 - float(i) / float(n))
	return a


func _trem(s: PackedFloat32Array, rate: float) -> PackedFloat32Array:
	for i in s.size():
		var t := float(i) / RATE
		s[i] *= 0.5 + 0.5 * sin(2.0 * PI * rate * t)
	return s


func _lay(a: PackedFloat32Array, b: PackedFloat32Array) -> PackedFloat32Array:
	var n := maxi(a.size(), b.size())
	var out := PackedFloat32Array()
	out.resize(n)
	for i in n:
		var va := a[i] if i < a.size() else 0.0
		var vb := b[i] if i < b.size() else 0.0
		out[i] = clampf(va + vb, -1.0, 1.0)
	return out


func _seq(parts: Array, gap: int) -> PackedFloat32Array:
	var total := 0
	for p in parts:
		total += p.size() + gap
	total -= gap
	var out := PackedFloat32Array()
	out.resize(total)
	var pos := 0
	for p in parts:
		for i in p.size():
			if pos + i < total:
				out[pos + i] += p[i]
		pos += p.size() + gap
	return out


func _pad_silence(s: PackedFloat32Array, n: int) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(n + s.size())
	for i in s.size():
		out[n + i] = s[i]
	return out
