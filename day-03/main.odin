package main

import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:testing"
import "core:unicode"

import "../parser"

index :: proc(s, substr: string) -> (idx: int, ok: bool) {
	idx = strings.index(s, substr)
	ok = idx != -1

	return
}

parse_number :: proc(s: ^string) -> (result: int, ok: bool) {
	length := len(s^)

	for r, i in s^ {
		if !unicode.is_digit(r) {
			length = i
			break
		}
	}

	ok = length != 0
	result = strconv.atoi(s[:length])
	s^ = s[length:]

	return
}

consume_rune :: proc(s: ^string, r: rune) -> (ok := true) {
	(rune(s[0]) == r) or_return
	s^ = s[1:]

	return
}

parse_mul_instr :: proc(s: ^string) -> (res: int, ok := true) {
	for {
		idx := index(s^, "mul(") or_return
		s^ = s[idx + 4:]

		a := parse_number(s) or_continue
		consume_rune(s, ',') or_continue
		b := parse_number(s) or_continue
		consume_rune(s, ')') or_continue

		res = a * b
		return
	}
}

part_1 :: proc(input: string) -> (sum: int) {
	input := input

	for product in parse_mul_instr(&input) {
		sum += product
	}

	return
}

part_2 :: proc(input: string) -> (sum: int) {
	input := input

	for part in strings.split_iterator(&input, "do()") {
		part := part

		disable := index(part, "don't()") or_else len(part)
		part = part[:disable]

		for product in parse_mul_instr(&part) {
			sum += product
		}
	}

	return
}

main :: proc() {
	input := os.read_entire_file("day-03/input.txt") or_else panic("Could not read input file")
	defer delete(input)

	input_string := string(input)

	fmt.printfln("Part 1: %i", part_1(input_string))
	fmt.printfln("Part 2: %i", part_2(input_string))
}


@(test)
part1_test :: proc(t: ^testing.T) {
	INPUT :: "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

	testing.expect_value(t, part_1(INPUT), 161)
}

@(test)
part2_test :: proc(t: ^testing.T) {
	INPUT :: "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

	testing.expect_value(t, part_2(INPUT), 48)
}
