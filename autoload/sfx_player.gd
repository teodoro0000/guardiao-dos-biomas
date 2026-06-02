extends Node

const SFX := {
	"jump":        "res://audio/sfx/jump.wav",
	"double_jump": "res://audio/sfx/synth.wav",
	"pickup":      "res://audio/sfx/powerUp.wav",
	"deposit":     "res://audio/sfx/blipSelect.wav",
	"hurt":        "res://audio/sfx/hitHurt.wav",
	"death":       "res://audio/sfx/explosion.wav",
	"restart":     "res://audio/sfx/click.wav",
	"victory":     "res://audio/sfx/powerUp.wav",
	"boss_hit":    "res://audio/sfx/hitHurt.wav",
	"boss_defeat": "res://audio/sfx/explosion.wav",
	"attack":      "res://audio/sfx/synth.wav",
}

const POOL_SIZE := 6
const DEFAULT_VOLUME_DB := -6.0

var _pool: Array[AudioStreamPlayer] = []
var _stream_cache: Dictionary = {}

func _ready() -> void:
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.name = "SfxPlayer%d" % i
		p.bus = "Master"
		p.volume_db = DEFAULT_VOLUME_DB
		add_child(p)
		_pool.append(p)

func play(key: String, volume_db: float = DEFAULT_VOLUME_DB) -> void:
	var stream := _load_stream(key)
	if stream == null:
		return
	var player := _pick_free_player()
	player.stream = stream
	player.volume_db = volume_db
	player.play()

func _load_stream(key: String) -> AudioStream:
	if _stream_cache.has(key):
		return _stream_cache[key]
	if not SFX.has(key):
		return null
	var path: String = SFX[key]
	if not ResourceLoader.exists(path):
		_stream_cache[key] = null
		return null
	var stream := load(path) as AudioStream
	_stream_cache[key] = stream
	return stream

func _pick_free_player() -> AudioStreamPlayer:
	for p in _pool:
		if not p.playing:
			return p
	# All busy — reuse first (interrupt oldest).
	return _pool[0]
