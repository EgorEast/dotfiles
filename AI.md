# AI

## генерация профиля для opencode

[генератор](https://tweakoc.com/flow/kdco-workspace/review)

### Piplene сбалансированного варианта - "умные" задачи для платного, "объемные и глупые" для беспратного

```text
User
↓
Orchestrator (z.AI)
↓
Explorer (BigPickle)
↓
Researcher (z.AI)
↓
Coder (BigPickle)
↓
Reviewer (z.AI)
↓
Scribe (BigPickle)
```

### для opencode go

```text
User
↓
Orchestrator (GLM-5.2)
↓
Explorer (MiniMax-M3)
↓
Researcher (GLM-5.2)
↓
Coder (MiniMax-M3)
↓
Reviewer (GLM-5.2)
↓
Scribe (MiniMax-M3)
```

### Models combo in aliases

самый дешевый из go - DeepSeek V4 Flash
бесплатный - BigPickle (opencode Zen)
средний по цене в go - Qwen3.7 Plus

go_glm_and_free - GLM-5.2 (opencode Go) + BigPickle (opencode Zen)
go_glm_deepseek - GLM-5.2 (opencode Go) + DeepSeek V4 Flash (opencode Go)
go_glm_minimax - GLM-5.2 (opencode Go) + MiniMax M3 (opencode Go)
go_lite - Qwen3.7 Plus (opencode Go) + DeepSeek V4 Flash (opencode Go)
zai - GLM-5.2 (z.AI)
zai-lite - GLM-4.7 (z.AI)
zai-lite_and_free - GLM-4.7 (z.AI) + BigPickle (opencode Zen)
zai_and_free - GLM-5.2 (z.AI) + BigPickle (opencode Zen)
zai_mixed - GLM-5.2 (z.AI) + GLM-4.7 (z.AI)
