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

Button :: enum rune {
	Empty    = ' ',
	Activate = 'A',
	Zero     = '0',
	One      = '1',
	Two      = '2',
	Three    = '3',
	Four     = '4',
	Five     = '5',
	Six      = '6',
	Seven    = '7',
	Eight    = '8',
	Nine     = '9',
	Up       = '^',
	Left     = '<',
	Down     = 'v',
	Right    = '>',
}

Direction := #partial #sparse[Button]Vec2i {
	.Up    = {0, -1},
	.Down  = {0, 1},
	.Left  = {-1, 0},
	.Right = {1, 0},
}

// The positions of the buttons.
// Both keypad types are overlayed, so the activate-button and the empty space are in the same positions
ButtonPositions := #sparse[Button]Vec2i {
	.Seven    = {0, 0},
	.Eight    = {1, 0},
	.Nine     = {2, 0},
	.Four     = {0, 1},
	.Five     = {1, 1},
	.Six      = {2, 1},
	.One      = {0, 2},
	.Two      = {1, 2},
	.Three    = {2, 2},
	.Zero     = {1, 3},
	.Up       = {1, 3},
	.Left     = {0, 4},
	.Down     = {1, 4},
	.Right    = {2, 4},
	.Activate = {2, 3},
	.Empty    = {0, 3},
}

// Using stack-allocated arrays for easy of copying.
// The lengths are the absolute minimum
ButtonSequence :: small_array.Small_Array(6, Button) // Going from A to 7 will produce 5 directional presses + one A press
Moveset :: small_array.Small_Array(9, ButtonSequence) // There are 9 distinct sequences to get from A to 7

// Find all possible moves to get from button a to b.
// Ignores all paths that would cross the empty space
find_possible_movesets :: proc(a, b: Button) -> Moveset {
	delta := ButtonPositions[b] - ButtonPositions[a]

	// Build a sequence of directional button presses
	dir_sequence: ButtonSequence

	if delta.x < 0 {
		for _ in 0 ..< -delta.x do sa_append(&dir_sequence, Button.Left)
	} else {
		for _ in 0 ..< delta.x do sa_append(&dir_sequence, Button.Right)
	}

	if delta.y < 0 {
		for _ in 0 ..< -delta.y do sa_append(&dir_sequence, Button.Up)
	} else {
		for _ in 0 ..< delta.y do sa_append(&dir_sequence, Button.Down)
	}

	// No need to move, just return a single moveset with 'A'
	if sa_len(dir_sequence) == 0 {
		activate_sequence := ButtonSequence{{0 = Button.Activate}, 1}
		return Moveset{{0 = activate_sequence}, 1}
	}

	moveset: Moveset

	// Check every permutation of the sequence
	perm_iter := slice.make_permutation_iterator(sa_slice(&dir_sequence))
	defer slice.destroy_permutation_iterator(perm_iter)

	perm_loop: for slice.permute(&perm_iter) {
		// Check if the sequence would enter the emtpy space
		pos := ButtonPositions[a]
		for d in sa_slice(&dir_sequence) {
			pos += Direction[Button(d)]
			if pos == ButtonPositions[Button.Empty] do continue perm_loop
		}

		// Finish every sequence with an 'A'
		sequence_copy := dir_sequence
		sa_append(&sequence_copy, Button.Activate)

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
	middle_robots: int,
	cache: ^Cache,
	depth := 0,
) -> (
	length: int,
) {
	// Check the cache
	cache_key := CacheKey{input_sequence, middle_robots, depth}
	if cache_key in cache do return cache[cache_key]

	input_sequence := input_sequence

	// Start on the activate button
	cur_button := Button.Activate
	for b in sa_slice(&input_sequence) {
		next_button := Button(b)

		// Find all movesets
		moveset := find_possible_movesets(cur_button, next_button)

		if depth == middle_robots {
			// If we've reached our recursion limit, just use the length of the first sequence
			length += sa_len(small_array.get(moveset, 0))
		} else {
			// For every sequence in the moveset, recursively find the shortest sequence
			shortest := max(int)
			for sequence in sa_slice(&moveset) {
				shortest = min(
					shortest,
					find_min_length(sequence, middle_robots, cache, depth + 1),
				)
			}
			length += shortest
		}

		cur_button = next_button
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

		// Build sequence from string input
		sequence: ButtonSequence
		for button in line {
			sa_append(&sequence, Button(button))
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
