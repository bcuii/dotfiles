#!/bin/bash
# Claude Code status line. Reads session JSON on stdin, prints two lines.
input=$(cat)

DIM=$'\033[2m'; RESET=$'\033[0m'
GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'
CYAN=$'\033[36m'; BLUE=$'\033[34m'; MAGENTA=$'\033[35m'

# One field per line: @tsv would collapse empty fields, since read treats runs
# of tabs as a single delimiter. Missing fields come through as empty strings.
i=0
while IFS= read -r v; do F[$i]=$v; i=$((i + 1)); done < <(jq -r '
  def pct: if . == null then "" else floor end;
  [ .model.display_name // "?"
  , .effort.level // ""
  , (if .fast_mode then "fast" else "" end)
  , .workspace.current_dir // .cwd // ""
  , (.context_window.used_percentage | pct)
  , .context_window.total_input_tokens // ""
  , .context_window.context_window_size // ""
  , .cost.total_cost_usd // 0
  , (if .prompt_cache == null then ""
     elif .prompt_cache.warm then "warm" else "cold" end)
  , (if .prompt_cache.hit_ratio == null then ""
     else (.prompt_cache.hit_ratio * 100 | floor) end)
  , .prompt_cache.ttl // ""
  , (.rate_limits.five_hour.used_percentage | pct)
  , .rate_limits.five_hour.resets_at // ""
  , (.rate_limits.seven_day.used_percentage | pct)
  , .rate_limits.seven_day.resets_at // ""
  , (.rate_limits.spend_limit.used_percentage | pct)
  , .rate_limits.spend_limit.resets_at // ""
  ] | map(tostring) | .[]' <<<"$input")

model=${F[0]}   effort=${F[1]}     fast=${F[2]}      dir=${F[3]}
ctx_pct=${F[4]} ctx_tok=${F[5]}    ctx_size=${F[6]}  cost=${F[7]}
warm=${F[8]}    hit=${F[9]}        ttl=${F[10]}

# Color a percentage: green under 50, yellow under 80, red at or above.
hue() {
  if   [ "$1" -ge 80 ] 2>/dev/null; then printf '%s' "$RED"
  elif [ "$1" -ge 50 ] 2>/dev/null; then printf '%s' "$YELLOW"
  else printf '%s' "$GREEN"; fi
}

# Token count as 35k / 1M / 1.2M.
human() {
  if [ "$1" -ge 1000000 ]; then
    local tenths=$(( $1 / 100000 ))
    if [ $(( tenths % 10 )) -eq 0 ]
      then printf '%dM' $(( tenths / 10 ))
      else printf '%d.%dM' $(( tenths / 10 )) $(( tenths % 10 )); fi
  elif [ "$1" -ge 1000 ]; then printf '%dk' $(( $1 / 1000 ))
  else printf '%d' "$1"; fi
}

# Compact time until an epoch timestamp: 4d / 2h05m / 15m. Empty once passed.
until_ts() {
  [ -n "$1" ] || return
  local d=$(( $1 - $(date +%s) ))
  [ "$d" -le 0 ] && return
  if   [ "$d" -ge 86400 ]; then printf '%dd' $(( d / 86400 ))
  elif [ "$d" -ge 3600 ];  then printf '%dh%02dm' $(( d / 3600 )) $(( d % 3600 / 60 ))
  else printf '%dm' $(( d / 60 )); fi
}

# -- line 1: model, effort, directory, git branch --
line1="${CYAN}${model}${RESET}"
[ -n "$effort" ] && line1="${line1}${DIM} ${effort}${RESET}"
[ -n "$fast" ] && line1="${line1} ${MAGENTA}fast${RESET}"

tilde='~'
[ -n "$dir" ] && line1="${line1}${DIM} | ${RESET}${BLUE}${dir/#$HOME/$tilde}${RESET}"

if branch=$(git -C "$dir" symbolic-ref --quiet --short HEAD 2>/dev/null); then
  git -C "$dir" diff --quiet --ignore-submodules HEAD 2>/dev/null || branch="${branch}*"
  line1="${line1}${DIM} | ${RESET}${MAGENTA}${branch}${RESET}"
fi

# -- line 2: context, cost, cache, rate limits --
parts=()

if [ -n "$ctx_tok" ] && [ -n "$ctx_size" ]; then
  # used_percentage is null early in a session and just after /compact; the
  # token counts are still there, so derive the color threshold from them.
  [ -n "$ctx_pct" ] || ctx_pct=$(( ctx_tok * 100 / ctx_size ))
  parts+=("ctx $(hue "$ctx_pct")$(human "$ctx_tok")${RESET}${DIM}/$(human "$ctx_size")${RESET}")
fi

parts+=("$(printf '$%.2f' "$cost")")

if [ -n "$warm" ]; then
  c="cache ${warm}"
  [ "$warm" = warm ] && [ -n "$ttl" ] && c="${c}${DIM}(${ttl})${RESET}"
  [ -n "$hit" ] && c="${c} ${DIM}${hit}% hit${RESET}"
  parts+=("$c")
fi

# A rate-limit window: label, used percentage, reset timestamp. Only a
# percentage is available for these -- the API reports no absolute figure.
window() {
  [ -n "$2" ] || return
  local s="$1 $(hue "$2")$2%${RESET}" left
  left=$(until_ts "$3")
  [ -n "$left" ] && s="${s}${DIM}(${left})${RESET}"
  parts+=("$s")
}
window 5h "${F[11]}" "${F[12]}"
window 7d "${F[13]}" "${F[14]}"
window spend "${F[15]}" "${F[16]}"

line2=
for p in "${parts[@]}"; do
  [ -n "$line2" ] && line2="${line2}${DIM} | ${RESET}"
  line2="${line2}${p}"
done

printf '%s\n%s\n' "$line1" "$line2"
