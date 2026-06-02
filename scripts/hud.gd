extends CanvasLayer

const COMBO_WARN_THRESHOLD := 0.30
const COLOR_OK := Color(0.40, 0.92, 0.62, 1.0)
const COLOR_WARN := Color(1.00, 0.78, 0.32, 1.0)
const COLOR_DANGER := Color(1.00, 0.34, 0.42, 1.0)

@onready var ods_label: Label = $Root/TopBar/HBox/OdsLabel
@onready var lives_label: Label = $Root/TopBar/HBox/LivesLabel
@onready var collectible_label: Label = $Root/TopBar/HBox/CollectibleLabel
@onready var collectible_count: Label = $Root/TopBar/HBox/CollectibleCount
@onready var combo_bar: ProgressBar = $Root/ComboBar

var _combo_fill: StyleBoxFlat = null

func _ready() -> void:
	GameState.collectible_picked.connect(_on_collectible_picked)
	GameState.lives_changed.connect(_on_lives_changed)
	GameState.combo_timer_changed.connect(_on_combo_timer_changed)
	GameState.combo_expired.connect(_on_combo_expired)
	# Duplicate the fill stylebox so per-frame color updates don't bleed across
	# any other ProgressBars sharing the scene's SubResource.
	var src := combo_bar.get_theme_stylebox("fill")
	if src != null:
		_combo_fill = src.duplicate() as StyleBoxFlat
		combo_bar.add_theme_stylebox_override("fill", _combo_fill)
	_refresh()

func _refresh() -> void:
	var data: Dictionary = GameState.get_current_level_data()
	if data.is_empty():
		return
	ods_label.text = "ODS %d" % data["ods_number"]
	var target: int = int(data.get("collectible_target", 0))
	if target <= 0:
		collectible_label.text = "DERROTE O CHEFE"
		collectible_count.text = ""
	else:
		collectible_label.text = data["collectible_label"]
		collectible_count.text = "%d/%d" % [GameState.get_collected(GameState.current_level_id), target]
	_render_lives(GameState.lives)

func _render_lives(n: int) -> void:
	lives_label.text = "♥".repeat(max(n, 0))

func _on_collectible_picked(_level_id: String, _total: int, _target: int) -> void:
	_refresh()
	var tween := create_tween()
	tween.tween_property(collectible_count, "scale", Vector2(1.3, 1.3), 0.08)
	tween.tween_property(collectible_count, "scale", Vector2(1.0, 1.0), 0.12)

func _on_lives_changed(n: int) -> void:
	_render_lives(n)
	var tween := create_tween()
	tween.tween_property(lives_label, "scale", Vector2(1.3, 1.3), 0.08)
	tween.tween_property(lives_label, "scale", Vector2(1.0, 1.0), 0.12)

func _on_combo_timer_changed(remaining: float, max_seconds: float) -> void:
	if max_seconds <= 0.0:
		combo_bar.modulate.a = 0.0
		return
	var ratio: float = clamp(remaining / max_seconds, 0.0, 1.0)
	combo_bar.value = ratio
	# Fade in only once the timer is actively counting (i.e. ratio < 1 or active).
	var target_alpha: float = 1.0 if ratio > 0.0 else 0.0
	if combo_bar.modulate.a != target_alpha:
		var fade := create_tween()
		fade.tween_property(combo_bar, "modulate:a", target_alpha, 0.25)
	var fill_color: Color = COLOR_OK
	if ratio <= COMBO_WARN_THRESHOLD:
		fill_color = COLOR_DANGER if ratio <= COMBO_WARN_THRESHOLD * 0.5 else COLOR_WARN
	if _combo_fill != null:
		_combo_fill.bg_color = fill_color

func _on_combo_expired(_level_id: String) -> void:
	var tween := create_tween()
	tween.tween_property(combo_bar, "modulate:a", 0.0, 0.35)
