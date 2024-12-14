package utils

import "core:flags"
import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"

@(private)
Options :: struct {
	file: os.Handle `args:"pos=0,file=r" usage:"File containing the puzzle input. Defaults to ./day_XX/input.txt"`,
}

aoc_main :: proc(
	part1: proc(input: $A) -> int,
	part2: proc(input: $B) -> int,
	loc := #caller_location,
) -> (
	part1_result, part2_result: int,
) {
	dir := filepath.dir(loc.file_path)
	dir_name := filepath.base(dir)
	assert(strings.has_prefix(dir_name, "day_"), "Directory needs to start with 'day_'")
	day := dir_name[4:]

	opt: Options
	flags.parse_or_exit(&opt, os.args, .Unix)

	// Default file path
	if opt.file == 0 {
		input_file := filepath.join({dir, "input.txt"})

		if file_handle, err := os.open(input_file); err != nil {
			fmt.printfln("Could not open input file %s", input_file)
			os.exit(1)
		} else {
			opt.file = file_handle
		}
	}

	fmt.printfln("Advent of Code - Day %s", day)

	input := os.read_entire_file(opt.file) or_else panic("Could not read input file")
	defer delete(input)

	part1_result = part1(cast(A)input)
	part2_result = part2(cast(B)input)

	fmt.printfln("Part 1: %i", part1_result)
	fmt.printfln("Part 2: %i", part2_result)

	return
}
