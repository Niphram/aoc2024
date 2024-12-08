package day_06

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"
import "core:testing"

import "../parse"
import "../utils"
import "../utils/grid"

Vec2i :: [2]int

StepStatus :: enum {
	NewTile,
	Normal,
	OutOfBounds,
	Loop,
}

Direction :: enum {
	North,
	East,
	South,
	West,
}

Direction_Vectors := [Direction]Vec2i {
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

Map :: grid.Grid(u8)

Guard :: struct {
	pos: Vec2i,
	dir: Direction,
}

next_pos :: proc(m: Map, guard: Guard) -> Maybe(Vec2i) {
	pos := Direction_Vectors[guard.dir] + guard.pos
	if !grid.in_bounds(m, pos) do return nil

	return pos
}

simulate_step :: proc(m: Map, guard: ^Guard) -> (status: StepStatus) {
	loop: for {
		pos, in_bounds := next_pos(m, guard^).(Vec2i)
		if !in_bounds do return .OutOfBounds

		switch grid.get(m, pos) {
		case Direction_Symbols[guard.dir]:
			return .Loop
		case '#':
			guard.dir = Direction((int(guard.dir) + 1) % 4)
		case:
			break loop
		}
	}

	guard.pos += Direction_Vectors[guard.dir]
	status = .NewTile if grid.get(m, guard.pos) == '.' else .Normal
	grid.set(m, guard.pos, Direction_Symbols[guard.dir])

	return
}

simulate_guard :: proc(m: Map, guard: Guard) -> (infinite: bool) {
	guard := guard

	for {
		switch simulate_step(m, &guard) {
		case .OutOfBounds:
			return false
		case .Loop:
			return true
		case .Normal, .NewTile:
			continue
		}
	}

	return false
}

part_1 :: proc(input: []u8) -> (visited_cells: int) {
	input := slice.clone(input)
	defer delete(input)
	lab_map := grid.from_seperated(input, '\n')

	start_idx :=
		slice.linear_search(lab_map.bytes, '^') or_else panic(
			"Could not determine starting position",
		)

	guard := Guard {
		pos = grid.index_to_xy(lab_map, start_idx),
		dir = Direction.North,
	}

	simulate_guard(lab_map, guard)

	return slice.count_proc(lab_map.bytes, proc(t: u8) -> bool {
		switch t {
		case '^', '>', 'v', '<':
			return true
		case:
			return false
		}
	})
}

part_2 :: proc(input: []u8) -> (obstacle_positions: int) {
	input := slice.clone(input)
	defer delete(input)
	lab_map := grid.from_seperated(input, '\n')

	start_idx :=
		slice.linear_search(lab_map.bytes, '^') or_else panic(
			"Could not determine starting position",
		)

	guard := Guard {
		pos = grid.index_to_xy(lab_map, start_idx),
		dir = Direction.North,
	}

	for {
		cloned_map := grid.clone(lab_map)
		defer delete(cloned_map.bytes)
		prev_guard := guard

		step_status := simulate_step(lab_map, &guard)

		if step_status == .OutOfBounds do return

		if step_status == .NewTile {
			grid.set(cloned_map, guard.pos, '#')
			if simulate_guard(cloned_map, prev_guard) do obstacle_positions += 1
		}
	}
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
