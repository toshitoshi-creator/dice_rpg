class_name SoundManager
extends Node
## 効果音の再生窓口。
##
## res://assets/sounds/<name>.(ogg|wav|mp3) があればそれを再生する。
## ファイルがまだ無い場合は、簡単な合成音で代用する（エラーにはしない）。
## 使用する名前: dice_roll, dice_hit, attack, damage, critical, enemy_attack,
##               enemy_die, victory, defeat, button, step, powerup, special

const SOUND_DIR := "res://assets/sounds/"
const EXTENSIONS := ["ogg", "wav", "mp3"]
const MIX_RATE := 22050
const POOL_SIZE := 8

## false にすると、ファイルが無いときは無音になる
@export var use_synth_fallback := true

var _cache: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next := 0


func _ready() -> void:
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)


func play(sound_name: StringName, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	var stream := _get_stream(sound_name)
	if stream == null:
		return
	var p := _players[_next]
	_next = (_next + 1) % _players.size()
	p.stream = stream
	p.volume_db = volume_db
	p.pitch_scale = pitch
	p.play()


func _get_stream(sound_name: StringName) -> AudioStream:
	if _cache.has(sound_name):
		return _cache[sound_name]
	var stream: AudioStream = null
	for ext in EXTENSIONS:
		var path := "%s%s.%s" % [SOUND_DIR, sound_name, ext]
		if ResourceLoader.exists(path):
			stream = load(path) as AudioStream
			if stream:
				break
	if stream == null and use_synth_fallback:
		stream = _synthesize(sound_name)
	_cache[sound_name] = stream
	return stream


# ------------------------------------------------------------------
# 合成音（仮 SE）
# ------------------------------------------------------------------
func _synthesize(sound_name: StringName) -> AudioStreamWAV:
	match sound_name:
		&"dice_roll":
			return _make(0.25, func(t: float, _i: int) -> float:
				return (randf() * 2.0 - 1.0) * 0.35 * (1.0 - t / 0.25) * (0.5 + 0.5 * sin(t * 120.0)))
		&"dice_hit":
			return _make(0.08, func(t: float, _i: int) -> float:
				return ((randf() * 2.0 - 1.0) * 0.5 + sin(t * TAU * 180.0) * 0.5) * exp(-t * 60.0))
		&"attack":
			return _make(0.22, func(t: float, _i: int) -> float:
				return (randf() * 2.0 - 1.0) * 0.5 * sin(PI * t / 0.22) * (0.3 + t * 3.0))
		&"damage":
			return _make(0.25, func(t: float, _i: int) -> float:
				var tone := sin(t * TAU * lerpf(220.0, 60.0, t / 0.25)) * 0.7 * exp(-t * 10.0)
				return tone + (randf() * 2.0 - 1.0) * 0.3 * exp(-t * 25.0))
		&"critical":
			return _make(0.45, func(t: float, _i: int) -> float:
				var f := 660.0 if t < 0.12 else 990.0
				return (1.0 if sin(t * TAU * f) > 0.0 else -1.0) * 0.25 * exp(-t * 4.0))
		&"enemy_attack":
			return _make(0.3, func(t: float, _i: int) -> float:
				return sin(t * TAU * lerpf(120.0, 320.0, t / 0.3)) * 0.5 * (1.0 - t / 0.3))
		&"enemy_die":
			return _make(0.7, func(t: float, _i: int) -> float:
				return sin(t * TAU * lerpf(500.0, 80.0, t / 0.7)) * 0.5 * (1.0 - t / 0.7))
		&"victory":
			return _make(0.9, func(t: float, _i: int) -> float:
				var notes := [523.25, 659.25, 783.99, 1046.5]
				var idx := mini(int(t / 0.18), notes.size() - 1)
				var local_t := t - idx * 0.18
				return (1.0 if sin(t * TAU * notes[idx]) > 0.0 else -1.0) * 0.18 * exp(-local_t * 3.0))
		&"defeat":
			return _make(1.0, func(t: float, _i: int) -> float:
				var notes := [392.0, 349.23, 311.13, 261.63]
				var idx := mini(int(t / 0.25), notes.size() - 1)
				return sin(t * TAU * notes[idx]) * 0.35 * (1.0 - t))
		&"powerup":
			return _make(0.6, func(t: float, _i: int) -> float:
				var f := lerpf(200.0, 900.0, t / 0.6)
				return (sin(t * TAU * f) * 0.4 + sin(t * TAU * f * 1.5) * 0.2) * minf(t * 8.0, 1.0) * (1.0 - t / 0.6))
		&"special":
			return _make(0.8, func(t: float, _i: int) -> float:
				var chord := sin(t * TAU * 523.25) + sin(t * TAU * 659.25) + sin(t * TAU * 783.99) + sin(t * TAU * 1046.5) * 0.6
				var hit := (randf() * 2.0 - 1.0) * exp(-t * 18.0)
				return (chord * 0.12 + hit * 0.5) * exp(-t * 2.2))
		&"step":
			return _make(0.07, func(t: float, _i: int) -> float:
				return ((randf() * 2.0 - 1.0) * 0.4 + sin(t * TAU * 90.0) * 0.6) * exp(-t * 55.0))
		&"button":
			return _make(0.06, func(t: float, _i: int) -> float:
				return sin(t * TAU * 880.0) * 0.3 * (1.0 - t / 0.06))
	return null


func _make(duration: float, generator: Callable) -> AudioStreamWAV:
	var count := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in count:
		var t := float(i) / MIX_RATE
		var v := clampf(float(generator.call(t, i)), -1.0, 1.0)
		data.encode_s16(i * 2, int(v * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = MIX_RATE
	wav.stereo = false
	wav.data = data
	return wav
