package parse

import "base:intrinsics"
import "core:strconv"
import "core:strings"
import "core:unicode"
import "core:unicode/utf8"

take :: proc {
	take_rune,
	take_prefix,
}

take_rune :: proc(s: ^string, prefix: rune) -> (r: rune, ok := true) {
	(utf8.rune_at(s^, 0) == prefix) or_return

	r = prefix
	s^ = s[1:]

	return
}

take_prefix :: proc(s: ^string, substr: string) -> (result: string, ok := true) {
	strings.has_prefix(s^, substr) or_return

	result = s[:len(substr)]
	s^ = s[len(substr):]

	return
}

seek_after :: proc(s: ^string, substr: string) -> (result: string, ok: bool) {
	if idx := strings.index(s^, substr); idx >= 0 {
		ok = true
		result = s[:idx + len(substr)]
		s^ = s[idx + len(substr):]
	}

	return
}

read_number :: proc(s: ^string) -> (result: int, ok := true) {
	number := take_proc(unicode.is_digit, s) or_return
	result = strconv.parse_int(number, 10) or_return

	return
}
