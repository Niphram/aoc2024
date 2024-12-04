package parse

RunePredicate :: proc(r: rune) -> bool

take_proc :: proc(
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
