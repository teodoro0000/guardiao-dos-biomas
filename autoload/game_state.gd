extends Node

signal collectible_picked(level_id: String, total: int, target: int)
signal level_completed(level_id: String)
signal lives_changed(lives: int)
signal combo_timer_changed(remaining: float, max_seconds: float)
signal combo_expired(level_id: String)
signal boss_hp_changed(level_id: String, current: int, max: int)
signal boss_defeated(level_id: String)

const PIXEL_FONT_PATH := "res://fonts/PressStart2P-Regular.ttf"
var pixel_font = null

const STARTING_LIVES := 3
var lives: int = STARTING_LIVES

const PORTRAIT_ATLAS_PATH := "res://kenney_pixel-platformer/Tilemap/tilemap-characters_packed.png"
const PIXEL_ADVENTURE_BASE := "res://sprites/Main Characters/"

const CHARACTERS := {
	"mata": {
		"display_name": "Mata",
		"tagline": "Guardiã da Mata Atlântica",
		"description": "Altura do pulo +25%",
		"accent_color": Color(0.40, 0.92, 0.62, 1.0),
		"modifiers": {"jump_velocity_mul": 1.25},
		"portrait_region": Rect2(0, 0, 24, 24),
		"bioma": "Floresta tropical · ODS 15",
		"sprite_folder": "Ninja Frog"
	},
	"mare": {
		"display_name": "Maré",
		"tagline": "Guardião do Manguezal",
		"description": "Velocidade horizontal +30%",
		"accent_color": Color(0.46, 0.80, 1.00, 1.0),
		"modifiers": {"max_speed_mul": 1.30},
		"portrait_region": Rect2(96, 0, 24, 24),
		"bioma": "Oceano e costa · ODS 14",
		"sprite_folder": "Virtual Guy"
	},
	"solis": {
		"display_name": "Solis",
		"tagline": "Guardiã do Cerrado",
		"description": "Raio de coleta 2×",
		"accent_color": Color(1.00, 0.78, 0.40, 1.0),
		"modifiers": {"collect_radius_mul": 2.0},
		"portrait_region": Rect2(48, 0, 24, 24),
		"bioma": "Sol e energia · ODS 7",
		"sprite_folder": "Mask Dude"
	},
	"raiz": {
		"display_name": "Raíz",
		"tagline": "Guardião da Caatinga",
		"description": "Começa com 1 vida extra",
		"accent_color": Color(1.00, 0.52, 0.42, 1.0),
		"modifiers": {"extra_lives": 1},
		"portrait_region": Rect2(24, 0, 24, 24),
		"bioma": "Sertão resistente · ODS 13",
		"sprite_folder": "Pink Man"
	}
}

const CHARACTER_ORDER := ["mata", "mare", "solis", "raiz"]
var selected_character: String = "mata"

func get_character_modifier(key: String, default_value):
	var mods = CHARACTERS.get(selected_character, {}).get("modifiers", {})
	return mods.get(key, default_value)

func get_character_data() -> Dictionary:
	return CHARACTERS.get(selected_character, {})

var _portrait_atlas: Texture2D = null
var _sprite_frames_cache: Dictionary = {}
var _portrait_cache: Dictionary = {}

const ANIM_SPECS := [
	{"name": "idle",     "file": "Idle (32x32).png",        "frames": 11, "speed": 12.0, "loop": true},
	{"name": "walk",     "file": "Run (32x32).png",         "frames": 12, "speed": 14.0, "loop": true},
	{"name": "jump",     "file": "Jump (32x32).png",        "frames": 1,  "speed": 5.0,  "loop": false},
	{"name": "fall",     "file": "Fall (32x32).png",        "frames": 1,  "speed": 5.0,  "loop": false},
	{"name": "hurt",     "file": "Hit (32x32).png",         "frames": 7,  "speed": 8.0,  "loop": false},
	{"name": "wall",     "file": "Wall Jump (32x32).png",   "frames": 5,  "speed": 10.0, "loop": true},
	{"name": "duck",     "file": "Idle (32x32).png",        "frames": 11, "speed": 6.0,  "loop": true},
	{"name": "slide",    "file": "Run (32x32).png",         "frames": 12, "speed": 18.0, "loop": true},
	{"name": "swimming", "file": "Fall (32x32).png",        "frames": 1,  "speed": 5.0,  "loop": true},
]

