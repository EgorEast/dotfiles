#!/usr/bin/env bash
# ============================================================================
#  Массовый перенос репозиториев Codeberg -> свой Forgejo + Codeberg как
#  push-зеркало (Forgejo главный, Codeberg держится в синхроне).
#
#  Идемпотентный: уже перенесённые репо и существующие зеркала пропускает.
#  Все curl с флагом -q (НЕ читать ~/.curlrc) — иначе из-за continue-at в
#  .curlrc POST-запросы падают с "cannot mix --continue-at with --data".
#
#  ТРЕБУЕТСЯ: curl, jq
#
#  ТОКЕНЫ:
#   - Codeberg: Settings -> Applications: repository (read+write), issue (read),
#     user (read), organization (read).
#   - Forgejo:  токен с write:repository (создавали через CLI).
#
#  ЗАПУСК:
#     export CODEBERG_USER=...  CODEBERG_TOKEN=...
#     export FORGEJO_TOKEN=...
#     # FORGEJO_OWNER задавать НЕ нужно — определится из токена.
#     DRY_RUN=true bash migrate-codeberg-to-forgejo.sh   # пробный прогон
#     bash migrate-codeberg-to-forgejo.sh                 # боевой
# ============================================================================
set -uo pipefail

# ---------- КОНФИГ ----------
CODEBERG_API="https://codeberg.org/api/v1"
CODEBERG_USER="${CODEBERG_USER:-}"
CODEBERG_TOKEN="${CODEBERG_TOKEN:-}"

FORGEJO_API="${FORGEJO_API:-https://git.lightnode.ru/api/v1}"
FORGEJO_OWNER="${FORGEJO_OWNER:-}" # пусто = взять логин владельца токена
FORGEJO_TOKEN="${FORGEJO_TOKEN:-}"

MIGRATE_SERVICE="${MIGRATE_SERVICE:-git}" # git = только код+история (надёжно, без API Codeberg); gitea = ещё issues/PR/релизы (медленно, ловит rate-limit)
MIGRATE_ISSUES=true
MIGRATE_PRS=true
MIGRATE_RELEASES=true
MIGRATE_WIKI=true

MIRROR_INTERVAL="8h0m0s"
SYNC_ON_COMMIT=true

ONLY_OWN=true
SKIP_FORKS=true

DRY_RUN="${DRY_RUN:-false}"
# ----------------------------

for c in curl jq; do command -v "$c" >/dev/null 2>&1 || {
  echo "Нужна утилита: $c"
  exit 1
}; done
if [ -z "$CODEBERG_USER" ] || [ -z "$CODEBERG_TOKEN" ] || [ -z "$FORGEJO_TOKEN" ]; then
  echo "Заполни CODEBERG_USER, CODEBERG_TOKEN, FORGEJO_TOKEN (см. шапку)."
  exit 1
fi

cb_auth=(-H "Authorization: token ${CODEBERG_TOKEN}")
fj_auth=(-H "Authorization: token ${FORGEJO_TOKEN}")
fj_json=(-H "Content-Type: application/json")

# владелец = логин владельца токена, если не задан явно
me=$(curl -qs "${fj_auth[@]}" "${FORGEJO_API}/user" | jq -r '.login // empty')
[ -z "$FORGEJO_OWNER" ] && FORGEJO_OWNER="$me"
if [ -z "$FORGEJO_OWNER" ]; then
  echo "Не удалось определить владельца Forgejo. Проверь FORGEJO_TOKEN и FORGEJO_API."
  exit 1
fi
echo "Целевой владелец в Forgejo: ${FORGEJO_OWNER} (токен принадлежит: ${me:-?})"

echo "== Собираю список репозиториев с Codeberg =="
repos_file="$(mktemp)"
page=1
while :; do
  resp="$(curl -qs "${cb_auth[@]}" "${CODEBERG_API}/user/repos?limit=50&page=${page}")"
  cnt="$(echo "$resp" | jq 'length' 2>/dev/null || echo 0)"
  [ "${cnt:-0}" -eq 0 ] && break
  echo "$resp" | jq -c '.[]' >>"$repos_file"
  page=$((page + 1))
done
echo "Получено записей: $(wc -l <"$repos_file" | tr -d ' ')"

