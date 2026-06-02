extends RefCounted
class_name SpriteBank

const FRAMES := {
	"res://sprites/0x72_DungeonTilesetII_v1.7/frames/chort_idle_anim_f": [
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/chort_idle_anim_f0.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/chort_idle_anim_f1.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/chort_idle_anim_f2.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/chort_idle_anim_f3.png"),
	],
	"res://sprites/0x72_DungeonTilesetII_v1.7/frames/muddy_anim_f": [
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/muddy_anim_f0.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/muddy_anim_f1.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/muddy_anim_f2.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/muddy_anim_f3.png"),
	],
	"res://sprites/0x72_DungeonTilesetII_v1.7/frames/slug_anim_f": [
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/slug_anim_f0.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/slug_anim_f1.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/slug_anim_f2.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/slug_anim_f3.png"),
	],
	"res://sprites/0x72_DungeonTilesetII_v1.7/frames/big_demon_idle_anim_f": [
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/big_demon_idle_anim_f0.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/big_demon_idle_anim_f1.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/big_demon_idle_anim_f2.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/big_demon_idle_anim_f3.png"),
	],
	"res://sprites/0x72_DungeonTilesetII_v1.7/frames/big_zombie_idle_anim_f": [
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/big_zombie_idle_anim_f0.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/big_zombie_idle_anim_f1.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/big_zombie_idle_anim_f2.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/big_zombie_idle_anim_f3.png"),
	],
	"res://sprites/0x72_DungeonTilesetII_v1.7/frames/ogre_idle_anim_f": [
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/ogre_idle_anim_f0.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/ogre_idle_anim_f1.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/ogre_idle_anim_f2.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/ogre_idle_anim_f3.png"),
	],
	"res://sprites/0x72_DungeonTilesetII_v1.7/frames/big_demon_run_anim_f": [
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/big_demon_run_anim_f0.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/big_demon_run_anim_f1.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/big_demon_run_anim_f2.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/big_demon_run_anim_f3.png"),
	],
	"res://sprites/0x72_DungeonTilesetII_v1.7/frames/big_zombie_run_anim_f": [
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/big_zombie_run_anim_f0.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/big_zombie_run_anim_f1.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/big_zombie_run_anim_f2.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/big_zombie_run_anim_f3.png"),
	],
	"res://sprites/0x72_DungeonTilesetII_v1.7/frames/ogre_run_anim_f": [
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/ogre_run_anim_f0.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/ogre_run_anim_f1.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/ogre_run_anim_f2.png"),
		preload("res://sprites/0x72_DungeonTilesetII_v1.7/frames/ogre_run_anim_f3.png"),
	],
}

static func get_frames(base: String, count: int) -> Array[Texture2D]:
	var out: Array[Texture2D] = []
	if FRAMES.has(base):
		var arr: Array = FRAMES[base]
		for i in range(min(count, arr.size())):
			out.append(arr[i])
		return out
	# Fallback for paths not in the bank (editor-only behavior).
	for i in range(count):
		var path: String = "%s%d.png" % [base, i]
		if ResourceLoader.exists(path):
			var tex: Texture2D = load(path) as Texture2D
			if tex != null:
				out.append(tex)
	return out
