package day_09

import "core:fmt"
import "core:os"
import "core:testing"

MemoryRegion :: struct {
	id:     int,
	offset: int,
	size:   int,
}

parse_disk :: proc(input: []u8) -> (files, gaps: [dynamic]MemoryRegion) {
	memory_idx := 0

	for b, i in input {
		region := MemoryRegion {
			id     = i / 2,
			offset = memory_idx,
			size   = int(input[i]) - '0',
		}

		memory_idx += region.size

		if i % 2 == 0 do append(&files, region)
		else do append(&gaps, region)
	}

	return
}

calculate_checksum :: proc {
	calculate_checksum_region,
	calculate_checksum_slice,
}

calculate_checksum_region :: proc(region: MemoryRegion) -> int {
	return region.id * region.size * (2 * region.offset + region.size - 1) / 2
}

calculate_checksum_slice :: proc(files: []MemoryRegion) -> int {
	checksum: int

	for f in files {
		checksum += calculate_checksum_region(f)
	}

	return checksum
}

part_1 :: proc(input: []u8) -> (checksum: int) {
	files, gaps := parse_disk(input)
	defer delete(files)
	defer delete(gaps)

	lower_ptr := 0
	upper_ptr := len(files) - 1

	for ; lower_ptr <= upper_ptr; lower_ptr += 1 {
		// Fill the gap with files from the right
		for gap := gaps[lower_ptr]; gap.size > 0 && lower_ptr < upper_ptr; {
			file := &files[upper_ptr]

			min_size := min(gap.size, file.size)

			// Calculate the checksum of the moved file (might be truncated, if the file could not fit)
			checksum += calculate_checksum(
				MemoryRegion{id = file.id, offset = gap.offset, size = min_size},
			)

			// Update memory region
			file.size -= min_size
			gap.offset += min_size
			gap.size -= min_size

			// Continue with next file
			if file.size == 0 do upper_ptr -= 1
		}

		// File on the left is positioned correctly
		checksum += calculate_checksum(files[lower_ptr])
	}

	return
}

part_2 :: proc(input: []u8) -> (checksum: int) {
	files, gaps := parse_disk(input)
	defer delete(files)
	defer delete(gaps)

	#reverse for &f, fi in files {
		for &g, gi in gaps[:fi] {
			if g.size >= f.size {
				g.size -= f.size
				f.offset = g.offset
				g.offset += f.size
				break
			}
		}
	}

	return calculate_checksum(files[:])
}

main :: proc() {
	input := os.read_entire_file("day_09/input.txt") or_else panic("Could not read input file")
	defer delete(input)

	fmt.printfln("Part 1: %i", part_1(input))
	fmt.printfln("Part 2: %i", part_2(input))
}

EXAMPLE_INPUT: string : `2333133121414131402`


@(test)
part1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(transmute([]u8)EXAMPLE_INPUT), 1928)
}

@(test)
part2_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(transmute([]u8)EXAMPLE_INPUT), 2858)
}
