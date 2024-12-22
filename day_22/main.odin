package day_22

import "core:strconv"
import "core:strings"
import "core:testing"

import "../utils"

// Moves all the values to the left (dropping the first element) and sets the value at the end
shift_in :: proc(buffer: ^[$N]$T, val: T) {
	for i in 0 ..< N - 1 {
		buffer[i] = buffer[i + 1]
	}
	buffer[N - 1] = val
}

// Produces the next secret by applying the rules
next_secret :: proc(secret: int) -> int {
	PRUNE :: 16777216

	secret := secret

	secret ~= secret * 64
	secret %= PRUNE

	secret ~= secret / 32
	secret %= PRUNE

	secret ~= secret * 2048
	secret %= PRUNE

	return secret
}

part_1 :: proc(input: string) -> (result: int) {
	input := input

	for secret_string in strings.split_lines_iterator(&input) {
		secret := strconv.parse_int(secret_string, 10) or_else panic("Input is not a number")

		for _ in 0 ..< 2000 {
			secret = next_secret(secret)
		}

		result += secret
	}

	return
}

part_2 :: proc(input: string) -> (result := min(int)) {
	ITERATIONS :: 2000
	PRICE_HISTORY :: 4

	PriceHistory :: [PRICE_HISTORY]int

	input := input

	// Keep track of the amount of bananas each sequence produces
	bananas_by_sequence := make(map[[4]int]int)
	defer delete(bananas_by_sequence)

	// Keep track of the price-histories the monkey has seen
	seen_changes := make(map[PriceHistory]struct {})
	defer delete(seen_changes)

	for secret_string in strings.split_lines_iterator(&input) {
		// Clear the seen changes (small performance improvement instead of re-creating the map for every input)
		clear(&seen_changes)

		secret := strconv.parse_int(secret_string, 10) or_else panic("Input is not a number")

		price_changes: PriceHistory

		for i in 0 ..< ITERATIONS {
			next := next_secret(secret)
			shift_in(&price_changes, (next % 10) - (secret % 10))
			secret = next

			// Wait until the price-history is filled
			if i >= PRICE_HISTORY {
				// Check if the monkey has already seen this price history
				if price_changes in seen_changes do continue
				seen_changes[price_changes] = {}

				bananas_by_sequence[price_changes] += secret % 10
			}
		}
	}

	// Find the sequence that produced the most bananas
	for _, b in bananas_by_sequence {
		result = max(result, b)
	}

	return
}

main :: proc() {
	utils.aoc_main(part_1, part_2)
}

EXAMPLE_1: string : `1
10
100
2024
`


EXAMPLE_2: string : `1
2
3
2024
`


@(test)
part1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(EXAMPLE_1), 37327623)
}

@(test)
part2_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(EXAMPLE_2), 23)
}