func get_character_sprite_frames(character_id: String) -> SpriteFrames:
	if _sprite_frames_cache.has(character_id):
		return _sprite_frames_cache[character_id]
	var data: Dictionary = CHARACTERS.get(character_id, {})
	var folder: String = data.get("sprite_folder", "")
	if folder == "":
		return null
	var base: String = PIXEL_ADVENTURE_BASE + folder + "/"
	var sf := SpriteFrames.new()
	for spec in ANIM_SPECS:
		var path: String = base + spec["file"]
		if not ResourceLoader.exists(path):
			continue
		var sheet: Texture2D = load(path) as Texture2D
		if sheet == null:
			continue
		sf.add_animation(spec["name"])
		sf.set_animation_speed(spec["name"], spec["speed"])
		sf.set_animation_loop(spec["name"], spec["loop"])
		for i in range(spec["frames"]):
			var atlas := AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = Rect2(i * 32, 0, 32, 32)
			atlas.filter_clip = true
			sf.add_frame(spec["name"], atlas)
	# SpriteFrames is created with a default "default" animation. Remove it.
	if sf.has_animation("default"):
		sf.remove_animation("default")
	_sprite_frames_cache[character_id] = sf
	return sf

func get_character_portrait(character_id: String) -> Texture2D:
	if _portrait_cache.has(character_id):
		return _portrait_cache[character_id]
	var data: Dictionary = CHARACTERS.get(character_id, {})
	var folder: String = data.get("sprite_folder", "")
	if folder == "":
		return null
	var idle_path: String = PIXEL_ADVENTURE_BASE + folder + "/Idle (32x32).png"
	if not ResourceLoader.exists(idle_path):
		return null
	var sheet: Texture2D = load(idle_path)
	if sheet == null:
		return null
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	atlas.region = Rect2(0, 0, 32, 32)
	atlas.filter_clip = true
	_portrait_cache[character_id] = atlas
	return atlas

const LEVELS := {
	"forest": {
		"display_name": "Floresta Ancestral",
		"ods_number": 15,
		"ods_name": "Vida Terrestre",
		"collectible_label": "Sementes",
		"collectible_target": 5,
		"combo_seconds": 10.0,
		"next_level": "tropic",
		"fact_1": "Florestas cobrem 31% da Terra e abrigam 80% das espécies terrestres.",
		"fact_2": "A cada minuto, o planeta perde área florestal equivalente a 27 campos de futebol.",
		"action": "Plante uma árvore nativa. Reduza consumo de papel. Apoie áreas protegidas."
	},
	"tropic": {
		"display_name": "Oceano Profundo",
		"ods_number": 14,
		"ods_name": "Vida na Água  ·  Reciclagem",
		"collectible_label": "Reciclados",
		"collectible_target": 5,
		"combo_seconds": 8.0,
		"next_level": "energy",
		"fact_1": "11 milhões de toneladas de plástico chegam ao oceano todo ano — e cada tipo de resíduo precisa de uma destinação correta.",
		"fact_2": "Reciclar 1 garrafa de vidro economiza energia suficiente pra acender uma lâmpada por 4 horas.",
		"action": "Separe seu lixo em casa. Plástico, vidro e orgânico têm coletas diferentes. Pesquise a coleta da sua cidade."
	},
	"energy": {
		"display_name": "Cidade do Amanhã",
		"ods_number": 7,
		"ods_name": "Energia Limpa e Acessível",
		"collectible_label": "Baterias solares",
		"collectible_target": 5,
		"combo_seconds": 6.0,
		"next_level": "final",
		"fact_1": "Quase 700 milhões de pessoas ainda vivem sem acesso à eletricidade.",
		"fact_2": "Energia limpa representa hoje 30% da matriz elétrica mundial — em crescimento.",
		"action": "Economize energia. Apoie políticas de transição energética."
	},
	"final": {
		"display_name": "Coração do Mundo",
		"ods_number": 13,
		"ods_name": "Ação Climática",
		"collectible_label": "",
		"collectible_target": 0,
		"combo_seconds": 0.0,
		"next_level": "",
		"fact_1": "A crise climática é a soma de todos os outros desafios — exige ação coletiva.",
		"fact_2": "Cada Guardião de cada bioma encara o mesmo inimigo final: a indiferença.",
		"action": "Aja todo dia. Pequeno gesto multiplicado é movimento."
	}
}

const LEVEL_ORDER := ["forest", "tropic", "energy"]

var current_level_id: String = ""
var collected_by_level: Dictionary = {}
var levels_completed: Dictionary = {}
var boss_defeated_by_level: Dictionary = {}
var checkpoint_positions: Dictionary = {}

var _combo_max: float = 0.0
var _combo_remaining: float = 0.0
var _combo_active: bool = false

func _ready() -> void:
	_load_pixel_font()
	for level_id in LEVELS:
		collected_by_level[level_id] = 0
		levels_completed[level_id] = false
		boss_defeated_by_level[level_id] = false

func _load_pixel_font() -> void:
	if not ResourceLoader.exists(PIXEL_FONT_PATH):
		return
	pixel_font = load(PIXEL_FONT_PATH)

func apply_pixel_font(root: Node) -> void:
	if pixel_font == null:
		return
	for node in root.find_children("*", "Label", true, false):
		node.add_theme_font_override("font", pixel_font)
	for node in root.find_children("*", "Button", true, false):
		node.add_theme_font_override("font", pixel_font)
	# Theme override happens after _ready — containers already laid out with
	# the default font's smaller metrics. Force a re-sort so the bigger pixel
	# glyphs don't overlap.
	for node in root.find_children("*", "Container", true, false):
		(node as Container).queue_sort()

