package day_07

import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strings"
import "core:testing"

import "../parse"
import "../utils"

parse_line :: proc(s: ^string) -> (target: int, numbers: [dynamic]int, ok := true) {
	target = parse.read_number(s) or_return

	parse.take(s, ": ") or_return

	for {
		value := parse.read_number(s) or_break
		append(&numbers, value)
		parse.take(s, ' ') or_break
	}

	return
}

part_1 :: proc(input: string) -> (test_value_sum: int) {
	// Returns true, if it is possible to reach the total value by combining the numbers with + and * 
	is_possible :: proc(total: int, numbers: []int) -> bool {
		// If there are no more numbers, return true if the total is zero
		if len(numbers) == 0 {
			return total == 0
		}

		rest, last := slice.split_last(numbers)

		// Try '+': Subtract the last number from the total and recursively call is_possible with the remaining numbers
		plus_possible := is_possible(total - last, rest)

		// Try '*': Check if the total cleanly divides into the last number.
		// If it does, recursively call is_possible with the remaining numbers
		mul_possible := (total % last == 0) && is_possible(total / last, rest)

		return plus_possible || mul_possible
	}

	input := input
	for line in strings.split_lines_iterator(&input) {
		line := line

		test_value, numbers := parse_line(&line) or_continue
		defer delete(numbers)

		is_possible(test_value, numbers[:]) or_continue

		test_value_sum += test_value
	}

	return
}

part_2 :: proc(input: string) -> (test_value_sum: int) {
	is_possible :: proc(total: int, numbers: []int) -> bool {
		if len(numbers) == 0 {
			return total == 0
		}

		rest, last := slice.split_last(numbers)

		plus_possible := is_possible(total - last, rest)
		mul_possible := (total % last == 0) && is_possible(total / last, rest)

		// Check if it could have been a concatenation of the numbers
		concat_possible: bool = ---
		{
			// Split the number into two parts, depending on the count of digits of the last number
			left, right := utils.split_int(total, math.count_digits_of_base(last, 10))

			// If the numbers match, recursively call is_possible with the remaining numbers
			concat_possible = right == last && is_possible(left, rest)
		}

		return plus_possible || mul_possible || concat_possible
	}

	input := input
	for line in strings.split_lines_iterator(&input) {
		line := line

		test_value, numbers := parse_line(&line) or_continue
		defer delete(numbers)

		is_possible(test_value, numbers[:]) or_continue

		test_value_sum += test_value
	}

	return
}

main :: proc() {
	input :=
		os.read_entire_file(#directory + "/input.txt") or_else panic("Could not read input file")
	defer delete(input)

	fmt.printfln("Part 1: %i", part_1(string(input)))
	fmt.printfln("Part 2: %i", part_2(string(input)))
}

EXAMPLE_INPUT :: `190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
`


@(test)
part1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(EXAMPLE_INPUT), 3749)
}

@(test)
part2_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(EXAMPLE_INPUT), 11387)
}
