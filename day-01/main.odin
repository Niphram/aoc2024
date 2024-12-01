package main

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode"

main :: proc() {
	input := os.read_entire_file("day-01/input.txt", context.allocator) or_else os.exit(1)
	defer delete(input, context.allocator)

	it := string(input)

	left_list: [dynamic]int
	defer delete(left_list)
	right_list: [dynamic]int
	defer delete(right_list)

	for line in strings.split_lines_iterator(&it) {
		parts := strings.split(line, "   ") or_else os.exit(-1)

		append(&left_list, strconv.atoi(parts[0]))
		append(&right_list, strconv.atoi(parts[1]))
	}

	slice.sort(left_list[:])
	slice.sort(right_list[:])

	zipped := soa_zip(l = left_list[:], r = right_list[:])

	{
		diff_sum: int
		for pair in zipped {
			diff_sum += abs(pair.l - pair.r)
		}
		fmt.println(diff_sum)
	}
	//// PART 2
	{
		total: int
		for l in left_list {
			total += l * slice.count(right_list[:], l)
		}
		fmt.println(total)
	}
}
