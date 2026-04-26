#!/usr/bin/env bash
# Claude Code status line.
# Layout: [directory  branch status] │ Model │ ██░░ pct% │ ↓in ↑out │ $cost │ 5h:pct% 7d:pct%
#
# This file is a template rendered by home-manager (home-manager/dev/claude-code.nix).
# @DRACULA_*@ placeholders are substituted from home-manager/theme/dracula.nix.

# ── Dracula palette ──────────────────────────────────────
GREEN='\033[38;2;@DRACULA_GREEN@m'
RED='\033[38;2;@DRACULA_RED@m'
YELLOW='\033[38;2;@DRACULA_YELLOW@m'
CYAN='\033[38;2;@DRACULA_CYAN@m'
PURPLE='\033[38;2;@DRACULA_PURPLE@m'
DIM='\033[38;2;@DRACULA_COMMENT@m'
BOLD='\033[1m'
RST='\033[0m'
SEP="${DIM} │ ${RST}"

# ── Read JSON from stdin ─────────────────────────────────
INPUT=$(cat)

MODEL=$(jq -r '.model.display_name // "unknown"' <<< "$INPUT")
CWD=$(jq -r '.cwd // .workspace.current_dir // "."' <<< "$INPUT")
CTX_PCT=$(jq -r '.context_window.used_percentage // 0 | floor' <<< "$INPUT")
COST=$(jq -r '.cost.total_cost_usd // 0' <<< "$INPUT")
TOK_IN=$(jq -r '.context_window.total_input_tokens // 0' <<< "$INPUT")
TOK_OUT=$(jq -r '.context_window.total_output_tokens // 0' <<< "$INPUT")
RATE_5H=$(jq -r '.rate_limits.five_hour.used_percentage // -1 | floor' <<< "$INPUT")
RATE_7D=$(jq -r '.rate_limits.seven_day.used_percentage // -1 | floor' <<< "$INPUT")

# ── Helpers ──────────────────────────────────────────────
color_for_pct() {
  local pct=${1:-0}
  if ((pct < 50)); then printf '%b' "$GREEN"
  elif ((pct < 75)); then printf '%b' "$YELLOW"
  else printf '%b' "$RED"; fi
}

bar() {
  local pct=${1:-0} w=${2:-10} i
  ((pct > 100)) && pct=100
  ((pct < 0)) && pct=0
  local f=$((pct * w / 100))
  local e=$((w - f))
  for ((i = 0; i < f; i++)); do printf '█'; done
  for ((i = 0; i < e; i++)); do printf '░'; done
}

human_tokens() {
  local n=${1:-0}
  if ((n >= 1000000)); then printf '%.1fM' "$(echo "$n / 1000000" | bc -l)"
  elif ((n >= 1000)); then printf '%.1fk' "$(echo "$n / 1000" | bc -l)"
  else printf '%d' "$n"; fi
}

# ── Starship (directory + git) ───────────────────────────
GIT=$(cd "$CWD" 2>/dev/null \
  && STARSHIP_CONFIG="$HOME/.claude/starship-statusline.toml" starship prompt 2>/dev/null \
  | tr -d '\n' | sed -E 's/%\{|%\}|\\\[|\\\]//g; s/ *$//') || true

# ── Assemble ─────────────────────────────────────────────
OUT=""
[[ -n "$GIT" ]] && OUT+="$GIT"
OUT+="${SEP}${PURPLE}${BOLD}${MODEL}${RST}"
OUT+="${SEP}$(color_for_pct "$CTX_PCT")$(bar "$CTX_PCT") ${CTX_PCT}%${RST}"

if [[ "$TOK_IN" != "0" || "$TOK_OUT" != "0" ]]; then
  OUT+="${SEP}${CYAN}↓$(human_tokens "$TOK_IN") ↑$(human_tokens "$TOK_OUT")${RST}"
fi

if [[ "$COST" != "0" && "$COST" != "null" ]]; then
  OUT+="${SEP}${YELLOW}\$$(printf '%.2f' "$COST")${RST}"
fi

((RATE_5H >= 0)) 2>/dev/null && OUT+="${SEP}$(color_for_pct "$RATE_5H")5h:${RATE_5H}%${RST}"
((RATE_7D >= 0)) 2>/dev/null && OUT+=" $(color_for_pct "$RATE_7D")7d:${RATE_7D}%${RST}"

printf '%b\n' "$OUT"
