package day_02

import "core:fmt"
import "core:strings"
import "core:testing"

import "../parse"
import "../utils"

parse_line :: proc(s: ^string) -> [dynamic]int {
	list: [dynamic]int

	for {
		value := parse.read_number(s) or_break
		append(&list, value)
		parse.take(s, ' ') or_break
	}

	return list
}

part_1 :: proc(input: string) -> (save_reports: int) {
	input := input

	report_loop: for line in strings.split_lines_iterator(&input) {
		line := line

		report := parse_line(&line)
		defer delete(report)

		sign := report[0] < report[1]
		for idx in 0 ..< len(report) - 1 {
			a, b := report[idx], report[idx + 1]

			if sign != (a < b) || a == b || abs(a - b) > 3 {
				continue report_loop
			}
		}

		save_reports += 1
	}

	return
}

part_2 :: proc(input: string) -> (save_reports: int) {
	input := input

	for line in strings.split_lines_iterator(&input) {
		line := line

		report := parse_line(&line)
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
	utils.aoc_main(part_1, part_2)
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
