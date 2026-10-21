# dateprogress.bash — date-range progress bar on shell startup
#
# Bash twin of dateprogress.zsh. Both read the same config file:
#   ~/.config/dateprogress.conf
#
# Install:
#   1. Save this file as ~/.config/dateprogress.bash
#   2. Add this line to ~/.bashrc:
#        [[ $- == *i* ]] && source ~/.config/dateprogress.bash
#
# Change the window anytime (no editing required):
#   dateprogress-set 2026-09-01 2026-12-20 "Fall semester"
#
# Or just show the bar again on demand:
#   dateprogress
#
# Targets bash 3.2 (the macOS system bash), so no printf '%(...)T' and no
# floating-point arithmetic in the shell: date parsing goes through date(1)
# and the gradient math goes through awk.

DATEPROGRESS_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/dateprogress.conf"

# YYYY-MM-DD -> epoch seconds
_dp_to_epoch() {
	date -j -f "%Y-%m-%d" "$1" "+%s" 2>/dev/null || date -d "$1" "+%s" 2>/dev/null
}

# epoch seconds -> date formatted with the given strftime format
_dp_from_epoch() {
	date -r "$1" "+$2" 2>/dev/null || date -d "@$1" "+$2" 2>/dev/null
}

dateprogress-set() {
	if [ "$#" -lt 2 ]; then
		printf '%s\n' "usage: dateprogress-set START END [LABEL]   (dates: YYYY-MM-DD)" >&2
		return 1
	fi

	local start end
	start="$(_dp_to_epoch "$1")"
	if [ -z "$start" ]; then
		printf '%s\n' "dateprogress-set: bad start date: $1" >&2
		return 1
	fi
	end="$(_dp_to_epoch "$2")"
	if [ -z "$end" ]; then
		printf '%s\n' "dateprogress-set: bad end date: $2" >&2
		return 1
	fi

	mkdir -p "$(dirname "$DATEPROGRESS_CONF")" || return 1
	{
		printf 'DP_START=%q\n' "$1"
		printf 'DP_END=%q\n' "$2"
		printf 'DP_LABEL=%q\n' "${3:-}"
	} > "$DATEPROGRESS_CONF" || return 1

	dateprogress
}

dateprogress() {
	local DP_START DP_END DP_LABEL
	if [ -r "$DATEPROGRESS_CONF" ]; then
		# shellcheck disable=SC1090
		. "$DATEPROGRESS_CONF"
	else
		printf '%s\n' "dateprogress: no window set — run: dateprogress-set START END [LABEL]" >&2
		return 1
	fi

	local start end now frac
	start="$(_dp_to_epoch "$DP_START")"
	end="$(_dp_to_epoch "$DP_END")"
	now="$(date "+%s")"
	if [ -z "$start" ] || [ -z "$end" ]; then
		printf '%s\n' "dateprogress: could not parse DP_START/DP_END in $DATEPROGRESS_CONF" >&2
		return 1
	fi
	if [ "$end" -le "$start" ]; then
		printf '%s\n' "dateprogress: end date must be after start date" >&2
		return 1
	fi

	# Bar width: fit the terminal, but cap it so it doesn't sprawl.
	# COLUMNS is 0 when stdout is not a terminal — fall back to 80 in that case.
	local cols="${COLUMNS:-80}"
	[ "$cols" -lt 1 ] && cols=80
	local width=$(( cols - 10 ))
	[ "$width" -gt 50 ] && width=50
	[ "$width" -lt 10 ] && width=10

	# Colors — truecolor gradient (Ghostty, iTerm2, kitty, etc.)
	# Edit these two RGB triples to change the gradient endpoints
	local reset=$'\e[0m' dim=$'\e[2m' bold=$'\e[1m' track=$'\e[38;5;238m'

	# Percentage (clamped) and filled cell count
	frac=$(awk -v n="$now" -v s="$start" -v e="$end" \
		'BEGIN { f = (n - s) * 100.0 / (e - s); if (f < 0) f = 0; if (f > 100) f = 100; printf "%.1f", f }')
	local filled
	filled=$(awk -v w="$width" -v f="$frac" 'BEGIN { printf "%d", int(w * f / 100.0 + 0.5) }')

	# Build the filled portion, interpolating RGB across it
	local bar
	bar=$(awk -v filled="$filled" -v w="$width" 'BEGIN {
		denom = (filled > 1 ? filled - 1 : 1);
		for (i = 0; i < filled; i++) {
			t = i / denom;
			r = int(0   + (175 - 0)   * t + 0.5);
			g = int(215 + (135 - 215) * t + 0.5);
			b = int(200 + (255 - 200) * t + 0.5);
			printf "\033[38;2;%d;%d;%dm█", r, g, b;
		}
		track = sprintf("%*s", w - filled, "");
		gsub(/ /, "░", track);
		printf "%s%s", "\033[38;5;238m", track;
	}')

	# End date as "Aug 21" style
	local end_pretty
	end_pretty="$(_dp_from_epoch "$end" "%b %-d")"

	printf '\n'
	[ -n "$DP_LABEL" ] && printf '  %s%s%s\n' "$bold" "$DP_LABEL" "$reset"
	printf '  %s%s%s%5s%%\n' "$bar" "$reset" "$bold" "$frac"
	if awk -v f="$frac" 'BEGIN { exit !(f >= 100) }'; then
		printf '  %s%s%s\n' "$dim" "done!" "$reset"
	elif [ "$now" -lt "$start" ]; then
		printf '  %s%s · begins %s%s\n' "$dim" "hasn't started yet" "$DP_START" "$reset"
	else
		printf '  %s%s days remaining · ends %s%s\n' "$dim" "$(( (end - now) / 86400 ))" "$end_pretty" "$reset"
	fi
	printf '\n'
}

# Run once at startup (this file is only sourced in interactive shells,
# but guard again in case it gets sourced from somewhere else)
[[ $- == *i* ]] && dateprogress
