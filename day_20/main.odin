package day_20

import "core:slice"
import "core:testing"

import "../utils"
import "../utils/grid"

Vec2i :: [2]int

Track :: grid.Grid(int)

Neighbors :: [?]Vec2i{{0, 1}, {0, -1}, {1, 0}, {-1, 0}}

calculate_track :: proc(input: []u8) -> Track {
	input_maze := grid.from_seperated(input, '\n')

	start := grid.index_to_xy(
		input_maze,
		slice.linear_search(input_maze.bytes, 'S') or_else panic("Could not find start"),
	)
	end := grid.index_to_xy(
		input_maze,
		slice.linear_search(input_maze.bytes, 'E') or_else panic("Could not find end"),
	)

	track := grid.clone_proc(input_maze, proc(t: u8) -> int {
			if t == '#' do return -1
			return 0
		})

	// Set the value of every track-tile to the distance from the start
	for i := 1; true; i += 1 {
		grid.set(track, start, i)

		if start == end do break

		for n in Neighbors {
			if grid.get(track, start + n) == 0 {
				start += n
				break
			}
		}
	}

	return track
}

count_shortcuts :: proc(
	track: Track,
	max_cheat_length: int,
	min_shortcut_length: int,
) -> (
	shortcuts: int,
) {
	for y1 in 1 ..< track.height - 1 {
		for x1 in 1 ..< track.width - 1 {
			// shortcut needs to start on the track
			first := grid.get(track, {x1, y1})
			if first <= 0 do continue

			// Check every other position in cheat-range
			y2_min := max(1, y1 - max_cheat_length)
			y2_max := min(y1 + max_cheat_length + 1, track.height - 1)
			for y2 in y2_min ..< y2_max {

				x2_min := max(1, x1 - max_cheat_length + abs(y1 - y2))
				x2_max := min(x1 + max_cheat_length + 1 - abs(y1 - y2), track.width - 1)
				for x2 in x2_min ..< x2_max {
					// End-position of the shortcut needs to be farther along than the start
					second := grid.get(track, {x2, y2})
					if second <= first do continue

					// Calculate saved time
					cheat_length := abs(x2 - x1) + abs(y2 - y1)
					saved_time := second - first - cheat_length
					if saved_time >= min_shortcut_length do shortcuts += 1
				}
			}
		}
	}

	return
}

part_1 :: proc(input: []u8, min_shortcut_length := 100) -> (result: int) {
	track := calculate_track(input)
	defer delete(track.bytes)

	return count_shortcuts(track, 2, min_shortcut_length)
}

part_2 :: proc(input: []u8, min_shortcut_length := 100) -> (result: int) {
	track := calculate_track(input)
	defer delete(track.bytes)

	return count_shortcuts(track, 20, min_shortcut_length)
}

main :: proc() {
	part1_wrapper :: proc(input: []u8) -> int {return part_1(input)}
	part2_wrapper :: proc(input: []u8) -> int {return part_2(input)}

	utils.aoc_main(part1_wrapper, part2_wrapper)
}

EXAMPLE_INPUT: string : `###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############
`


@(test)
part1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(transmute([]u8)EXAMPLE_INPUT, 2), 44)
}

@(test)
part2_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(transmute([]u8)EXAMPLE_INPUT, 50), 285)
}
