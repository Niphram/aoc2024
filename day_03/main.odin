package day_03

import "core:fmt"
import "core:strings"
import "core:testing"

import "../parse"
import "../utils"

parse_mul_instr :: proc(s: ^string) -> (res: int, ok := true) {
	for {
		parse.seek_after(s, "mul(") or_return

		a := parse.read_number(s) or_continue
		parse.take(s, ',') or_continue
		b := parse.read_number(s) or_continue
		parse.take(s, ')') or_continue

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

		disable := parse.first_index(part, "don't()") or_else len(part)
		part = part[:disable]

		for product in parse_mul_instr(&part) {
			sum += product
		}
	}

	return
}

main :: proc() {
	utils.aoc_main(part_1, part_2)
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
