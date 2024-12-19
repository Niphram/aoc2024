package day_19

import "core:strings"
import "core:testing"

import "../utils"

parse_towels :: proc(s: string) -> (towels: [dynamic]string) {
	s := s
	for t in strings.split_iterator(&s, ", ") {
		append(&towels, t)
	}
	return
}

Cache :: map[string]int

pattern_possible :: proc(pattern: string, towels: []string) -> bool {
	if len(pattern) == 0 do return true

	for t in towels {
		if strings.has_suffix(pattern, t) {
			trimmed := pattern[:len(pattern) - len(t)]

			if pattern_possible(trimmed, towels) do return true
		}
	}

	return false
}

count_possibilities :: proc(pattern: string, towels: []string, cache: ^Cache) -> (designs: int) {
	if len(pattern) == 0 do return 1

	if pattern in cache do return cache[pattern]

	for t in towels {
		if strings.has_suffix(pattern, t) {
			trimmed := pattern[:len(pattern) - len(t)]
			designs += count_possibilities(trimmed, towels, cache)
		}
	}

	cache[pattern] = designs
	return
}

part_1 :: proc(input: string) -> (result: int) {
	towels_string, patterns := utils.split_once(input, "\n\n") or_else panic("Invalid input")

	towels := parse_towels(towels_string)
	defer delete(towels)

	for pattern in strings.split_lines_iterator(&patterns) {
		if pattern_possible(pattern, towels[:]) do result += 1
	}

	return
}

part_2 :: proc(input: string) -> (result: int) {
	towels_string, patterns := utils.split_once(input, "\n\n") or_else panic("Invalid input")

	towels := parse_towels(towels_string)
	defer delete(towels)

	cache: Cache
	defer delete(cache)

	for pattern in strings.split_lines_iterator(&patterns) {
		result += count_possibilities(pattern, towels[:], &cache)
	}

	return
}

main :: proc() {
	utils.aoc_main(part_1, part_2)
}

EXAMPLE_INPUT: string : `r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb
`


@(test)
part1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(EXAMPLE_INPUT), 6)
}

@(test)
part2_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(EXAMPLE_INPUT), 16)
}
