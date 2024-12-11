package day_01

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"
import "core:testing"

import "../parse"

parse_input :: proc(s: ^string) -> #soa[dynamic][2]int {
	pair_parser :: proc(s: ^string) -> (pair: [2]int, ok := true) {
		pair.x = parse.read_number(s) or_return
		parse.take(s, "   ") or_return
		pair.y = parse.read_number(s) or_return

		return
	}

	list: #soa[dynamic][2]int

	for line in strings.split_lines_iterator(s) {
		line := line

		pair := pair_parser(&line) or_break
		append(&list, pair)
	}

	return list
}

part_1 :: proc(input: string) -> (result: int) {
	input_copy := input

	res := parse_input(&input_copy)
	defer delete(res)

	// Sort slices
	slice.sort(res.x[:len(res)])
	slice.sort(res.y[:len(res)])

	// Sum of absolute differences
	for pair in res {
		result += abs(pair.x - pair.y)
	}

	return
}

part_2 :: proc(input: string) -> (result: int) {
	input_copy := input

	res := parse_input(&input_copy)
	defer delete(res)

	// Count all numbers in right list
	count_map := make(map[int]int)
	defer delete(count_map)
	for pair in res {
		count_map[pair.y] += 1
	}

	// Sum totals
	for pair in res {
		result += pair.x * count_map[pair.x]
	}

	return
}

main :: proc() {
	input :=
		os.read_entire_file(#directory + "/input.txt") or_else panic("Could not read input file")
	defer delete(input)

	input_string := string(input)

	fmt.printfln("Part 1: %i", part_1(input_string))
	fmt.printfln("Part 2: %i", part_2(input_string))
}

EXAMPLE_INPUT :: `3   4
4   3
2   5
1   3
3   9
3   3
`


@(test)
part1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(EXAMPLE_INPUT), 11)
}

@(test)
part2_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(EXAMPLE_INPUT), 31)
}
