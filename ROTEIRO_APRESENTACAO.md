# Guardião dos Biomas — Roteiro de Apresentação

> **Tema:** Game ODS — Dia do Meio Ambiente · FATEC Jacareí
> **Duração sugerida:** 15-20 minutos · **Grupo:** 5 pessoas

---

## 📌 Antes de tudo — o que cada um precisa saber

Mesmo que cada integrante fale uma parte específica, **todos** precisam dominar três respostas curtas, porque o professor pode perguntar pra qualquer um:

1. **"O que é Godot?"** → Motor de jogos (game engine) **gratuito e open-source**, criado em 2014, usado pra fazer jogos 2D e 3D. Concorrente direto da Unity e da Unreal, mas leve (menos de 100MB) e sem royalties.

2. **"O que é GDScript?"** → Linguagem de programação **própria do Godot**, criada especificamente para fazer jogos nele. É **muito parecida com Python** (mesma indentação, sintaxe limpa, fácil de aprender).

3. **"Por que escolheram Godot e não Unity?"** → Open-source (sem custo de licença), mais leve, e a curva de aprendizado é menor porque GDScript é fácil. Pra um projeto acadêmico com prazo curto, foi a escolha certa.

---

## 🎤 Divisão de falas — 5 integrantes

### **PESSOA 1 — Abertura & Tema do Jogo** (2-3 min)

**O que falar:**
- Cumprimentar a banca, apresentar o nome do grupo e o nome do jogo: *Guardião dos Biomas*.
- Contextualizar o tema:
  - **ODS (Objetivos de Desenvolvimento Sustentável) da ONU** — especialmente **ODS 15 (Vida Terrestre)** que trata da proteção de ecossistemas terrestres e biodiversidade.
  - **Dia do Meio Ambiente** (5 de junho) — data oficial da ONU.
- Pitch do jogo em 1 frase: *"Um jogo de plataforma 2D em pixel art onde o jogador atravessa os biomas brasileiros enfrentando ameaças ambientais, com o objetivo de conscientizar sobre a importância da preservação."*
- Citar os biomas representados (Amazônia, Cerrado, Mata Atlântica, Pantanal, etc — confirmar quais estão no jogo).

**Frase de transição:**
> "Pra construir esse jogo, escolhemos uma engine moderna e open-source chamada Godot. A próxima pessoa vai explicar o que é."

---

### **PESSOA 2 — O que é Godot** (3-4 min)

**O que falar:**

**Definição:**
> "Godot é uma engine de jogos — ou seja, um software que junta tudo o que é preciso pra criar um jogo: gráficos, física, áudio, programação, animações. É como se fosse o Photoshop dos jogos."

**Pontos-chave a destacar:**

| Característica | Por que importa |
|---|---|
| **Open-source e gratuito** | Sem licenças, sem royalties. Você pode publicar e vender o jogo sem pagar nada. |
| **Leve** | O Godot inteiro tem menos de 100 MB. A Unity passa de 10 GB. |
| **Multiplataforma** | Um único projeto exporta pra Windows, Mac, Linux, Android, iOS e Web. |
| **Sistema de cenas e nós** | Tudo no Godot é um "Nó" (Node). Uma cena é uma árvore de nós. Isso torna a estrutura previsível e modular. |
| **Comunidade ativa** | Documentação oficial muito boa, fórum ativo, milhares de tutoriais. |

**Concorrentes (pra mostrar contexto):**
- **Unity** — usada em jogos como *Hollow Knight* e *Among Us*. Mais robusta, mas paga em alguns casos.
- **Unreal Engine** — usada em *Fortnite*. Mais voltada pra jogos 3D AAA, mas é pesada e complexa.
- **Godot** — usada em jogos como *Cruelty Squad*, *Brotato* e *Dome Keeper*. Cresceu muito desde 2023 quando a Unity mudou as regras de cobrança.

**Frase de transição:**
> "Pra programar dentro do Godot, usamos uma linguagem chamada GDScript. Próximo integrante explica."

---

### **PESSOA 3 — O que é GDScript** (3-4 min)

**O que falar:**

**Definição direta:**
> "GDScript é a linguagem de programação criada especificamente pro Godot. Foi feita pra ser fácil de aprender, rápida pra escrever, e otimizada pra desenvolvimento de jogos."

**Comparação que sempre vai ser perguntada — "se parece com qual linguagem?":**

> **Resposta:** "GDScript é **muito parecida com Python**. Mesma forma de organizar o código (com indentação em vez de chaves), sintaxe limpa e legível, tipagem opcional. Se você sabe Python, aprende GDScript em uma tarde."

**Exemplo lado a lado — mostre no slide:**

```python
# Python
def somar(a, b):
    return a + b

print(somar(2, 3))
```

```gdscript
# GDScript
func somar(a: int, b: int) -> int:
    return a + b

print(somar(2, 3))
```

**Características importantes do GDScript:**
- **Tipagem dinâmica com tipagem opcional** — você pode declarar tipos (`var vida: int = 100`) ou deixar livre (`var vida = 100`).
- **Integração total com o editor** — autocomplete entende todos os nós da cena, sabe quais sinais existem, etc.
- **Sinais (signals)** — sistema de eventos. Quando algo acontece (jogador morreu, item coletado), um sinal é emitido e outros nós podem reagir.
- **Anotações** — palavras-chave que começam com `@` (`@onready`, `@export`) que conectam código com o editor.

**Exemplo real do nosso jogo (mostre um trecho simples):**

```gdscript
extends CharacterBody2D

@export var velocidade: float = 60.0
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
    if Input.is_action_pressed("ui_right"):
        velocity.x = velocidade
        anim.play("walk")
    else:
        velocity.x = 0
        anim.play("idle")
    move_and_slide()
```

