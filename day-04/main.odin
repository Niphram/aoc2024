package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:testing"

import "../utils"

part_1 :: proc(input: string) -> (count: int) {
	line_len := strings.index_rune(input, '\n') + 1

	// horizontal
	count += utils.count_with_stride(input, "XMAS", 1)
	count += utils.count_with_stride(input, "SAMX", 1)

	// vertical
	count += utils.count_with_stride(input, "XMAS", line_len)
	count += utils.count_with_stride(input, "SAMX", line_len)

	// diagonal down-right
	count += utils.count_with_stride(input, "XMAS", line_len + 1)
	count += utils.count_with_stride(input, "SAMX", line_len + 1)

	// diagonal down-left
	count += utils.count_with_stride(input, "XMAS", line_len - 1)
	count += utils.count_with_stride(input, "SAMX", line_len - 1)

	return
}

part_2 :: proc(input: string) -> (count: int) {
	grid := utils.grid_from_string(input)

	for x in 1 ..< (grid.width - 1) {
		for y in 1 ..< (grid.height - 1) {
			if utils.index_grid(grid, x, y) != 'A' {
				continue
			}

			tl := utils.index_grid(grid, x - 1, y - 1)
			tr := utils.index_grid(grid, x + 1, y - 1)
			bl := utils.index_grid(grid, x - 1, y + 1)
			br := utils.index_grid(grid, x + 1, y + 1)

			if (tl + br) != ('M' + 'S') {
				continue
			}

			if (tr + bl) != ('M' + 'S') {
				continue
			}

			count += 1
		}
	}

	return
}

main :: proc() {
	input := os.read_entire_file("day-04/input.txt") or_else panic("Could not read input file")
	defer delete(input)

	input_string := string(input)

	fmt.printfln("Part 1: %i", part_1(input_string))
	fmt.printfln("Part 2: %i", part_2(input_string))
}

EXAMPLE_INPUT :: `MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
`


@(test)
part1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(EXAMPLE_INPUT), 18)
}

@(test)
part2_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(EXAMPLE_INPUT), 9)
}
