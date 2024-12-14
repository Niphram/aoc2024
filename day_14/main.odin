package day_14

import "core:fmt"
import "core:slice"
import "core:strings"
import "core:testing"

import "../parse"
import "../utils"

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

	room_center := room_size / 2

	sector_counts: [4]int
	for r in robots {
		if r.pos.x < room_center.x && r.pos.y < room_center.y {
			sector_counts[0] += 1
		} else if r.pos.x > room_center.x && r.pos.y < room_center.y {
			sector_counts[1] += 1
		} else if r.pos.x < room_center.x && r.pos.y > room_center.y {
			sector_counts[2] += 1
		} else if r.pos.x > room_center.x && r.pos.y > room_center.y {
			sector_counts[3] += 1
		}
	}

	// Product of all sector counts
	return slice.reduce(sector_counts[:], 1, proc(val, acc: int) -> int {
		return val * acc
	})
}

part_2 :: proc(input: string) -> (iterations_until_tree: int) {
	robots := parse_input(input)
	defer delete(robots)

	// Since the room dimensions are prime numbers, all robots form a cycle that is 101*103 = 10403 long (LCM)
	room_size := Vec2i{101, 103}

	// By looking at the first 103 iterations you can find obvious clusterings of the robots.
	// Iterate through the first 103 seconds (after that the horizonal and vertical axis will repeat)
	// Separately calculate the variance of x and y values and keep track of the iteration where it was lowest.
	// These will be the iterations where the robots line up on one axis.
	// In my case, these were after 70 and 19 iterations respectively
	// Then use the Chinese Remainder Theorem to find the iteration where the two cycles overlap

	variance_2d :: proc(robots: []Robot) -> Vec2i {
		// Calculate the mean position of all robots
		mean: Vec2i
		for r in robots do mean += r.pos
		mean /= len(robots)

		// Calculate the variance to the mean
		variance: Vec2i
		for r in robots do variance += (r.pos - mean) * (r.pos - mean)
		return variance / len(robots)
	}

	min_x_variance, min_x_variance_iteration := max(int), 0
	min_y_variance, min_y_variance_iteration := max(int), 0

	// Find the iterations with the lowest variances
	for i in 0 ..< 103 {
		variance := variance_2d(robots[:])

		if variance.x < min_x_variance {
			min_x_variance = variance.x
			min_x_variance_iteration = i
		}

		if variance.y < min_y_variance {
			min_y_variance = variance.y
			min_y_variance_iteration = i
		}

		simulate_movement(robots[:], room_size)
	}

	// Using the Chinese Remainder Theorem
	iterations_until_tree = utils.chinese_remainder_theorem(
		{{min_x_variance_iteration, room_size.x}, {min_y_variance_iteration, room_size.y}},
	)

	// Show tree when config is set
	when SHOW_TREE {
		for _ in iterations_until_tree ..< part2_result do simulate_movement(robots[:], {101, 103})
		print_robots(robots[:], {101, 103})
	} else {
		fmt.println("Run with '-define:SHOW_TREE=true' to print the tree.")
	}

	return
}

main :: proc() {
	utils.aoc_main(proc(input: string) -> int {return part_1(input)}, part_2)
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