> "Esse código faz o personagem andar pra direita quando a tecla é pressionada e troca a animação. Em outras engines isso levaria 30 linhas. No Godot são 10."

**Frase de transição:**
> "Agora a próxima pessoa vai mostrar como organizamos o projeto e quais mecânicas implementamos."

---

### **PESSOA 4 — Arquitetura do Projeto & Mecânicas** (3-4 min)

**O que falar:**

**Estrutura do projeto (mostre a árvore de pastas):**
- `scripts/` — todos os scripts em GDScript (lógica do jogador, inimigos, fases, chefões).
- `entities/` — cenas reutilizáveis (jogador, inimigos, chefes, itens).
- `tiles/` — tilemaps dos cenários de cada bioma.
- `sprites/` — arte em pixel art (personagens, inimigos, fundos).
- `audio/` — músicas e efeitos sonoros.
- `ui/` — telas de menu, pausa, fim de fase.
- `autoload/` — *singletons* que ficam disponíveis em todas as cenas (estado do jogo, controle de música, efeitos).

**Mecânicas implementadas (escolha 2-3 pra detalhar):**
1. **Movimentação** — andar, pular, nadar (estado especial em água).
2. **Plataformas móveis** — sobem, descem, deslocam horizontalmente.
3. **Inimigos variados** — cada bioma tem inimigos próprios (com IA simples de patrulha e perseguição).
4. **Sistema de chefe (boss)** — chefão final com múltiplos estados (hover, charge, smash, recover, stagger) implementado como **máquina de estados finitos** (FSM).
5. **HUD e barra de vida** — interface em pixel art.
6. **Sistema de fases** — cada bioma é uma fase com objetivos e progressão.

**Fala forte:**
> "Apesar de ser um projeto acadêmico, seguimos boas práticas de engenharia de software: separação de responsabilidades, código modular, e o projeto inteiro está versionado no GitHub."

**Frase de transição:**
> "Pra fechar, a última pessoa vai mostrar o jogo rodando e os resultados."

---

### **PESSOA 5 — Demonstração & Encerramento** (3-5 min)

**O que falar e fazer:**

**1. Rodar o jogo ao vivo (`GuardiaoDosBiomas.exe`)**
- Mostrar a tela de abertura (a splash com o ícone do carvalho).
- Mostrar o menu principal.
- Jogar uma fase de cada bioma (pular pelos pontos altos — pular partes lentas).
- Mostrar uma luta com inimigo e, se der tempo, o chefe final.

**2. Resultados/aprendizados (1-2 min):**
- O que o grupo aprendeu (engine, linguagem, trabalho em equipe, controle de versão com Git).
- Tempo total de desenvolvimento.
- Desafios principais (ex: implementar a máquina de estados do boss, balancear dificuldade, criar a arte coerente entre biomas).

**3. Próximos passos (opcional):**
- Adicionar mais biomas (Caatinga, Pampa).
- Versão mobile.
- Sistema de pontuação e ranking.

**4. Encerramento:**
> "Obrigado pela atenção. Esperamos que o Guardião dos Biomas inspire mais pessoas a olharem com cuidado pros ecossistemas brasileiros. Estamos abertos a perguntas."

---

## ❓ Perguntas que provavelmente o professor vai fazer

**P:** Por que GDScript e não C# ou C++?
**R:** O Godot suporta C# também, mas GDScript foi feito pra ser rápido de aprender e tem integração mais profunda com o editor. Pra um projeto com prazo curto, foi a escolha certa.

**P:** Quanto tempo levou?
**R:** *(combinar antes — tipo "cerca de X semanas trabalhando em paralelo às aulas")*.

**P:** O que é "pixel art"?
**R:** Estilo de arte digital onde cada pixel é colocado manualmente. Lembra os jogos clássicos de Super Nintendo e Mega Drive. Escolhemos esse estilo porque é nostálgico, leve de processar e dá uma identidade visual forte ao jogo.

**P:** O jogo é educativo?
**R:** É um jogo de ação que **carrega o tema educativo na ambientação** — cada fase representa um bioma brasileiro real, com elementos visuais e sonoros característicos. Não é um quiz, é uma experiência imersiva que desperta curiosidade.

**P:** Posso compartilhar o jogo?
**R:** Sim, o código está no GitHub (link público) e o `.exe` roda em qualquer Windows sem instalação.

**P:** Vocês vão continuar o desenvolvimento?
**R:** *(combinar antes — resposta honesta do grupo)*.

---

## 📋 Checklist do dia da apresentação

- [ ] Notebook com o jogo já exportado (`GuardiaoDosBiomas.exe`) testado.
- [ ] Cabo HDMI / adaptador pra projetor.
- [ ] Slides prontos (a `Apresentacao.pptx` do projeto).
- [ ] Controle de mouse ou apresentador remoto, se possível.
- [ ] Caixa de som ou alto-falante (pra ouvir a música e SFX do jogo).
- [ ] Backup do `.exe` em pendrive.
- [ ] Cada integrante sabe o que vai falar (decorar a parte!).
- [ ] Cronometrar a apresentação inteira pelo menos uma vez antes.

---

## 🎯 Dicas finais

1. **Não leiam slides.** Slides são apoio visual; quem fala é vocês.
2. **Olhem pra banca.** Quem está apresentando olha pros professores, não pra tela.
3. **Se der erro no jogo na hora, riam.** Faz parte do desenvolvimento. Resolvam ou pulem.
4. **Tempo é cruel.** Se ensaiarem e passar de 20 min, cortem partes.
5. **A pergunta do final vai vir.** Tenham respostas prontas pras perguntas listadas acima.

**Boa apresentação. 🌱**
