# opencode — глобальный конфиг

Глобальная настройка OpenCode (агенты, профили, плагины). Каталог подключён к
dotfiles-репозиторию симлинком.

## Плагин `profile-global`

`plugins/profile/index.ts` — **глобальный fallback** переключателя профилей для
проектов, у которых нет своего `.opencode/plugins/profile` (например, exarh-web).
Source of truth дизайна — проект `slovo-propovedi-mobile`, его локальная копия
плагина; этот файл зеркалит её с четырьмя намеренными отличиями:

1. **id `profile-global`** (не `profile`) — глобальный и проектный плагины с
   одним id оба помечаются хостом как failed ещё до `setup()`.
2. **`profilesDir` из `import.meta.dir`** (`../../profiles`) — путь не зависит от
   текущего проекта, иначе профили искались бы в `<проект>/.opencode/profiles`.
3. **Early-return guard** — `setup()` ничего не делает, если у проекта есть свой
   `.opencode/plugins/profile` (иначе команды регистрировались бы дважды).
4. **Динамический `classifySubagents`** — какие субагенты пинятся через
   frontmatter их `.md`, а какие через registry-transform, определяется по
   наличию `.opencode/agents/<id>.md` в текущем проекте, а не хардкодом.

## Фейловер моделей при лимитах (profile-failover)

Плагин `profile-global` следит за ретраями сессии и при ошибках квоты/лимита
автоматически переключает запрошенные модели на запасные:

- **Триггеры** (два канала — retry-хук и `http.response`):
  - **жёсткий** лимит — `status 429` или текст про
    `quota`/`insufficient`/`credits`/`billing`/`payment`; ретрай его не
    восстанавливает, поэтому фейловер активируется **сразу, уже на первой
    попытке** (в т.ч. по сырому ответу сервиса `429`/`402`);
  - **мягкий** лимит — только текст `rate limit`/`too many requests`; может
    пройти сам, поэтому активируется на **втором и последующих** ретраях
    (`attempt >= 2`), а первый логируется как `skip ... first attempt`.
  Ошибка на уже активной **запасной** модели никогда не откатывает фейловер —
  только логируется; оба канала делят один mutex и гард «уже переключено», так
  что один сбой активирует фейловер ровно один раз.
- **Пары** (source → fallback):

  | Source                          | Fallback                    |
  | ------------------------------- | --------------------------- |
  | `zai-coding-plan/glm-5.3-flash` | `opencode-go/glm-5.3-flash` |
  | `zai-coding-plan/glm-5.3`       | `opencode-go/glm-5.3`       |
  | `opencode/big-pickle`           | `opencode-go/deepseek-v4.1-flash` |

- **Что переключается**: субагенты под failing-моделью (frontmatter для
  markdown-агентов + registry-пин для built-in) и primary текущей сессии, если
  её живая модель (в т.ч. переключённая вручную через `/models`) совпадает с
  failing-моделью.
- **Состояние — на проект**: файл `<проект>/.opencode/profile-fallback.json`
  (overlay или dry-run-маркер) — переживает рестарты; при старте живой overlay
  переприменяется, истёкший overlay откатывается с cooldown, устаревший
  dry-run-маркер просто удаляется (без cooldown). Файл project-relative, потому
  что фейловер правит frontmatter агентов именно этого проекта.
- **TTL**: 30 минут — затем авто-revert и повторное применение профиля.
  **Cooldown**: 5 минут между revert и следующей активацией.
- **Лог**: `<проект>/.opencode/profile-fallback.log` — одна строка на событие;
  при превышении 1 MB ротируется в `.log.1` (перезапись). Skip-строки
  дедуплицируются (не чаще раза за cooldown-окно на пару «причина + модель»).
- **Репетиция**: `/profile-failover-test dry [modelRef]` — только логирует
  (`dry-run`), ничего не применяет. Реальный тест: `/profile-failover-test
[modelRef]` (по умолчанию — модель текущей сессии); это единственный путь,
  который обходит cooldown, чтобы форсировать прогон сразу после revert.
- **Ручное переключение профиля** (`/profile <имя>`) сбрасывает overlay
  (reset). При hot-reload плагина cleanup отписывает retry- и
  `http.response`-хуки, диспоузит registry-пины и снимает TTL-таймер.

Код: `plugins/profile/index.ts` (wiring), `plugins/profile/failover.ts`
(механика), `plugins/profile/shared.ts` (общие хелперы).
