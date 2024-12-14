package day_11

import "core:fmt"
import "core:math"
import "core:testing"

import "../parse"
import "../utils"

input_iter :: proc(input: ^string) -> (res: int, ok: bool) {
	space_seperator :: proc(s: ^string) -> (r: rune, ok: bool) {
		return parse.take_rune(s, ' ')
	}

	return parse.seperated_list_iter(parse.read_number, space_seperator, input)
}

StoneSplitCache :: map[struct {
	stone, iteration: int,
}]int

simulate_stone :: proc(stone, iterations: int, cache: ^StoneSplitCache) -> int {
	if iterations == 0 do return 1

	// Check if we've seen this stone before
	if res, ok := cache[{stone, iterations}]; ok do return res

	stone_count := 0

	if stone == 0 {
		stone_count += simulate_stone(1, iterations - 1, cache)
	} else if math.count_digits_of_base(stone, 10) % 2 == 0 {
		l, r := utils.split_int(stone, math.count_digits_of_base(stone, 10) / 2)
		stone_count += simulate_stone(l, iterations - 1, cache)
		stone_count += simulate_stone(r, iterations - 1, cache)
	} else {
		stone_count += simulate_stone(stone * 2024, iterations - 1, cache)
	}

	// Cache the result
	cache[{stone, iterations}] = stone_count
	return stone_count
}

part_1 :: proc(input: string) -> (number_of_stones: int) {
	input := input

	cache := make(StoneSplitCache)
	defer delete(cache)

	for stone in input_iter(&input) {
		number_of_stones += simulate_stone(stone, 25, &cache)
	}

	return
}

part_2 :: proc(input: string) -> (number_of_stones: int) {
	input := input

	cache := make(StoneSplitCache)
	defer delete(cache)

	for stone in input_iter(&input) {
		number_of_stones += simulate_stone(stone, 75, &cache)
	}

	return
}

main :: proc() {
	utils.aoc_main(part_1, part_2)
}

@(test)
part1_test :: proc(t: ^testing.T) {
	EXAMPLE_INPUT: string : `125 17`

	testing.expect_value(t, part_1(EXAMPLE_INPUT), 55312)
}
