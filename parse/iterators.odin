package parse

import "core:strings"

seperated_list_iter :: proc(
	parser: proc(s: ^string) -> (result: $R, ok: bool),
	seperator: proc(s: ^string) -> (result: $S, ok: bool),
	s: ^string,
) -> (
	result: R,
	ok := true,
) {
	for {
		result = parser(s) or_return
		seperator(s)
	}
}
