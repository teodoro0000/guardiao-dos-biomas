# Handoff — Guardião dos Biomas

**Última sessão:** 2026-06-02 (Dia do Meio Ambiente, dia do evento Fatec Jacareí)
**Estado:** Pronto pra apresentação. Todas as features pedidas implementadas.

---

## 🎯 Status atual do projeto

O jogo está **end-to-end funcional**:

```
Main Menu → Character Select → Level Select →
  Forest (boss Ogre) → ods_message →
    Tropic (boss Big Zombie) → ods_message →
      Energy (boss Big Demon) → ods_message →
        Final (Super Boss Enemy3) → Victory (baú+moedas) → Credits
```

Game over flow funcional (vidas zeram → game_over.tscn → retry recarrega fase ou volta menu).

## ✅ O que foi implementado (sessão de 02-jun-2026)

### Gameplay
- **4 Guardiões** (Mata/Maré/Solis/Raíz) com poderes mecânicos distintos, mapeados a personagens Pixel Adventure
- **Player projétil** (X/J lança sementes) com cooldown 0.35s — `entities/player_projectile.tscn`
- **Boss em cada fase** (3 bosses regulares animados 0x72: Ogre/Big Zombie/Big Demon)
- **Super boss voador** com smash attack — `entities/boss_super.tscn` (Enemy3 cogumelo)
- **Checkpoints** (bandeiras coloridas) — `entities/checkpoint.tscn`, salva position no GameState
- **Life pickup** (♥) — `entities/life_pickup.tscn`, +1 vida cap em 5
- **Sistema SFX completo** — `autoload/sfx_player.gd` com pool de 6 players, 11 chaves mapeadas
- **Música** — 5 tracks (uma por contexto: menu, 3 fases, boss final)

### UI / Telas
- **Main menu** com 4 portraits dinâmicos dos Pixel Adventure
- **Character select** com card por guardião + bioma info
- **HUD** com vidas/ODS/coletáveis/combo bar
- **ODS message** entre fases com fato real + ação sugerida
- **Victory screen** (`ui/victory.tscn`) com baú dourado + moedas saltando + "JOGAR DE NOVO"
- **Credits** (`ui/credits.tscn`) com mensagem ODS + créditos completos

### Assets
- Personagens: `sprites/Main Characters/` (Pixel Adventure — 4 personagens × 7 anims)
- Inimigos/bosses: `sprites/0x72_DungeonTilesetii_v1.7/frames/` (muddy, slug, chort, ogre, big_zombie, big_demon)
- Super boss: `sprites/Enemy3/Enemy3-No-Movement-In-Animation/` (7 anims 64x64)
- Lixeiras + sementes: `sprites/Items/` (Flaticon)
- Portal: `sprites/Main Characters/Appearing (96x96).png` (7 frames pixel art)
- Música: `audio/music/` (5 mp3s)
- SFX: `audio/sfx/` (7 wavs sfxr)

### Documentos
- `README.md` — completo com equipe, controles, build instructions
- `LICENSE` — MIT atualizada com a equipe + crédito Rafael Forbeck
- `PRESENTATION.md` — roteiro detalhado de 14 slides com notas
- `Apresentacao.pptx` — **gerado via python-pptx**, 14 slides 16:9 dark theme, pronto pra apresentar
- `build_presentation.py` — script Python pra regenerar o pptx
- Este handoff

---

## 👥 Equipe

- Alicia Silva Dias
- Gabrielly Neu dos Santos
- Manuela Lucia Lemes de Castro
- Pedro Claudino Nunes
- Gabriel Teodoro (CTO/programação principal)

Fatec Jacareí · DSM · Curso de Desenvolvimento de Software Multiplataforma

---

## 🗂️ Arquitetura — onde está cada coisa

```
guardiao-dos-biomas/              (renomear de Godot-2025-Plataforma-2D-YouTube)
├── audio/
│   ├── music/                    5 mp3s mapeados no music_player.gd
│   └── sfx/                      7 wavs sfxr mapeados no sfx_player.gd
├── autoload/                     3 singletons globais
│   ├── game_state.gd             ★ heart — CHARACTERS, LEVELS, lives, checkpoints, sfx wrapper
│   ├── music_player.gd           crossfade entre tracks
│   └── sfx_player.gd             pool de 6 AudioStreamPlayers
├── entities/                     prefabs reutilizáveis
│   ├── player.tscn               com sprite_frames substituído em runtime
│   ├── boss.tscn                 chefes regulares (escalado 1.5×)
│   ├── boss_super.tscn           super boss voador final
│   ├── skeleton.tscn             mobs comuns (sprite tunable via export)
│   ├── checkpoint.tscn           bandeira 0x72
│   ├── life_pickup.tscn          coração ♥
│   ├── player_projectile.tscn    semente do ataque do player
│   ├── trash_bin.tscn            lixeira do tropic
│   ├── trash_item.tscn           item de lixo do tropic
│   ├── collectible.tscn          sementes/baterias (por fase)
│   ├── moving_platform.tscn      plataformas tropic + energy
│   ├── camera.tscn               câmera 2D shared
│   ├── level_end.tscn            portal Pixel Adventure animado
│   └── spinning_bone.tscn        projétil do skeleton
├── scene/                        4 fases
│   ├── forest.tscn               ODS 15 — tilemap, parallax 6 camadas
│   ├── tropic.tscn               ODS 14 — vertical com água
│   ├── energy.tscn               ODS 7 — cidade noturna (300+ nodes)
│   ├── final.tscn                ODS 13 — arena boss final
│   └── game.tscn                 sandbox legado (ignorar)
├── scripts/                      lógica GDScript
├── sprites/                      todos os assets de imagem
├── tiles/                        TileSet resources Godot
├── ui/                           main_menu, character_select, hud, ods_message, game_over, credits, victory
├── fonts/                        Press Start 2P + Intel Mono
├── kenney_*/                     packs Kenney (platformer, pixel-platformer, game-icons)
├── project.godot                 4 autoloads + 5 input actions
├── README.md
├── LICENSE
├── PRESENTATION.md               roteiro markdown
├── build_presentation.py         gera Apresentacao.pptx
├── Apresentacao.pptx             ← entregável pro evento
└── project-handoff-next-session.md   ← este arquivo
```

