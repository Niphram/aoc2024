package day_15

import "core:fmt"
import "core:slice"
import "core:strings"
import "core:testing"

import "../parse"
import "../utils"
import "../utils/grid"

Grid :: grid.Grid(u8)


part_1 :: proc(input: string) -> int {
	map_string, moves := utils.split_once(input, "\n\n") or_else panic("Invalid input")
	warehouse := grid.from_seperated(transmute([]u8)strings.clone(map_string), '\n')
	defer delete(warehouse.bytes)

	start_idx :=
		slice.linear_search(warehouse.bytes, '@') or_else panic(
			"Could not determine starting position",
		)
	warehouse.bytes[start_idx] = '.'
	pos := grid.index_to_xy(warehouse, start_idx)

	for m in moves {
		dir: [2]int

		switch m {
		case '^':
			dir = {0, -1}
		case '>':
			dir = {+1, 0}
		case 'v':
			dir = {0, +1}
		case '<':
			dir = {-1, 0}
		case:
			continue
		}

		// fmt.println(string(warehouse.bytes), pos, m)

		found_boxes := 0
		safe_space := pos

		step_loop: for tile in grid.get_safe(warehouse, pos + dir) {
			switch tile {
			case '.':
				pos += dir
				break step_loop
			case '#':
				break step_loop
			case 'O':
				search_pos := pos + dir
				for tile in grid.get_safe(warehouse, search_pos + dir) {
					switch tile {
					case '#':
						break step_loop
					case '.':
						grid.set(warehouse, search_pos + dir, 'O')
						grid.set(warehouse, pos + dir, '.')
						pos += dir
						break step_loop
					case 'O':
						search_pos += dir
					}
				}
			}
		}
	}

	gps := 0

	for y in 1 ..< warehouse.height - 1 {
		for x in 1 ..< warehouse.width - 1 {
			if grid.get(warehouse, {x, y}) == 'O' {
				gps += x + 100 * y
			}
		}
	}

	return gps
}

part_2 :: proc(input: string) -> int {
	map_string, moves := utils.split_once(input, "\n\n") or_else panic("Invalid input")


	warehouse: map[[2]int]u8
	defer delete(warehouse)

	pos: [2]int
	{
		temp_grid := grid.from_seperated(transmute([]u8)map_string, '\n')

		for y in 0 ..< temp_grid.height {
			for x in 0 ..< temp_grid.width {
				switch grid.get(temp_grid, {x, y}) {
				case '#':
					warehouse[{2 * x, y}] = '#'
				case 'O':
					warehouse[{2 * x, y}] = 'O'
				case '@':
					pos = {2 * x, y}
				}
			}
		}
	}

	print :: proc(warehouse: map[[2]int]u8, robot: [2]int) {
		width, height := 20, 10

		for y := 0; y < height; y += 1 {
			for x := 0; x < width; x += 1 {

				if robot == {x, y} {
					fmt.print("@")
				} else {
					switch warehouse[{x, y}] {
					case 0:
						fmt.print('.')
					case '#':
						fmt.print("##")
						x += 1
					case 'O':
						fmt.print("[]")
						x += 1
					}
				}
			}
			fmt.println("")
		}
	}

	can_push :: proc(warehouse: map[[2]int]u8, pos, dir: [2]int, is_box := false) -> bool {
		switch dir {
		case {0, 1}, {0, -1}:
			a, b, c :=
				warehouse[pos + dir + {-1, 0}], warehouse[pos + dir], warehouse[pos + dir + {1, 0}]

			if a == '#' || b == '#' || (is_box && c == '#') do return false

			if a == 'O' && !can_push(warehouse, pos + dir + {-1, 0}, dir, true) do return false
			if b == 'O' && !can_push(warehouse, pos + dir, dir, true) do return false
			if is_box && c == 'O' && !can_push(warehouse, pos + dir + {+1, 0}, dir, true) do return false

			return true
		case {-1, 0}:
			a := warehouse[pos + dir + dir]
			if a == '#' do return false
			if a == 'O' && !can_push(warehouse, pos + dir + dir, dir, true) do return false

			return true
		case {+1, 0}:
			check_pos := pos + dir
			if is_box do check_pos += dir

			a := warehouse[check_pos]
			if a == '#' do return false
			if a == 'O' && !can_push(warehouse, check_pos, dir, true) do return false

			return true
		case:
			panic("???")
		}
	}

	do_push :: proc(warehouse: ^map[[2]int]u8, pos, dir: [2]int, is_box := false) {
		switch dir {
		case {0, 1}, {0, -1}:
			a, b, c :=
				warehouse[pos + dir + {-1, 0}], warehouse[pos + dir], warehouse[pos + dir + {1, 0}]

			if a == '#' || b == '#' || (is_box && c == '#') do return

			if a == 'O' do do_push(warehouse, pos + dir + {-1, 0}, dir, true)
			if b == 'O' do do_push(warehouse, pos + dir, dir, true)
			if is_box && c == 'O' do do_push(warehouse, pos + dir + {+1, 0}, dir, true)

			warehouse[pos + dir] = warehouse[pos]
			warehouse[pos] = 0
		case {-1, 0}:
			a := warehouse[pos + dir + dir]
			if a == '#' do return
			if a == 'O' do do_push(warehouse, pos + dir + dir, dir, true)

			warehouse[pos + dir] = warehouse[pos]
			warehouse[pos] = 0
		case {+1, 0}:
			check_pos := pos + dir
			if is_box do check_pos += dir

			a := warehouse[check_pos]
			if a == '#' do return
			if a == 'O' do do_push(warehouse, check_pos, dir, true)

			warehouse[pos + dir] = warehouse[pos]
			warehouse[pos] = 0
		case:
			panic("???")
		}
	}

	for m in moves {
		dir: [2]int

		switch m {
		case '^':
			dir = {0, -1}
		case '>':
			dir = {+1, 0}
		case 'v':
			dir = {0, +1}
		case '<':
			dir = {-1, 0}
		case:
			continue
		}

		// print(warehouse, pos)

		if can_push(warehouse, pos, dir) {
			do_push(&warehouse, pos, dir)
			pos += dir
		}
	}

	gps := 0

	for pos, v in warehouse {
		if v == 'O' {
			gps += pos.x + 100 * pos.y
		}
	}

	return gps
}

main :: proc() {
	utils.aoc_main(part_1, part_2)
}

EXAMPLE_INPUT: string : ``


@(test)
part1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(EXAMPLE_INPUT), 0)
}

@(test)
part2_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(EXAMPLE_INPUT), 0)
}
