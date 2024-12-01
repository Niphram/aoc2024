package parser

import "core:strconv"
import "core:strings"
import "core:unicode"

/*
Takes runes from the string until the predicate no longer matches `truth`.

Inputs:
- pred: A predicate that will be matched against every rune
- s: The string to parse
- truth: The truth-value to compare the predicate against

Returns:
- consumed: The consumed part of the string
- ok: will always be `true`
*/
take_while :: proc(
	pred: proc(r: rune) -> bool,
	s: ^string,
	truth := true,
) -> (
	consumed: string,
	ok := true,
) {
	count := len(s)

	for r, i in s^ {
		if pred(r) != truth {
			count = i
			break
		}
	}

	consumed = s[:count]
	s^ = s[count:]

	return
}

/*
Takes runes from the string until the predicate no longer matches `truth`.
Fails if no runes were consumed.

Inputs:
- pred: A predicate that will be matched against every rune
- s: The string to parse
- truth: The truth-value to compare the predicate against

Returns:
- consumed: The consumed part of the string
- ok: `true` if at least one rune was consumed, otherwise `false`
*/
take_while1 :: proc(
	pred: proc(r: rune) -> bool,
	s: ^string,
	truth := true,
) -> (
	consumed: string,
	ok: bool,
) {
	consumed = take_while(pred, s, truth) or_return
	ok = len(consumed) > 0

	return
}


/*
Takes a literal string from the start of `s`

Inputs:
- tag_string: The string to take from the start of `s`
- s: The string to take from

Returns:
- consumed: The consumed part of the string
- ok: `true` if the string `s` started with the tag, otherwise `false`
*/
tag :: proc(tag_string: string, s: ^string) -> (consumed: string, ok := true) {
	strings.starts_with(s^, tag_string) or_return

	consumed = s[:len(tag_string)]
	s^ = s[len(tag_string):]

	return
}

/*
Takes digits from the start of the string and parsed them into an int

Inputs:
- s: The string to parse

Returns:
- result: The parsed integer
- ok: `true` if the string `s` started with at least one digit, otherwise `false`
*/
integer :: proc(s: ^string) -> (result: int, ok := true) {
	number_string := take_while1(unicode.is_digit, s) or_return
	result = strconv.atoi(number_string)

	return
}

/*
Takes a single newline ('\n') from the start of `s`

Inputs:
- s: The string to parse

Returns:
- consumed: The consumed part of the string
- ok: `true` if the string `s` started with a newline, otherwise `false`
*/
newline :: proc(s: ^string) -> (consumed: string, ok: bool) {
	return tag("\n", s)
}
