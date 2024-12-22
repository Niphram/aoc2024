package day_22

import "core:container/small_array"
import "core:fmt"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:testing"

import "../parse"
import "../utils"

RingArray :: struct($L: int, $T: typeid) {
	data: [L]T,
	ptr:  int,
}

ring_push :: proc(ring: ^RingArray($N, $T), val: T) {
	ring.data[ring.ptr] = val
	ring.ptr += 1
	ring.ptr %= N
}

ring_compare :: proc(ring: RingArray($N, $T), values: []T) -> bool {
	for v, i in values {
		if v != ring.data[(ring.ptr + i) % N] do return false
	}

	return true
}

ring_to_slice :: proc(ring: RingArray($N, $T)) -> [N]T {
	out: [N]T

	for i in 0 ..< N {
		out[i] = ring.data[(ring.ptr + i) % N]
	}

	return out
}

next_secret :: proc(previous: int) -> int {
	previous := previous

	previous ~= previous * 64
	previous %= 16777216

	previous ~= previous / 32
	previous %= 16777216

	previous ~= previous * 2048
	previous %= 16777216

	return previous
}

part_1 :: proc(input: string) -> (result: int) {
	input := input

	input_loop: for secret_string in strings.split_lines_iterator(&input) {
		secret := strconv.parse_int(secret_string, 10) or_continue

		for _ in 0 ..< 2000 {
			secret = next_secret(secret)
		}

		result += secret
	}

	return
}

part_2 :: proc(input: string) -> (result: int) {
	input := input

	ITERATIONS :: 2000
	PRICE_HISTORY :: 4

	// Keep track of the amount of bananas each sequence produces
	bananas := make(map[[4]int]int)
	defer delete(bananas)

	for secret_string in strings.split_lines_iterator(&input) {
		secret := strconv.parse_int(secret_string, 10) or_else panic("INput is not a number")

		price_changes: RingArray(PRICE_HISTORY, int)

		seen_changes := make(map[[PRICE_HISTORY]int]struct {})
		defer delete(seen_changes)

		for i in 0 ..< ITERATIONS {
			next := next_secret(secret)
			ring_push(&price_changes, (next % 10) - (secret % 10))
			secret = next

			if i >= 4 {
				changes := ring_to_slice(price_changes)
				if changes in seen_changes do continue
				seen_changes[changes] = {}

				bananas[changes] += secret % 10
			}
		}
	}

	// Find the most bananas
	max_bananas := min(int)
	for _, v in bananas {
		if v > max_bananas do max_bananas = v
	}

	return max_bananas
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