func enter_level(level_id: String) -> void:
	current_level_id = level_id
	collected_by_level[level_id] = 0
	_combo_max = float(LEVELS.get(level_id, {}).get("combo_seconds", 0.0))
	_combo_remaining = _combo_max
	_combo_active = false
	combo_timer_changed.emit(_combo_remaining, _combo_max)

func get_level_data(level_id: String) -> Dictionary:
	return LEVELS.get(level_id, {})

func get_current_level_data() -> Dictionary:
	return get_level_data(current_level_id)

func collect(level_id: String) -> void:
	collected_by_level[level_id] = collected_by_level.get(level_id, 0) + 1
	var target: int = LEVELS[level_id]["collectible_target"]
	collectible_picked.emit(level_id, collected_by_level[level_id], target)
	if _combo_max > 0.0:
		_combo_remaining = _combo_max
		_combo_active = true
		combo_timer_changed.emit(_combo_remaining, _combo_max)

func _process(delta: float) -> void:
	if not _combo_active or _combo_max <= 0.0 or current_level_id == "":
		return
	_combo_remaining = max(0.0, _combo_remaining - delta)
	combo_timer_changed.emit(_combo_remaining, _combo_max)
	if _combo_remaining <= 0.0:
		_combo_active = false
		combo_expired.emit(current_level_id)
		if not lose_life():
			go_to_game_over()

func get_collected(level_id: String) -> int:
	return collected_by_level.get(level_id, 0)

func get_target(level_id: String) -> int:
	return LEVELS.get(level_id, {}).get("collectible_target", 0)

func complete_level(level_id: String) -> void:
	levels_completed[level_id] = true
	_combo_active = false
	_combo_remaining = 0.0
	clear_checkpoint(level_id)
	level_completed.emit(level_id)

func is_completed(level_id: String) -> bool:
	return levels_completed.get(level_id, false)

func get_next_level(level_id: String) -> String:
	return LEVELS.get(level_id, {}).get("next_level", "")

func reset_all() -> void:
	for level_id in LEVELS:
		collected_by_level[level_id] = 0
		levels_completed[level_id] = false
		boss_defeated_by_level[level_id] = false
	checkpoint_positions.clear()
	current_level_id = ""
	lives = STARTING_LIVES + int(get_character_modifier("extra_lives", 0))
	lives_changed.emit(lives)

func set_checkpoint(level_id: String, pos: Vector2) -> void:
	checkpoint_positions[level_id] = pos

func has_checkpoint(level_id: String) -> bool:
	return checkpoint_positions.has(level_id)

func get_checkpoint(level_id: String) -> Vector2:
	return checkpoint_positions.get(level_id, Vector2.ZERO)

func clear_checkpoint(level_id: String) -> void:
	checkpoint_positions.erase(level_id)

func is_boss_defeated(level_id: String) -> bool:
	return boss_defeated_by_level.get(level_id, false)

func defeat_boss(level_id: String) -> void:
	boss_defeated_by_level[level_id] = true
	boss_defeated.emit(level_id)

func report_boss_hp(level_id: String, current: int, max_hp: int) -> void:
	boss_hp_changed.emit(level_id, current, max_hp)

func lose_life() -> bool:
	lives -= 1
	lives_changed.emit(lives)
	return lives > 0

func reload_current_level() -> void:
	get_tree().reload_current_scene()

func go_to_game_over() -> void:
	go_to_scene("res://ui/game_over.tscn")

func go_to_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)

func go_to_main_menu() -> void:
	go_to_scene("res://ui/main_menu.tscn")

func go_to_character_select() -> void:
	go_to_scene("res://ui/character_select.tscn")

func go_to_level_select() -> void:
	go_to_scene("res://ui/level_select.tscn")

func go_to_level(level_id: String) -> void:
	enter_level(level_id)
	go_to_scene("res://scene/" + level_id + ".tscn")

func select_character(character_id: String) -> void:
	if CHARACTERS.has(character_id):
		selected_character = character_id
		lives = STARTING_LIVES + int(get_character_modifier("extra_lives", 0))
		lives_changed.emit(lives)

func go_to_ods_message(level_id: String) -> void:
	current_level_id = level_id
	go_to_scene("res://ui/ods_message.tscn")

func go_to_credits() -> void:
	current_level_id = ""
	_combo_active = false
	_combo_remaining = 0.0
	go_to_scene("res://ui/credits.tscn")

func go_to_victory() -> void:
	current_level_id = ""
	_combo_active = false
	_combo_remaining = 0.0
	go_to_scene("res://ui/victory.tscn")

func play_sfx(key: String, vol_db: float = -6.0) -> void:
	var sfx := get_node_or_null("/root/SfxPlayer")
	if sfx == null:
		return
	if sfx.has_method("play"):
		sfx.play(key, vol_db)
