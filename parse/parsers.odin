package parse

import "core:strconv"
import "core:strings"
import "core:unicode"

Void :: struct {}

alpha0 := Parser(string, Void){{}, proc(_: Void, s: ^string) -> (result: string, ok := true) {
		count := len(s^)

		for r, i in s^ {
			if !unicode.is_alpha(r) {
				count = i
				break
			}
		}

		result = s[:count]
		s^ = s[count:]

		return
	}}

tag :: proc(t: string) -> Parser(string, string) {
	return {t, proc(t: string, s: ^string) -> (result: string, ok: bool) {
			strings.starts_with(s^, t) or_return

			result = s[:len(t)]
			s^ = s[len(t):]

			return
		}}
}

integer :: Parser(int, Void){{}, proc(_: Void, s: ^string) -> (result: int, ok := true) {
		number := exec(take_while(1, unicode.is_digit), s) or_return
		result = strconv.atoi(number)

		return
	}}
