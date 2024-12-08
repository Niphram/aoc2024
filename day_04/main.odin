package day_04

import "core:fmt"
import "core:os"
import "core:strings"
import "core:testing"

import "../utils"
import "../utils/grid"

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

part_2 :: proc(input: []u8) -> (count: int) {
	g := grid.from(input, '\n')

	for x in 1 ..< (g.width - 1) {
		for y in 1 ..< (g.height - 1) {
			if grid.get(g, {x, y}) != 'A' {
				continue
			}

			tl := grid.get(g, {x - 1, y - 1})
			tr := grid.get(g, {x + 1, y - 1})
			bl := grid.get(g, {x - 1, y + 1})
			br := grid.get(g, {x + 1, y + 1})

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
	input := os.read_entire_file("day_04/input.txt") or_else panic("Could not read input file")
	defer delete(input)

	fmt.printfln("Part 1: %i", part_1(string(input)))
	fmt.printfln("Part 2: %i", part_2(input))
}

EXAMPLE_INPUT: string : `MMMSXXMASM
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
	testing.expect_value(t, part_2(transmute([]u8)EXAMPLE_INPUT), 9)
}
