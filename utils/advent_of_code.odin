package utils

import "core:flags"
import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strconv"
import "core:strings"
import "core:text/table"
import "core:time"

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
	directory := filepath.base(filepath.dir(loc.file_path))
	assert(strings.has_prefix(directory, "day_"), "Directory needs to start with 'day_'")
	day := strconv.parse_int(directory[4:], 10) or_else panic("Could not parse day")

	opt: Options
	flags.parse_or_exit(&opt, os.args, .Unix)

	// Default file path
	if opt.file == 0 {
		input_file := filepath.join({directory, "input.txt"})

		if file_handle, err := os.open(input_file); err != nil {
			fmt.printfln("Could not open input file %s", input_file)
			os.exit(1)
		} else {
			opt.file = file_handle
		}
	}

	input := os.read_entire_file(opt.file) or_else panic("Could not read input file")
	defer delete(input)

	part1_duration, part2_duration: time.Duration

	{
		start_tick := time.tick_now()
		part1_result = part1(transmute(A)input)
		part1_duration = time.tick_since(start_tick)
	}
	{
		start_tick := time.tick_now()
		part2_result = part2(transmute(B)input)
		part2_duration = time.tick_since(start_tick)
	}

	print_aoc_results(day, part1_result, part2_result, part1_duration, part2_duration)

	return
}

@(private)
print_aoc_results :: proc(day: int, part1, part2: int, duration1, duration2: time.Duration) {
	t := table.init(&table.Table{})
	defer table.destroy(t)

	table.caption(t, table.format(t, "Advent of Code - Day %i", day))
	table.padding(t, 2, 2)
	table.header_of_aligned_values(t, {{.Center, "Part"}, {.Center, "Result"}, {.Center, "Time"}})

	table.row_of_aligned_values(t, {{.Left, "Part 1"}, {.Right, part1}, {.Right, duration1}})
	table.row_of_aligned_values(t, {{.Left, "Part 2"}, {.Right, part2}, {.Right, duration2}})

	table.write_plain_table(os.stream_from_handle(os.stdout), t)
}
