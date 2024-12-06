package day_06

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"
import "core:testing"

import "../parse"
import "../utils"
import "../utils/grid"

Direction :: enum {
	North,
	East,
	South,
	West,
}

Direction_Vectors := [Direction][2]int {
	.North = {0, -1},
	.East  = {+1, 0},
	.South = {0, +1},
	.West  = {-1, 0},
}

Direction_Symbols := [Direction]u8 {
	.North = '^',
	.East  = '>',
	.South = 'v',
	.West  = '<',
}

part_1 :: proc(input: []u8) -> (visited_cells: int) {
	input_copy := slice.clone(input)
	defer delete(input_copy)

	g := grid.from_seperated(input_copy, '\n')

	start_idx :=
		slice.linear_search(g.bytes, '^') or_else panic("Could not determine starting position")

	pos: [2]int
	pos.x, pos.y = grid.index_to_xy(g, start_idx)
	dir := Direction.North

	step_loop: for {
		g.bytes[grid.xy_to_index(g, pos.x, pos.y)] = '+'

		for {
			next_pos := Direction_Vectors[dir] + pos
			(grid.in_bounds(g, next_pos.x, next_pos.y)) or_break step_loop
			(grid.get(g, next_pos.x, next_pos.y) == '#') or_break
			dir = Direction((int(dir) + 1) % 4)
		}

		pos += Direction_Vectors[dir]
	}

	return slice.count(g.bytes, '+')
}

part_2 :: proc(input: []u8) -> (obstacle_positions: int) {

	g := grid.from_seperated(input, '\n')

	start_idx :=
		slice.linear_search(g.bytes, '^') or_else panic("Could not determine starting position")

	for x in 0 ..< g.width {
		for y in 0 ..< g.height {
			input_copy := slice.clone(input)
			defer delete(input_copy)
			g.bytes = input_copy

			if grid.get(g, x, y) != '.' {
				continue
			}

			g.bytes[grid.xy_to_index(g, x, y)] = '#'

			pos: [2]int
			pos.x, pos.y = grid.index_to_xy(g, start_idx)
			dir := Direction.North


			step_loop: for {
				for {
					next_pos := Direction_Vectors[dir] + pos
					(grid.in_bounds(g, next_pos.x, next_pos.y)) or_break step_loop
					(grid.get(g, next_pos.x, next_pos.y) == '#') or_break
					dir = Direction((int(dir) + 1) % 4)
				}

				pos += Direction_Vectors[dir]

				if grid.get(g, pos.x, pos.y) == Direction_Symbols[dir] {
					obstacle_positions += 1
					break
				}

				g.bytes[grid.xy_to_index(g, pos.x, pos.y)] = Direction_Symbols[dir]
			}

		}
	}


	return
}

main :: proc() {
	input := os.read_entire_file("day_06/input.txt") or_else panic("Could not read input file")
	defer delete(input)

	fmt.printfln("Part 1: %i", part_1(input))
	fmt.printfln("Part 2: %i", part_2(input))
}

EXAMPLE_INPUT: string : `....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
`


@(test)
part1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(transmute([]u8)EXAMPLE_INPUT), 41)
}

@(test)
part2_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(transmute([]u8)EXAMPLE_INPUT), 6)
}
