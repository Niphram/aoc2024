package parse

import "core:strings"

first_index :: proc(s, substr: string) -> (idx: int, ok: bool) {
	idx = strings.index(s, substr)
	ok = idx != -1

	return
}
