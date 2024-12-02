package main

import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:testing"
import "core:unicode"

import "../parser"

parse_input :: proc(s: ^string) -> [dynamic][dynamic]int {
	space_parser :: proc(s: ^string) -> (consumed: string, ok: bool) {
		return parser.tag(" ", s)
	}

	report_parser :: proc(s: ^string) -> (report: [dynamic]int, ok := true) {
		report = parser.seperated_list1(space_parser, parser.integer, s) or_return

		return
	}

	result :=
		parser.seperated_list0(parser.newline, report_parser, s) or_else panic(
			"Could not parse input!",
		)

	return result
}

part_1 :: proc(input: string) -> (save_reports: int) {
	input_copy := input

	res := parse_input(&input_copy)
	defer delete(res)

	report_loop: for report in res {
		defer delete(report)

		sign := report[0] < report[1]
		for idx in 0 ..< len(report) - 1 {
			#no_bounds_check {
				a, b := report[idx], report[idx + 1]

				if sign != (a < b) || a == b || abs(a - b) > 3 {
					continue report_loop
				}
			}
		}

		save_reports += 1
	}

	return
}

part_2 :: proc(input: string) -> (save_reports: int) {
	input_copy := input

	res := parse_input(&input_copy)
	defer delete(res)

	for report in res {
		defer delete(report)

		skip_idx :: proc(idx, skipped: int) -> int {
			return idx if idx < skipped else idx + 1
		}

		// Naive implementation for now
		skip_level_loop: for skipped in 0 ..< len(report) {
			sign := report[skip_idx(0, skipped)] < report[skip_idx(1, skipped)]

			for idx in 0 ..< len(report) - 2 {
				a, b := report[skip_idx(idx, skipped)], report[skip_idx(idx + 1, skipped)]

				if sign != (a < b) || a == b || abs(a - b) > 3 {
					continue skip_level_loop
				}

			}

			save_reports += 1
			break
		}
	}

	return
}

main :: proc() {
	input := os.read_entire_file("day-02/input.txt") or_else panic("Could not read input file")
	defer delete(input)

	input_string := string(input)

	fmt.printfln("Part 1: %i", part_1(input_string))
	fmt.printfln("Part 2: %i", part_2(input_string))
}

EXAMPLE_INPUT :: `7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
`


@(test)
part1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(EXAMPLE_INPUT), 2)
}

@(test)
part2_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(EXAMPLE_INPUT), 4)
}
