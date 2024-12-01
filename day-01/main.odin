package main

import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode"

import "../utils"

main :: proc() {
	input := os.read_entire_file("day-01/input.txt") or_else panic("Could not read input file")
	defer delete(input)

	input_string := string(input)

	// Input lists
	left_list: [dynamic]int
	right_list: [dynamic]int
	defer delete(left_list)
	defer delete(right_list)

	// Parse input
	for line in utils.split_lines_iterator_trim(&input_string) {
		left, right := utils.split_once(line, "   ") or_else panic("Could not parse input")

		append(&left_list, strconv.atoi(left))
		append(&right_list, strconv.atoi(right))
	}

	// Sort lists
	slice.sort(left_list[:])
	slice.sort(right_list[:])

	// Part 1
	{
		diff_sum: int
		for pair in soa_zip(l = left_list[:], r = right_list[:]) {
			diff_sum += abs(pair.l - pair.r)
		}

		fmt.printfln("Part 1: %i", diff_sum)
	}

	// Part 2
	{

		// Count all numbers in right map
		count_map: map[int]int
		defer delete(count_map)
		for r in right_list {
			count_map[r] += 1
		}

		// Sum totals
		total: int
		for l in left_list {
			total += l * count_map[l]
		}

		fmt.printfln("Part 2: %i", total)
	}
}
