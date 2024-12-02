package parse

/*
Applies the `parser` exactly `Count` times.
*/
count :: proc(
	$Count: int,
	parser: proc(s: ^string) -> (result: $R, ok: bool),
	s: ^string,
) -> (
	result: [Count]R,
	ok := true,
) {
	for i in 0 ..< Count {
		parsed := parser(s) or_return
		result[i] = parsed
	}

	return
}

/*
Applies the `parser` as often as possible
*/
many0 :: proc(
	parser: proc(s: ^string) -> (result: $R, ok: bool),
	s: ^string,
) -> (
	result: [dynamic]R,
	ok := true,
) {
	for {
		parsed := parser(s) or_break
		append(&result, parsed)
	}

	return
}

/*
Applies the `parser` as often as possible.
Fails if the parser can not be applied at least once
*/
many1 :: proc(
	parser: proc(s: ^string) -> (result: $R, ok: bool),
	s: ^string,
) -> (
	result: [dynamic]R,
	ok: bool,
) {
	result = many0(parser, s) or_return
	ok = len(result) > 0
	return
}

/*
Alternatingly applies `parser` and `seperator` and collect the results of `parser`.
*/
seperated_list0 :: proc(
	seperator: proc(s: ^string) -> (result: $S, ok: bool),
	parser: proc(s: ^string) -> (result: $R, ok: bool),
	s: ^string,
) -> (
	result: [dynamic]R,
	ok := true,
) {
	for {
		parsed := parser(s) or_break
		append(&result, parsed)
		seperator(s) or_break
	}

	return
}

/*
Alternatingly applies `parser` and `seperator` and collect the results of `parser`.
Fails if `parser` cannot be applied at least once.
*/
seperated_list1 :: proc(
	seperator: proc(s: ^string) -> (result: $S, ok: bool),
	parser: proc(s: ^string) -> (result: $R, ok: bool),
	s: ^string,
) -> (
	result: [dynamic]R,
	ok: bool,
) {
	result = seperated_list0(seperator, parser, s) or_return
	ok = len(result) > 0

	return
}

/*
Same as `seperated_list0`, but the result will be a struct of arrays
*/
soa_seperated_list0 :: proc(
	seperator: $S/Parser($SR, $SC),
	parser: $P/Parser($PR, $PC),
) -> Parser(#soa[dynamic]PR, struct {
			s: S,
			p: P,
		}) {
	return {{seperator, parser}, proc(ctx: struct {
				s: S,
				p: P,
			}, s: ^string) -> (result: #soa[dynamic]R, ok := true) {
			for {
				parsed := exec(ctx.p) or_break
				append(&result, parsed)
				exec(ctx.s) or_break
			}

			return
		}}

}

/*
Same as `seperated_list1`, but the result will be a struct of arrays
*/
soa_seperated_list1 :: proc(
	seperator: proc(s: ^string) -> (result: $S, ok: bool),
	parser: proc(s: ^string) -> (result: $R, ok: bool),
	s: ^string,
) -> (
	result: #soa[dynamic]R,
	ok: bool,
) {
	result = soa_seperated_list0(seperator, parser, s) or_return
	ok = len(result) > 0

	return
}


/*
Matches input of format `<parser><seperator><parser>` and returns a tuple of the two values
*/
seperated :: proc(
	seperator: proc(s: ^string) -> (result: $S, ok: bool),
	parser: proc(s: ^string) -> (result: $R, ok: bool),
	s: ^string,
) -> (
	result: [2]R,
	ok := true,
) {
	result[0] = parser(s) or_return
	seperator(s) or_return
	result[1] = parser(s) or_return

	return
}
