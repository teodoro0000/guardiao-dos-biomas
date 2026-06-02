extends Node

const TRACKS := {
	"menu":   "res://audio/music/Cyberpunk Moonlight Sonata v2.mp3",
	"forest": "res://audio/music/soundtracklegends-80s-retro-gaming-through-the-dark-forest-411472.mp3",
	"tropic": "res://audio/music/monument_music-cruising-down-8bit-lane-159615.mp3",
	"energy": "res://audio/music/brutaldesign-retro_space-464883.mp3",
	"final":  "res://audio/music/alperomeresin-the-final-boss-battle-158700.mp3",
}

const FADE_DURATION := 0.8
const TARGET_VOLUME_DB := -8.0
const MUTED_DB := -80.0

var _player_a: AudioStreamPlayer
var _player_b: AudioStreamPlayer
var _active: AudioStreamPlayer
var _current_key: String = ""

func _ready() -> void:
	_player_a = _make_player("MusicA")
	_player_b = _make_player("MusicB")
	_active = _player_a

func _make_player(p_name: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.name = p_name
	p.bus = "Master"
	p.volume_db = MUTED_DB
	p.autoplay = false
	add_child(p)
	return p

func play(key: String) -> void:
	if key == _current_key and _active.playing:
		return
	if not TRACKS.has(key):
		return
	var path: String = TRACKS[key]
	if not ResourceLoader.exists(path):
		_current_key = key
		return
	var stream := load(path) as AudioStream
	if stream == null:
		return
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	elif stream is AudioStreamMP3:
		stream.loop = true
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	var next: AudioStreamPlayer = _player_b if _active == _player_a else _player_a
	next.stream = stream
	next.volume_db = MUTED_DB
	next.play()
	_crossfade(_active, next)
	_active = next
	_current_key = key

func stop() -> void:
	var t := create_tween()
	t.tween_property(_active, "volume_db", MUTED_DB, FADE_DURATION)
	t.tween_callback(_active.stop)
	_current_key = ""

func _crossfade(from: AudioStreamPlayer, to: AudioStreamPlayer) -> void:
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(to, "volume_db", TARGET_VOLUME_DB, FADE_DURATION)
	if from.playing:
		t.tween_property(from, "volume_db", MUTED_DB, FADE_DURATION)
		t.chain().tween_callback(from.stop)
