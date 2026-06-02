# Trilha sonora — Guardião dos Biomas

Mapeamento atual (Incompetech, CC-BY — Kevin MacLeod, atribuir nos créditos):

| Cena | Arquivo | Faixa |
|---|---|---|
| `ui/main_menu.tscn` | `Pixelland.mp3` | menu calmo, pixel-platformer |
| `scene/forest.tscn` | `Wallpaper.mp3` | orgânico, aventureiro |
| `scene/tropic.tscn` | `Aquarium.mp3` | aquático, contemplativo |
| `scene/energy.tscn` | `Electrodoodle.mp3` | chiptune uplifting |

Godot 4 importa `.mp3` nativamente — sem necessidade de conversão. Loop é setado em runtime por `autoload/music_player.gd`. Se trocar de faixa, atualize a constante `TRACKS` lá.

**Atribuição obrigatória** (Kevin MacLeod / incompetech.com — Creative Commons BY 4.0): incluir crédito em uma tela de créditos ou no README do projeto final.
