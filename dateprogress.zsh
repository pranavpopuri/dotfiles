# dateprogress.zsh — date-range progress bar on shell startup
#
# Install:
#   1. Save this file as ~/.config/dateprogress.zsh
#   2. Add this line to ~/.zshrc:
#        [[ -o interactive ]] && source ~/.config/dateprogress.zsh
#
# Change the window anytime (no editing required):
#   dateprogress-set 2026-09-01 2026-12-20 "Fall semester"
#
# Or just show the bar again on demand:
#   dateprogress

DATEPROGRESS_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/dateprogress.conf"

dateprogress-set() {
  if (( $# < 2 )); then
    print -u2 "usage: dateprogress-set START END [LABEL]   (dates: YYYY-MM-DD)"
    return 1
  fi
  # Validate the dates before saving
  zmodload zsh/datetime
  local _t
  strftime -r -s _t '%Y-%m-%d' "$1" 2>/dev/null || { print -u2 "bad start date: $1"; return 1 }
  strftime -r -s _t '%Y-%m-%d' "$2" 2>/dev/null || { print -u2 "bad end date: $2"; return 1 }

  mkdir -p "${DATEPROGRESS_CONF:h}"
  {
    print -r -- "DP_START=${(qq)1}"
    print -r -- "DP_END=${(qq)2}"
    print -r -- "DP_LABEL=${(qq)${3:-}}"
  } > "$DATEPROGRESS_CONF"
  dateprogress   # show the new window immediately
}

dateprogress() {
  zmodload zsh/datetime zsh/mathfunc

  local DP_START DP_END DP_LABEL
  if [[ -r $DATEPROGRESS_CONF ]]; then
    source "$DATEPROGRESS_CONF"
  else
    print -u2 "dateprogress: no window set — run: dateprogress-set START END [LABEL]"
    return 1
  fi

  local start end now frac
  strftime -r -s start '%Y-%m-%d' "$DP_START" || return 1
  strftime -r -s end   '%Y-%m-%d' "$DP_END"   || return 1
  now=$EPOCHSECONDS

  if (( end <= start )); then
    print -u2 "dateprogress: end date must be after start date"
    return 1
  fi

  frac=$(( (now - start) * 100.0 / (end - start) ))
  (( frac < 0 ))   && frac=0
  (( frac > 100 )) && frac=100

  # Bar width: fit the terminal, but cap it so it doesn't sprawl
  local width=$(( ${COLUMNS:-80} - 10 ))
  (( width > 50 )) && width=50
  (( width < 10 )) && width=10
  local filled=$(( int(width * frac / 100.0 + 0.5) ))

  # Colors — truecolor gradient (Ghostty, iTerm2, kitty, etc.)
  # Edit these two RGB triples to change the gradient endpoints
  local -a c_from=(0 215 200)     # teal
  local -a c_to=(175 135 255)     # violet
  local reset=$'\e[0m' dim=$'\e[2m' bold=$'\e[1m' track=$'\e[38;5;238m'

  # Build the filled portion, interpolating RGB across it
  local bar="" i t r g b
  local denom=$(( filled > 1 ? filled - 1 : 1 ))
  for (( i = 0; i < filled; i++ )); do
    t=$(( i * 1.0 / denom ))
    r=$(( int(c_from[1] + (c_to[1] - c_from[1]) * t + 0.5) ))
    g=$(( int(c_from[2] + (c_to[2] - c_from[2]) * t + 0.5) ))
    b=$(( int(c_from[3] + (c_to[3] - c_from[3]) * t + 0.5) ))
    bar+=$'\e[38;2;'${r}';'${g}';'${b}$'m█'
  done
  bar+="${track}${(pl:$(( width - filled ))::░:)}${reset}"

  # End date as "Aug 21" style
  local end_pretty
  strftime -s end_pretty '%b %-d' "$end"

  print
  [[ -n $DP_LABEL ]] && print -- "  ${bold}${DP_LABEL}${reset}"
  printf '  %s %s%5.1f%%%s\n' "$bar" "$bold" "$frac" "$reset"
  if (( frac >= 100 )); then
    print -- "  ${dim}done!${reset}"
  elif (( now < start )); then
    print -- "  ${dim}hasn't started yet · begins $DP_START${reset}"
  else
    print -- "  ${dim}$(( (end - now) / 86400 )) days remaining · ends $end_pretty${reset}"
  fi
  print
}

# Run once at startup (this file is only sourced in interactive shells,
# but guard again in case it gets sourced from somewhere else)
[[ -o interactive ]] && dateprogress
