package day_18

import "core:fmt"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:testing"

import "../parse"
import "../utils"
import "../utils/grid"

Vec2i :: [2]int

parse_coords :: proc(s: string) -> (pos: Vec2i, ok := true) {
	s := s

	pos.x = parse.read_number(&s) or_return
	parse.take(&s, ',') or_return
	pos.y = parse.read_number(&s) or_return

	return
}

part_1 :: proc(input: string) -> (result: int) {
	input := input

	ROOM := Vec2i{70, 70}

	memory := grid.Grid(bool) {
		width  = ROOM.x + 1,
		height = ROOM.y + 1,
		bytes  = make([]bool, (ROOM.x + 1) * (ROOM.y + 1)),
	}
	defer delete(memory.bytes)

	fallen := 0
	for line in strings.split_lines_iterator(&input) {
		if fallen >= 1024 do break
		fallen += 1

		pos := parse_coords(line) or_continue
		grid.set(memory, pos, true)
	}

	shortest_path := a_star_exhaustive(memory, {0, 0}, ROOM)

	return shortest_path
}

part_2 :: proc(input: string) -> (result: string) {
	input := input

	ROOM := Vec2i{70, 70}

	memory := grid.Grid(bool) {
		width  = ROOM.x + 1,
		height = ROOM.y + 1,
		bytes  = make([]bool, (ROOM.x + 1) * (ROOM.y + 1)),
	}
	defer delete(memory.bytes)

	// Very naive implementation, but still computes in under a minute on this old laptop (<13sec when compiling an -o:speed build)
	for line in strings.split_lines_iterator(&input) {
		pos := parse_coords(line) or_continue
		grid.set(memory, pos, true)

		lowest_cost := a_star_exhaustive(memory, {0, 0}, ROOM)

		if lowest_cost == max(int) {
			fmt.println(pos)

			b :=
				strings.builder_init_len(&strings.Builder{}, 5) or_else panic(
					"Could not initialize string builder",
				)

			strings.write_int(b, pos.x)
			strings.write_rune(b, ',')
			strings.write_int(b, pos.y)

			return cast(string)b.buf[:]
		}
	}

	return ""
}

main :: proc() {
	utils.aoc_main(part_1, part_2)
}

EXAMPLE_1: string : ``


EXAMPLE_2: string : ``

// TODO: Adjust tests

@(test)
part1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(EXAMPLE_1), 140)
}

@(test)
part2_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(EXAMPLE_2), "")
}
