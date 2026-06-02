# Assets necessários — Game ODS "Guardião dos Biomas"

Você só troca arquivos de imagem. O código já está pronto e configurado.

---

## 1. Protagonista (jovem estudante)

**Onde salvar:** `sprites/1 - Penguin/` (mantém o nome da pasta — é referência fixa no `player.tscn`. Só troca os arquivos PNG.)

Cada arquivo é uma **spritesheet horizontal** de frames 16×16. Substitua os existentes mantendo o mesmo nome e a mesma quantidade de frames.

| Arquivo PNG | Animação | Frames mínimos |
|---|---|---|
| `Idle (16 x 16).png` | parado, respirando | 4 |
| `Waddling (16 x 16).png` | caminhando | 6 |
| `Jump (16 x 16).png` | salto subindo | 2 |
| `Falling (16 x 16).png` | caindo | 2 |
| `Ducking (16 x 16).png` | agachado | 2 |
| `Belly_Sliding (16 x 16).png` | deslizando no chão | 2 |
| `Swimming (16 x 16).png` | nadando | 4 |
| `Hurt (16 x 16).png` | tomando dano | 2 |
| `Wall_Slide (16x16).png` | escorregando na parede | 2 |

> Os arquivos `Looking_Off`, `Looking_Up`, `Sitting`, `Standing`, `Surprised`, `Victory_Dance`, `Wall_Grab`, `Lying_On_Ground`, `Blink` são extras que o sprite original tinha — só substitua se sua nova arte tiver equivalentes. Caso contrário, deixe os atuais (não serão usados em runtime).

**Onde achar:**
- Kenney "Platformer Characters" (kenney.nl/assets) — CC0
- CraftPix "Free Hero Pack" (craftpix.net/freebies)
- Retro Diffusion (IA) com seed fixa pra manter consistência entre animações

---

## 2. Inimigo (substitui o esqueleto)

**Onde salvar:** `sprites/3 - Skeleton/` (mantém o nome, troca PNGs)

Tema sugerido por fase:
- **Floresta** → desmatador com motosserra
- **Oceano** → poluidor de jet-ski / rede fantasma
- **Energia** → opcional (a fase Energy não usa inimigo no level atual)

Estrutura igual à do esqueleto: spritesheets 32×32 com animações `walk`, `attack`, `hurt`, `inactive`, `landed`, `standing`, `twitching_idle`, etc.

| Arquivo PNG (deve manter o nome) | Animação |
|---|---|
| `Standing_Idle (32 x 32).png` | parado |
| `Limping_Movement (32 x 32).png` | caminhando |
| `Bone_Toss (32 x 32).png` | atacando (jogando objeto) |
| `Hurt (32 x 32).png` | tomando dano |

E renomeie no contexto: ele joga galhos/lixo/sucata em vez de ossos — só visualmente, o código já é genérico.

Sprite do projétil: `sprites/3 - Skeleton/Spinning_Bone (16 x 16).png` — substitua por galho/garrafa/etc.

---

## 3. Coletáveis (sementes / lixo / baterias)

**Onde salvar:** crie a pasta `sprites/Collectibles/` (não obrigatório, mas organiza).

Por fase:
| Fase | ODS | Sprite (16×16, sem fundo) |
|---|---|---|
| `forest.tscn` | 15 | **Semente** ou broto |
| `tropic.tscn` | 14 | **Garrafa plástica** ou saco de lixo |
| `energy.tscn` | 7 | **Bateria** ou painel solar |

**Como aplicar:** abra cada fase no editor, selecione `Collectible1...Collectible5`, troque a `Texture` do `Sprite2D` por sua nova imagem. (Ou edite o `entities/collectible.tscn` pra fazer global — mas aí todas as fases usam o mesmo sprite. Recomendado: 1 sprite por fase via override.)

**Onde achar:**
- Kenney "Platformer Items" — pixel art 16×16 CC0
- game-icons.net (vetor) — exportar como PNG 16×16

---

## 4. Tilesets

Os tilesets atuais **já funcionam** pras fases:
- `forest.tscn` usa **Autumn Forest** (`sprites/Seasonal Tilesets/2 - Autumn Forest/`)
- `tropic.tscn` usa **Tropics** (`sprites/Seasonal Tilesets/3 - Tropics/`)
- `energy.tscn` **não usa tileset** — plataformas geométricas estilizadas (céu/cidade do amanhã)

**Opcionais (deixam ainda mais polido):**
- Substituir o tileset da Floresta por um mais "vivo" (verde, primavera) em vez do outono — combina mais com "preservação".
- Adicionar tileset industrial pra energy.tscn (Kenney "Industrial") — depois você edita a cena no editor.

---

## 5. Ícones de fim-de-fase (opcional, melhora o impacto visual)

A `LevelEnd` atualmente não tem sprite visível. Se quiser, abra `entities/level_end.tscn` e adicione um `Sprite2D` filho com:
- Floresta → ícone de árvore plantada
- Oceano → ícone de tartaruga
- Energia → ícone de pá eólica

16×16 ou 32×32. game-icons.net tem tudo.

---

## 6. Áudio (opcional — o jogo roda sem)

Quando tiver, salvar em `audio/sfx/` e `audio/music/`. Avisa que eu plugo no código.

Sugestão de SFX (curtinhos, formato `.wav` ou `.ogg`):
- `jump.ogg` — pulo
- `collect.ogg` — coletável apanhado
- `hurt.ogg` — dano
- `level_complete.ogg` — vitória

Sugestão de trilha (1 por fase, formato `.ogg`):
- `forest_theme.ogg` — orgânico, suave
- `ocean_theme.ogg` — etéreo, água
- `energy_theme.ogg` — eletrônico, esperançoso

**Onde achar:**
- SFX: sfxr.me (gerador 8-bit), freesound.org
- Trilha: pixabay.com/music, incompetech.com

---

## Resumo do mínimo viável pra ficar com tema ODS

Se você só tiver tempo pra trocar **uma coisa**, troque os PNGs em `sprites/1 - Penguin/` por um humano. Já vira "Guardião dos Biomas" imediatamente.

Se tiver tempo pra **três coisas**, troca:
1. Protagonista (pasta `sprites/1 - Penguin/`)
2. Inimigo (pasta `sprites/3 - Skeleton/`)
3. Sprites de coletáveis (3 PNGs, um por fase, override no editor)

Tempo total estimado: **30–45 minutos** caçando assets no Kenney/CraftPix.
