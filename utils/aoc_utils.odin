package utils

import "core:strings"

trim_newline :: proc(s: string) -> string {
	return strings.trim_right(s, "\n")
}

split_lines_iterator_trim :: proc(s: ^string) -> (line: string, ok: bool) {
	line = strings.split_lines_iterator(s) or_return

	ok = len(line) != 0

	return
}

split_once :: proc(s, sep: string) -> (left, right: string, ok := true) {
	split_idx := strings.index(s, sep)
	(split_idx >= 0) or_return

	left = s[:split_idx]
	right = s[split_idx + len(sep):]

	return
}
