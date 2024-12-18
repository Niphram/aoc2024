package day_18

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

create_memory :: proc(space: Vec2i) -> grid.Grid(bool) {
	memory_size := space + {1, 1}

	memory := grid.Grid(bool) {
		width  = memory_size.x,
		height = memory_size.y,
		bytes  = make([]bool, memory_size.x * memory_size.y),
	}

	return memory
}

corrupt_memory_iterator :: proc(
	memory: grid.Grid(bool),
	input: ^string,
) -> (
	pos: Vec2i,
	ok := true,
) {
	line := strings.split_lines_iterator(input) or_return
	pos = parse_coords(line) or_return
	grid.set(memory, pos, true)

	return
}

part_1 :: proc(input: string, space: Vec2i, iterations: int) -> (result: int) {
	input := input

	memory := create_memory(space)
	defer delete(memory.bytes)

	for _ in 0 ..< iterations {
		corrupt_memory_iterator(memory, &input) or_break
	}

	shortest_path := a_star(memory, {0, 0}, space)

	return shortest_path
}

part_2 :: proc(input: string, space: Vec2i, skip_iterations: int) -> (result: string) {
	input := input

	b := strings.builder_init_len_cap(&strings.Builder{}, 0, 5)

	memory := create_memory(space)
	defer delete(memory.bytes)

	// Skip the iterations from part 1. We already know there is still a path
	for _ in 0 ..< skip_iterations {
		corrupt_memory_iterator(memory, &input) or_break
	}

	// Just recalculate the shortest distance after every corrupted byte. Good enough
	for pos in corrupt_memory_iterator(memory, &input) {
		// No path was found
		if a_star(memory, {0, 0}, space) == max(int) {
			strings.write_int(b, pos.x)
			strings.write_rune(b, ',')
			strings.write_int(b, pos.y)

			break
		}
	}

	return string(b.buf[:])
}

main :: proc() {
	MEMORY_SPACE :: Vec2i{70, 70}
	ITERATIONS :: 1024

	part1_wrapper :: proc(input: string) -> int {
		return part_1(input, MEMORY_SPACE, ITERATIONS)
	}

	part2_wrapper :: proc(input: string) -> string {
		return part_2(input, MEMORY_SPACE, ITERATIONS)
	}

	part1_result, part2_result := utils.aoc_main(part1_wrapper, part2_wrapper)
	delete(part2_result)
}

EXAMPLE_INPUT: string : `5,4
4,2
4,5
3,0
2,1
6,3
2,4
1,5
0,6
3,3
2,6
5,1
1,2
5,5
2,5
6,5
1,4
0,4
6,4
1,1
6,1
1,0
0,5
1,6
2,0
`


@(test)
part1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(EXAMPLE_INPUT, {6, 6}, 12), 22)
}

@(test)
part2_test :: proc(t: ^testing.T) {
	result := part_2(EXAMPLE_INPUT, {6, 6}, 12)
	defer delete(result)
	testing.expect_value(t, result, "6,1")
}
