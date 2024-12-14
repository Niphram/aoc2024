package day_14

import "core:fmt"
import "core:os"
import "core:strings"
import "core:testing"

import "../parse"

SHOW_TREE :: #config(SHOW_TREE, false)

Vec2i :: [2]int

Robot :: struct {
	pos: Vec2i,
	vel: Vec2i,
}

parse_input :: proc(s: string) -> [dynamic]Robot {
	s := s
	result := make([dynamic]Robot)

	parse_robot :: proc(s: string) -> (robot: Robot, ok := true) {
		s := s

		parse.take(&s, "p=") or_return
		robot.pos.x = parse.read_number(&s) or_return
		parse.take(&s, ",") or_return
		robot.pos.y = parse.read_number(&s) or_return

		parse.take(&s, " v=") or_return
		robot.vel.x = parse.read_signed_number(&s) or_return
		parse.take(&s, ",") or_return
		robot.vel.y = parse.read_signed_number(&s) or_return

		return
	}

	for line in strings.split_lines_iterator(&s) {
		robot := parse_robot(line) or_continue
		append(&result, robot)
	}

	return result
}

simulate_movement :: proc(robots: []Robot, space: Vec2i) {
	for &r in robots {
		r.pos += r.vel + space
		r.pos %= space
	}
}

part_1 :: proc(input: string, room_size := Vec2i{101, 103}) -> (safety_factor := 1) {
	robots := parse_input(input)
	defer delete(robots)

	for _ in 0 ..< 100 {
		simulate_movement(robots[:], room_size)
	}

	sector_counts: [4]int

	for r in robots {
		if r.pos.x < (room_size.x / 2) && r.pos.y < (room_size.y / 2) {
			sector_counts[0] += 1
		} else if r.pos.x > (room_size.x / 2) && r.pos.y < (room_size.y / 2) {
			sector_counts[1] += 1
		} else if r.pos.x < (room_size.x / 2) && r.pos.y > (room_size.y / 2) {
			sector_counts[2] += 1
		} else if r.pos.x > (room_size.x / 2) && r.pos.y > (room_size.y / 2) {
			sector_counts[3] += 1
		}
	}

	safety_factor *= sector_counts[0]
	safety_factor *= sector_counts[1]
	safety_factor *= sector_counts[2]
	safety_factor *= sector_counts[3]

	return
}

part_2 :: proc(input: string) -> (tokens: int) {
	robots := parse_input(input)
	defer delete(robots)

	// Since the room dimensions are prime numbers, all robots form a cycle that is 101*103 = 10403 long (LCM)
	room_size := Vec2i{101, 103}
	room_cycle := room_size.x * room_size.y

	// By looking at the first 103 iterations you can find obvious clusterings of the robots.
	// Every 101 iterations the robots form a vertical line and every 103 a horizontal line.
	// The first of these instances is the offset in the tree-pattern.
	// In my case, after 70 and 19 iterations respectively
	// Tree is visible when (i-70) % 101 = (i-19) % 103
	// TODO: Solve this equation. So I can just iterate through the first 103 iterations and find the vertical/horizontal offset.

	// Find the average position of all robots and then calculate the average squared distance to that origin
	average_distance_sq :: proc(robots: []Robot) -> int {
		center: Vec2i
		for r in robots {
			center += r.pos
		}
		center /= len(robots)

		dis: int
		for r in robots {
			offset := center - r.pos
			dis += offset.x * offset.x + offset.y * offset.y
		}
		dis /= len(robots)

		return dis
	}

	for i in 0 ..< room_cycle {
		// Simple heuristic that seems to work okay
		if average_distance_sq(robots[:]) < 1000 {
			when SHOW_TREE do print_robots(robots[:], room_size)
			return i
		}

		simulate_movement(robots[:], room_size)
	}

	return -1
}

main :: proc() {
	input :=
		os.read_entire_file(#directory + "/input.txt") or_else panic("Could not read input file")
	defer delete(input)

	when !SHOW_TREE do fmt.println("Run with '-define:SHOW_TREE=true' to print the tree.")

	fmt.printfln("Part 1: %i", part_1(string(input)))
	fmt.printfln("Part 2: %i", part_2(string(input)))
}

EXAMPLE_INPUT: string : `p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3
`


@(test)
part1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(EXAMPLE_INPUT, {11, 7}), 12)
}
