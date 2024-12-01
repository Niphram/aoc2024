package utils

import "core:fmt"
import "core:mem"
import "core:os"
import "core:strings"

trim_newline :: proc(s: string) -> string {
	return strings.trim_right(s, "\n")
}

split_lines_iterator_trim :: proc(s: ^string) -> (line: string, ok: bool) {
	line = strings.split_lines_iterator(s) or_return

	ok = len(line) != 0

	return
}

split_once :: proc(
	s, sep: string,
	allocator := context.allocator,
) -> (
	left, right: string,
	err: mem.Allocator_Error,
) {
	parts := strings.split_n(s, sep, 2) or_return

	left = parts[0]
	right = parts[1]

	return
}
