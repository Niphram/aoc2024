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

calculate_checksum :: proc(files: []MemoryRegion) -> int {
	checksum: int

	for f in files {
		for m in f.offset ..< (f.offset + f.size) {
			checksum += m * f.id
		}
	}

	return checksum
}

part_1 :: proc(input: []u8) -> (checksum: int) {
	files, gaps := parse_disk(input)
	defer delete(files)
	defer delete(gaps)

	file_ptr := len(files) - 1
	for &gap, gi in gaps {
		// No more files to fill gaps with
		if gi >= file_ptr do break

		for gap.size > 0 {
			file := &files[file_ptr]

			if gap.size >= file.size {
				// File fits into the gap
				file.offset = gap.offset
				gap.size -= file.size
				gap.offset += file.size

				file_ptr -= 1
			} else {
				// File partially fits
				file_part := file^
				file_part.size = gap.size
				file_part.offset = gap.offset
				append(&files, file_part)

				// Remaining file
				file.size -= gap.size
				gap.size = 0
			}
		}
	}

	return calculate_checksum(files[:])
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
