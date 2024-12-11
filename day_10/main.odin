package day_10

import "core:fmt"
import "core:os"
import "core:testing"

import "../utils/grid"

Vec2i :: [2]int
TopoMap :: grid.Grid(u8)
HashSet :: map[Vec2i]struct {}

NEIGHBORS :: [4]Vec2i{{0, -1}, {1, 0}, {0, 1}, {-1, 0}}

count_trails :: proc(
	tm: TopoMap,
	start_pos: Vec2i,
	end_positions: Maybe(^HashSet) = nil,
) -> (
	possible_trails: int,
) {
	current := grid.get(tm, start_pos)
	if current == '9' {
		// Add the end to the hashset, if one is passed in
		if hs, ok := end_positions.(^HashSet); ok do hs[start_pos] = {}
		return 1
	}

	// Check all neighbors and continue trail if possible
	for n in NEIGHBORS {
		if v, ok := grid.get_safe(tm, start_pos + n).(u8); ok && v == (current + 1) {
			possible_trails += count_trails(tm, start_pos + n, end_positions)
		}
	}

	return
}

part_1 :: proc(input: []u8) -> (reachable_trailheads: int) {
	hiking_map := grid.from_seperated(input, '\n')

	trail_ends: HashSet
	defer delete(trail_ends)

	for t, i in hiking_map.bytes {
		if t == '0' {
			count_trails(hiking_map, grid.index_to_xy(hiking_map, i), &trail_ends)

			reachable_trailheads += len(trail_ends)
			clear(&trail_ends)
		}
	}

	return
}

part_2 :: proc(input: []u8) -> (possible_trails: int) {
	hiking_map := grid.from_seperated(input, '\n')


	for t, i in hiking_map.bytes {
		if t == '0' {
			possible_trails += count_trails(hiking_map, grid.index_to_xy(hiking_map, i))
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

EXAMPLE_INPUT: string : `89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
`


@(test)
part1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(transmute([]u8)EXAMPLE_INPUT), 36)
}

@(test)
part2_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(transmute([]u8)EXAMPLE_INPUT), 81)
}
