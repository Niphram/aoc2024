package day_22

import "core:container/bit_array"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:testing"

import "../utils"

RingArray :: struct($N: int, $T: typeid) {
	buf: [N]T,
	ptr: int,
}

ring_append :: proc(ring: ^RingArray($N, $T), value: T) {
	ring.buf[ring.ptr] = value
	ring.ptr = (ring.ptr + 1) % N
}

// Packs the values into the minimum space
ring_pack :: proc(ring: RingArray($N, $T), min, max: int) -> (result: int) {
	for i in 0 ..< N {
		result *= max - min
		result += ring.buf[(i + ring.ptr) % N] - min
	}

	return
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
	PRICE_HISTORY_LENGTH :: 4
	PriceHistory :: RingArray(PRICE_HISTORY_LENGTH, int)

	// Sequences are 4 "digits" of -9 to 9, so in total 19**4
	PossibleSequences := utils.pow(19, PRICE_HISTORY_LENGTH)

	input := input

	// Keep track of the amount of bananas each sequence produces
	// Uses the packed integer of the sequence as the index
	bananas_by_sequence := make([]int, PossibleSequences)
	defer delete(bananas_by_sequence)

	// Keep track of the price-histories the monkey has seen
	// Uses the packed integer of the sequence as the index
	seen_sequences := bit_array.create(PossibleSequences)
	defer bit_array.destroy(seen_sequences)

	for secret_string in strings.split_lines_iterator(&input) {
		// Clear the seen changes (small performance improvement instead of re-creating the map for every input)
		bit_array.clear(seen_sequences)

		secret := strconv.parse_int(secret_string, 10) or_else panic("Input is not a number")

		price_changes: PriceHistory

		for i in 0 ..< ITERATIONS {
			next := next_secret(secret)
			ring_append(&price_changes, (next % 10) - (secret % 10))
			secret = next

			// Wait until the price-history is filled
			if i >= PRICE_HISTORY_LENGTH {
				packed := ring_pack(price_changes, -9, +9)

				// Check if the monkey has already seen this price history
				// Unsafe is fine here
				if bit_array.unsafe_get(seen_sequences, packed) do continue
				bit_array.unsafe_set(seen_sequences, packed)

				bananas_by_sequence[packed] += secret % 10
			}
		}
	}

	// Find the sequence that produced the most bananas
	return slice.max(bananas_by_sequence[:])
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
