#!/usr/bin/env bash
# Claude Code statusLine script — Tokyo Night theme

input=$(cat)

# ── constants ──────────────────────────────────────────────────────────────

RESET='\033[0m'
DIM='\033[2m'
BLUE='\033[38;2;122;162;247m'         # #7aa2f7
MAGENTA='\033[38;2;187;154;247m'      # #bb9af7
CYAN='\033[38;2;125;207;255m'         # #7dcfff
BRIGHT_BLACK='\033[38;2;107;112;137m' # #6b7089

SEP_R=''    # Powerline right arrow (filled)
ICON_MODEL=󰛄  # nf-md-asterisk   U+F07C4
ICON_GIT=    # nf-dev-git_branch U+E725

# ── primitive helpers ──────────────────────────────────────────────────────

# make_bar <pct>  →  "██████░░░░"  (colour-coded, 10 blocks)
make_bar() {
  local pct=${1:-0}
  local filled=$(( pct * 10 / 100 )) empty=$(( 10 - pct * 10 / 100 ))
  local bar="" i
  for (( i=0; i<filled; i++ )); do bar+="█"; done
  for (( i=0; i<empty;  i++ )); do bar+="░"; done
  if   (( pct >= 80 )); then printf '\033[38;2;255;107;107m%s\033[0m' "$bar"
  elif (( pct >= 60 )); then printf '\033[38;2;224;175;104m%s\033[0m' "$bar"
  else                       printf '\033[38;2;158;206;106m%s\033[0m' "$bar"
  fi
}

# pct_colour <pct>  →  ANSI colour escape for the value (no reset)
pct_colour() {
  local pct=${1:-0}
  if   (( pct >= 80 )); then printf '\033[38;2;255;107;107m'
  elif (( pct >= 60 )); then printf '\033[38;2;224;175;104m'
  else                       printf '\033[38;2;158;206;106m'
  fi
}

# fmt_tokens <n>  →  "1.2k" / "1.2M" / "42"
fmt_tokens() {
  local n=${1:-0}
  if   (( n >= 1000000 )); then awk "BEGIN{printf \"%.1fM\", $n/1000000}"
  elif (( n >= 1000     )); then awk "BEGIN{printf \"%.1fk\", $n/1000}"
  else                          printf '%d' "$n"
  fi
}

# fmt_remaining <unix_epoch>  →  "3h24m" / "42m" / "now"
fmt_remaining() {
  local resets_at=${1:-0}
  (( resets_at == 0 )) && return
  local secs=$(( resets_at - $(date +%s) ))
  if   (( secs <= 0      )); then printf 'now'
  elif (( secs < 3600   )); then printf '%dm' "$(( secs / 60 ))"
  elif (( secs < 86400  )); then
    local h=$(( secs / 3600 )) m=$(( (secs % 3600) / 60 ))
    (( m > 0 )) && printf '%dh%dm' "$h" "$m" || printf '%dh' "$h"
  else
    local d=$(( secs / 86400 )) h=$(( (secs % 86400) / 3600 ))
    (( h > 0 )) && printf '%dd%dh' "$d" "$h" || printf '%dd' "$d"
  fi
}

# ── parse JSON ─────────────────────────────────────────────────────────────

ctx_used=$( echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_in=$(   echo "$input" | jq -r '((.context_window.current_usage.input_tokens // 0) + (.context_window.current_usage.cache_creation_input_tokens // 0) + (.context_window.current_usage.cache_read_input_tokens // 0)) | floor')
ctx_out=$(  echo "$input" | jq -r '(.context_window.current_usage.output_tokens // 0) | floor')
rl_5h_pct=$(   echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rl_5h_reset=$( echo "$input" | jq -r '.rate_limits.five_hour.resets_at       // 0')
rl_7d_pct=$(   echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
rl_7d_reset=$( echo "$input" | jq -r '.rate_limits.seven_day.resets_at       // 0')
model=$(    echo "$input" | jq -r '.model.display_name                                                       // empty')
cwd=$(      echo "$input" | jq -r '.workspace.current_dir                                                    // .cwd // empty')

# ── part builders ──────────────────────────────────────────────────────────

# part_ctx  →  "ctx ██████░░░░ 47%  ↑12.3k ↓4.5k"
part_ctx() {
  [ -z "$ctx_used" ] && return
  local pct; pct=$(printf '%.0f' "$ctx_used")
  local bar; bar=$(make_bar "$pct")
  local col; col=$(pct_colour "$pct")

  local token_io=""
  if (( ctx_in > 0 || ctx_out > 0 )); then
    token_io=$(printf "  ${DIM}↑$(fmt_tokens "$ctx_in") ↓$(fmt_tokens "$ctx_out")${RESET}")
  fi

  printf "${DIM}ctx${RESET} ${bar} ${col}${pct}%%${RESET}${token_io}"
}

# part_model  →  " 󰛄 Claude Sonnet 4.6"
part_model() {
  [ -z "$model" ] && return
  printf "${BRIGHT_BLACK}${SEP_R}${RESET} ${CYAN}${ICON_MODEL} ${model}${RESET}"
}

# part_git  →  "  main"
part_git() {
  [ -z "$cwd" ] && return
  git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1 || return
  local branch
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  [ -z "$branch" ] && return
  printf "${BRIGHT_BLACK}${SEP_R}${RESET} ${BLUE}${ICON_GIT} ${MAGENTA}${branch}${RESET}"
}

# part_rate_limit <label> <pct_float> <resets_at>
# →  "5h ████░░░░░░ 42% ·3h24m"
# →  "7d ████████░░ 86% ·42m"
part_rate_limit() {
  local label=$1 raw_pct=$2 resets_at=${3:-0}
  [ -z "$raw_pct" ] && return
  local pct; pct=$(printf '%.0f' "$raw_pct")
  local bar; bar=$(make_bar "$pct")
  local col; col=$(pct_colour "$pct")
  local remaining; remaining=$(fmt_remaining "$resets_at")
  local reset_str=""
  [ -n "$remaining" ] && reset_str=$(printf " ${DIM}·${remaining}${RESET}")
  printf "${DIM}${label}${RESET} ${bar} ${col}${pct}%%${RESET}${reset_str}"
}

# ── assemble ───────────────────────────────────────────────────────────────

join_parts() {
  local sep result="" i
  sep=$(printf "  ${BRIGHT_BLACK}│${RESET}  ")
  for i in "$@"; do
    [ -z "$i" ] && continue
    result="${result:+${result}${sep}}${i}"
  done
  printf '%s' "$result"
}

row1=$(join_parts "$(part_model)" "$(part_git)")
row2=$(join_parts "$(part_ctx)" "$(part_rate_limit "5h" "$rl_5h_pct" "$rl_5h_reset")" "$(part_rate_limit "7d" "$rl_7d_pct" "$rl_7d_reset")")

[ -z "$row1" ] && [ -z "$row2" ] && exit 0

[ -n "$row1" ] && printf '%b\n' "$row1"
[ -n "$row2" ] && printf '%b\n' "$row2"
