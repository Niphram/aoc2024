package day_08

import "core:fmt"
import "core:testing"

import "../utils"
import "../utils/grid"

Vec2i :: [2]int

collect_antennas :: proc(g: grid.Grid(u8)) -> map[u8][dynamic]Vec2i {
	antennae: map[u8][dynamic]Vec2i

	for y in 0 ..< g.height {
		for x in 0 ..< g.width {
			if a := grid.get(g, {x, y}); a != '.' {
				antennae_list := antennae[a]
				append(&antennae_list, Vec2i{x, y})
				antennae[a] = antennae_list
			}
		}
	}

	return antennae
}

delete_antennas :: proc(m: map[u8][dynamic]Vec2i) {
	for _, value in m do delete(value)
	delete(m)
}

part_1 :: proc(input: []u8) -> (antinodes_count: int) {
	g := grid.from_seperated(input, '\n')

	antennas := collect_antennas(g)
	defer delete_antennas(antennas)

	antinodes: map[Vec2i]struct {}
	defer delete(antinodes)

	for _, antennas in antennas {
		for a1, i in antennas {
			for a2 in antennas[i + 1:] {
				diff := a2 - a1

				if antinode := a1 - diff; grid.in_bounds(g, antinode) {
					antinodes[antinode] = struct {}{}
				}

				if antinode := a2 + diff; grid.in_bounds(g, antinode) {
					antinodes[antinode] = struct {}{}
				}
			}
		}
	}

	return len(antinodes)
}

part_2 :: proc(input: []u8) -> (antinodes_count: int) {
	g := grid.from_seperated(input, '\n')

	antennas_map := collect_antennas(g)
	defer delete_antennas(antennas_map)

	antinodes: map[Vec2i]struct {}
	defer delete(antinodes)

	for _, antenna_list in antennas_map {
		for a1, i in antenna_list {
			for a2 in antenna_list[i + 1:] {
				diff := a2 - a1

				// Repeatedly subtract the difference between the antennas from a1
				for antinode := a1; grid.in_bounds(g, antinode); antinode -= diff {
					antinodes[antinode] = struct {}{}
				}

				// Repeatedly add the difference between the antennas to a2
				for antinode := a2; grid.in_bounds(g, antinode); antinode += diff {
					antinodes[antinode] = struct {}{}
				}
			}
		}
	}

	return len(antinodes)
}

main :: proc() {
	utils.aoc_main(part_1, part_2)
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