ok=0
skip=0
fail=0
while IFS= read -r repo; do
  name=$(echo "$repo" | jq -r '.name')
  owner=$(echo "$repo" | jq -r '.owner.login')
  clone=$(echo "$repo" | jq -r '.clone_url')
  private=$(echo "$repo" | jq -r '.private')
  isfork=$(echo "$repo" | jq -r '.fork')
  desc=$(echo "$repo" | jq -r '.description // ""')

  if [ "$ONLY_OWN" = true ] && [ "$owner" != "$CODEBERG_USER" ]; then continue; fi
  if [ "$SKIP_FORKS" = true ] && [ "$isfork" = "true" ]; then
    echo "пропуск (форк): $name"
    skip=$((skip + 1))
    continue
  fi

  echo "--- ${owner}/${name} ---"

  exists=$(curl -qs -o /dev/null -w '%{http_code}' "${fj_auth[@]}" "${FORGEJO_API}/repos/${FORGEJO_OWNER}/${name}")
  if [ "$exists" = "200" ]; then
    echo "  уже есть в Forgejo — миграцию пропускаю"
  elif [ "$DRY_RUN" = true ]; then
    echo "  [dry-run] миграция ${clone} -> ${FORGEJO_OWNER}/${name}"
  else
    payload=$(jq -n \
      --arg clone "$clone" --arg name "$name" --arg owner "$FORGEJO_OWNER" \
      --arg token "$CODEBERG_TOKEN" --arg desc "$desc" --argjson priv "$private" \
      --argjson issues "$MIGRATE_ISSUES" --argjson prs "$MIGRATE_PRS" \
      --argjson rel "$MIGRATE_RELEASES" --argjson wiki "$MIGRATE_WIKI" \
      --arg svc "$MIGRATE_SERVICE" \
      '{clone_addr:$clone, repo_name:$name, repo_owner:$owner, service:$svc,
        auth_token:$token, mirror:false, private:$priv, description:$desc,
        issues:$issues, labels:true, milestones:true, pull_requests:$prs,
        releases:$rel, wiki:$wiki}')
    code=$(curl -qs -o /tmp/_mig.out -w '%{http_code}' -X POST "${fj_auth[@]}" "${fj_json[@]}" \
      -d "$payload" "${FORGEJO_API}/repos/migrate")
    if [ "$code" = "201" ]; then
      echo "  миграция OK"
    else
      echo "  миграция FAILED (HTTP $code): $(head -c 300 /tmp/_mig.out)"
      fail=$((fail + 1))
      continue
    fi
  fi

  if [ "$DRY_RUN" = true ]; then
    echo "  [dry-run] push-зеркало -> ${clone}"
  else
    have=$(curl -qs "${fj_auth[@]}" "${FORGEJO_API}/repos/${FORGEJO_OWNER}/${name}/push_mirrors" |
      jq -r --arg r "$clone" 'map(select(.remote_address==$r)) | length' 2>/dev/null || echo 0)
    if [ "${have:-0}" -gt 0 ]; then
      echo "  push-зеркало уже есть"
    else
      mpayload=$(jq -n \
        --arg addr "$clone" --arg user "$CODEBERG_USER" --arg pass "$CODEBERG_TOKEN" \
        --arg interval "$MIRROR_INTERVAL" --argjson soc "$SYNC_ON_COMMIT" \
        '{remote_address:$addr, remote_username:$user, remote_password:$pass,
          sync_on_commit:$soc, interval:$interval}')
      code=$(curl -qs -o /tmp/_pm.out -w '%{http_code}' -X POST "${fj_auth[@]}" "${fj_json[@]}" \
        -d "$mpayload" "${FORGEJO_API}/repos/${FORGEJO_OWNER}/${name}/push_mirrors")
      if [ "$code" = "200" ] || [ "$code" = "201" ]; then
        echo "  push-зеркало OK"
      else
        echo "  push-зеркало FAILED (HTTP $code): $(head -c 300 /tmp/_pm.out)"
      fi
    fi
  fi

  ok=$((ok + 1))
  sleep 1
done <"$repos_file"

echo "== Готово: обработано=$ok, пропущено=$skip, ошибок=$fail =="
echo "Если часть упала из-за того, что большая миграция ещё шла — запусти скрипт ещё раз."
rm -f "$repos_file"