## 🎮 Controles

| Ação | Tecla |
|---|---|
| Andar | A/D ou ←/→ |
| Pular / Pulo duplo | W / ↑ / Espaço |
| Agachar / Deslizar | S / ↓ |
| Atacar (lançar semente) | X ou J |
| Voltar pro menu | Esc |

---

## ⚠️ Pendências e atenção

### Git
- **149 arquivos modificados/novos** ainda não commitados
- Quando criar repo novo no GitHub:
  ```bash
  git remote remove origin    # remove repo do tutorial Rafael Forbeck
  git add .
  git commit -m "feat: Guardião dos Biomas v1 - apresentação Fatec"
  git remote add origin https://github.com/<user>/guardiao-dos-biomas.git
  git push -u origin main
  ```

### Pasta
- Renomear de `Godot-2025-Plataforma-2D-YouTube` → **`guardiao-dos-biomas`** ANTES de subir
- Feche o Godot antes de renomear

### Apresentação .pptx
- 14 slides gerados em `Apresentacao.pptx`
- **Falta adicionar manualmente:**
  - Screenshots in-game (capturar do Godot via Print Screen ou Project → Export → Screenshot)
  - Logo Fatec no slide 1
  - Sprites dos personagens nos círculos do slide 4
  - Fotos reais da equipe no slide 12 (substituir os placeholders "A/G/M/P/G")
  - QR code do GitHub no slide 14 (gera em qr-code-generator.com)
- Pra regenerar o pptx do zero: `py build_presentation.py`

### Build .exe
- Setup uma vez: Godot → Editor → Manage Export Templates → Download (~600 MB)
- Project → Export... → Add Windows Desktop → ✅ Embed PCK → Export Project
- Resultado: arquivo `.exe` único (~60-80 MB), roda em qualquer PC sem instalar Godot

### Possíveis ajustes pós-evento
- **Boss visual:** sprite 32×36 com scale 1.5× pode clipar 3px no chão (cosmético, não afeta gameplay)
- **Tropic:** checkpoint anterior em Y=175 estava parcialmente submerso na água — corrigido pra Y=176 mas pode precisar fine-tune
- **Energy:** plataformas usam floor_1.png tintado azul (workaround sem tileset "city futurístico" real)
- **HUD:** mostra "DERROTE O CHEFE" na final (não mostra contagem de coletáveis, OK)

---

## 🔧 Como retomar o trabalho

1. **Abrir o projeto:** Godot 4.6 → Import → seleciona `project.godot`
2. **Rodar:** F5 (cena principal = `ui/main_menu.tscn`)
3. **Ver tasks abertas:** seção "Próximas evoluções" abaixo
4. **Memória:** `~/.claude/projects/.../memory/` tem `project_pivot_ods.md` com contexto do pivô

---

## 🚀 Próximas evoluções (backlog informal)

### Polimento visual
- Adicionar sprite real pro chão da Forest e Tropic (já tem tilemap, pode melhorar parallax)
- Particles ao matar inimigo (smoke/poof)
- Screen shake no boss hit
- Hit flash branco no player ao tomar dano

### Conteúdo
- ODS 6 (Água Potável) e ODS 12 (Consumo Responsável) — 2 novas fases
- Modo cooperativo local (2 players no split screen ou shared screen)
- Tradução EN/ES via TranslationServer do Godot

### Acessibilidade
- Tela de configurações (volume música/sfx separado, fullscreen toggle)
- Remapeamento de teclas
- Tutorial primeira vez (overlay com controles)

### Engenharia
- Migrar `enemy_sprite_region` (Kenney) pro mesmo padrão de `external_frame_base` (consolidar API)
- Refatorar boss_super.gd: a state machine cresceu, daria pra extrair `BossPattern` class
- Adicionar smoke test em CI (Godot tem export headless) que carrega cada fase e verifica sem erros de parser

---

## 📚 Decisões técnicas notáveis

- **Pixel Adventure** (32×32) escolhido sobre **Seliel** (64×64) — menos risco de recalibração de fase
- **`GameState.play_sfx()` wrapper** em vez de `SfxPlayer.play()` direto — porque autoload pode não estar registrado durante compile de scripts irmãos. Bulletproof contra "Identifier not found" no startup
- **Sprite-frames dinâmicos** (player, boss, skeleton) — montados em runtime via `SpriteFrames.new()` e `AtlasTexture.new()`. Permite trocar visual sem editar `.tscn` por instância
- **Combo timer** reseta em `complete_level()` — evitou bug de game-over fantasma durante transição pra credits
- **Boss_super invulnerável** removido (`status != recover` gate) — UX feedback do user: stomp/projétil não respondia
- **Music silencioso na final** removido — agora toca "The Final Boss Battle" épico
- **Checkpoint** anchored no base do mastro (pole bottom = position Y) — facilita posicionar visualmente nas fases

---

**Mensagem final:** o projeto está pronto pra subir. Boa apresentação à equipe. 🌍
