package day_21

import "core:container/small_array"
import "core:slice"
import "core:strings"
import "core:testing"

import "../parse"
import "../utils"

sa_append :: small_array.append
sa_slice :: small_array.slice
sa_len :: small_array.len

Vec2i :: [2]int

Direction := #sparse[?]Vec2i {
	'^' = {0, -1},
	'v' = {0, 1},
	'<' = {-1, 0},
	'>' = {1, 0},
}

// The positions of the buttons.
// Both keypad types are overlayed, so the activate-button and the empty space are in the same positions
Keypad := #sparse[?]Vec2i {
	'7' = {0, 0},
	'8' = {1, 0},
	'9' = {2, 0},
	'4' = {0, 1},
	'5' = {1, 1},
	'6' = {2, 1},
	'1' = {0, 2},
	'2' = {1, 2},
	'3' = {2, 2},
	'0' = {1, 3},
	'^' = {1, 3},
	'<' = {0, 4},
	'v' = {1, 4},
	'>' = {2, 4},
	'A' = {2, 3},
	' ' = {0, 3},
}

// Using stack-allocated arrays for easy of copying.
// The lengths are the absolute minimum
ButtonSequence :: small_array.Small_Array(6, u8) // Going from A to 7 will produce 5 directional presses + one A press
Moveset :: small_array.Small_Array(9, ButtonSequence) // There are 9 distinct sequences to get from A to 7

// Find all possible moves to get from button a to b.
// Ignores all paths that would cross the empty space
find_possible_movesets :: proc(start, end: Vec2i) -> Moveset {
	delta := end - start

	// Build a sequence of directional button presses
	dir_sequence: ButtonSequence

	if delta.x < 0 {
		for _ in 0 ..< -delta.x do sa_append(&dir_sequence, '<')
	} else {
		for _ in 0 ..< delta.x do sa_append(&dir_sequence, '>')
	}

	if delta.y < 0 {
		for _ in 0 ..< -delta.y do sa_append(&dir_sequence, '^')
	} else {
		for _ in 0 ..< delta.y do sa_append(&dir_sequence, 'v')
	}

	// No need to move, just return a single moveset with 'A'
	if sa_len(dir_sequence) == 0 {
		activate_sequence := ButtonSequence{{0 = 'A'}, 1}
		return Moveset{{0 = activate_sequence}, 1}
	}

	moveset: Moveset

	// Check every permutation of the sequence
	perm_iter := slice.make_permutation_iterator(sa_slice(&dir_sequence))
	defer slice.destroy_permutation_iterator(perm_iter)

	perm_loop: for slice.permute(&perm_iter) {
		// Check if the sequence would enter the emtpy space
		pos := start
		for d in sa_slice(&dir_sequence) {
			pos += Direction[d]
			if pos == Keypad[' '] do continue perm_loop
		}

		// Finish every sequence with an 'A'
		sequence_copy := dir_sequence
		sa_append(&sequence_copy, 'A')

		// Add it to the moveset
		if !slice.contains(sa_slice(&moveset), sequence_copy) {
			sa_append(&moveset, sequence_copy)
		}
	}

	return moveset
}

CacheKey :: struct {
	input:        ButtonSequence,
	limit, depth: int,
}

Cache :: map[CacheKey]int

find_min_length :: proc(
	input_sequence: ButtonSequence,
	limit: int,
	cache: ^Cache,
	depth := 0,
) -> (
	length: int,
) {
	// Check the cache
	cache_key := CacheKey{input_sequence, limit, depth}
	if cache_key in cache do return cache[cache_key]

	input_sequence := input_sequence

	// Start on the activate button
	cur := Keypad['A']
	for r in sa_slice(&input_sequence) {
		next_cur := Keypad[r]

		// Find all movesets
		moveset := find_possible_movesets(cur, next_cur)

		if depth == limit {
			// If we've reached our recursion limit, just use the length of the first sequence
			length += sa_len(small_array.get(moveset, 0))
		} else {
			// For every sequence in the moveset, recursively find the shortest sequence
			shortest := max(int)
			for sequence in sa_slice(&moveset) {
				shortest = min(shortest, find_min_length(sequence, limit, cache, depth + 1))
			}
			length += shortest
		}

		cur = next_cur
	}

	cache[cache_key] = length
	return
}

sum_complexities :: proc(input: string, middle_robots: int) -> (sum: int) {
	input := input

	cache: Cache
	defer delete(cache)

	for line in strings.split_lines_iterator(&input) {
		line := line

		// Build sequence from string input (assumes the string only contains valid characters)
		sequence: ButtonSequence
		for button in transmute([]u8)line {
			sa_append(&sequence, button)
		}

		// Find the minimum input length
		min_sequence_length := find_min_length(sequence, middle_robots, &cache)
		complexity_factor := parse.read_number(&line) or_else panic("Invalid input")

		sum += min_sequence_length * complexity_factor
	}

	return
}

part_1 :: proc(input: string) -> (result: int) {
	return sum_complexities(input, 2)
}

part_2 :: proc(input: string) -> (result: int) {
	return sum_complexities(input, 25)
}

main :: proc() {
	utils.aoc_main(part_1, part_2)
}

EXAMPLE_INPUT: string : `029A
980A
179A
456A
379A
`


@(test)
part1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(EXAMPLE_INPUT), 126384)
}
