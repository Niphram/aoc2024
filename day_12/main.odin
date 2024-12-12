package day_12

import "core:fmt"
import "core:os"
import "core:testing"

import "../utils/grid"

Vec2i :: [2]int
Grid :: grid.Grid(u8)

NEIGHBORS_4 :: [4]Vec2i{{0, -1}, {+1, 0}, {0, +1}, {-1, 0}}
NEIGHBORS_DIAG :: [?]Vec2i{{+1, +1}, {+1, -1}, {-1, +1}, {-1, -1}}

HashSet :: map[Vec2i]struct {}

fence :: proc(g: ^Grid, starting_pos: Vec2i) -> (cost: int) {
	region := grid.get(g^, starting_pos)

	to_check := [dynamic]Vec2i{starting_pos}
	defer delete(to_check)


	area: HashSet
	defer delete(area)

	for pos in pop_safe(&to_check) {
		if grid.get(g^, pos) != region do continue

		area[pos] = {}

		for n in NEIGHBORS_4 {
			if (pos + n) in area do continue

			if grid.in_bounds(g^, pos + n) {
				append(&to_check, pos + n)
			}
		}
	}

	fences := 0

	for k in area {
		for n in NEIGHBORS_4 {
			if (k + n) not_in area {
				fences += 1
			}
		}

		grid.set(g^, k, 0)
	}

	return len(area) * fences
}

fence2 :: proc(g: ^Grid, starting_pos: Vec2i) -> (cost: int) {
	region := grid.get(g^, starting_pos)

	to_check := [dynamic]Vec2i{starting_pos}
	defer delete(to_check)


	area: HashSet
	defer delete(area)

	for pos in pop_safe(&to_check) {
		if grid.get(g^, pos) != region do continue

		area[pos] = {}

		for n in NEIGHBORS_4 {
			if (pos + n) in area do continue

			if grid.in_bounds(g^, pos + n) {
				append(&to_check, pos + n)
			}
		}
	}


	fences: HashSet
	defer delete(fences)

	corners := 0

	for k in area {

		neighbors: bit_set[0 ..< 8]

		for n, i in NEIGHBORS_4 {
			if (k + n) in area {
				neighbors += {i}
			}
		}

		switch neighbors {
		// Single
		case {}:
			corners += 4
		// Only one neighbor
		case {0}, {1}, {2}, {3}:
			corners += 2
		case {0, 1}:
			corners += 1
			if (k + {+1, -1}) not_in area do corners += 1
		case {1, 2}:
			corners += 1
			if (k + {+1, +1}) not_in area do corners += 1
		case {2, 3}:
			corners += 1
			if (k + {-1, +1}) not_in area do corners += 1
		case {3, 0}:
			corners += 1
			if (k + {-1, -1}) not_in area do corners += 1

		// T-Pieces
		case {1, 2, 3}:
			if (k + {-1, +1}) not_in area do corners += 1
			if (k + {+1, +1}) not_in area do corners += 1
		case {0, 2, 3}:
			if (k + {-1, -1}) not_in area do corners += 1
			if (k + {-1, +1}) not_in area do corners += 1
		case {0, 1, 3}:
			if (k + {-1, -1}) not_in area do corners += 1
			if (k + {+1, -1}) not_in area do corners += 1
		case {0, 1, 2}:
			if (k + {+1, +1}) not_in area do corners += 1
			if (k + {+1, -1}) not_in area do corners += 1

		case {0, 1, 2, 3}:
			for n, i in NEIGHBORS_DIAG {
				if (k + n) not_in area {
					corners += 1
				}
			}
		}

		grid.set(g^, k, 0)
	}


	//fmt.println("Area starting at", starting_pos, rune(region), len(area), corners)

	return len(area) * corners
}

part_1 :: proc(input: []u8) -> (cost: int) {

	g := grid.clone(grid.from_seperated(input, '\n'))
	defer delete(g.bytes)

	for y in 0 ..< g.height {
		for x in 0 ..< g.width {
			if grid.get(g, {x, y}) != 0 {
				cost += fence(&g, {x, y})
			}
		}
	}

	return
}

part_2 :: proc(input: []u8) -> (cost: int) {
	g := grid.clone(grid.from_seperated(input, '\n'))
	defer delete(g.bytes)

	for y in 0 ..< g.height {
		for x in 0 ..< g.width {
			if grid.get(g, {x, y}) != 0 {
				cost += fence2(&g, {x, y})
			}
		}
	}
	return
}

main :: proc() {
	input :=
		os.read_entire_file(#directory + "/input.txt") or_else panic("Could not read input file")
	defer delete(input)

	fmt.printfln("Part 1: %i", part_1(input))
	fmt.printfln("Part 2: %i", part_2(input))
}

EXAMPLE_INPUT: string : `............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............
`


@(test)
part1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(transmute([]u8)EXAMPLE_INPUT), 14)
}

@(test)
part2_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(transmute([]u8)EXAMPLE_INPUT), 34)
}
