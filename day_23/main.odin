package day_23

import "core:container/bit_array"
import "core:fmt"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:testing"

import "../utils"

NODE_COUNT :: 26 * 26

Graph :: [NODE_COUNT]bit_array.Bit_Array


parse_connection :: proc(input: []u8) -> [2]int {
	return {pack_node(input[:2]), pack_node(input[3:])}
}

pack_node :: proc(input: []u8) -> (packed: int) {
	return int(input[0] - 'a') * 26 + int(input[1] - 'a')
}


dfs :: proc(graph: ^Graph, marked: ^bit_array.Bit_Array, n, vert, start: int) -> int {
	bit_array.unsafe_set(marked, vert)

	if n == 0 {
		bit_array.unsafe_unset(marked, vert)

		if bit_array.unsafe_get(&graph[vert], start) {
			return 1
		} else {
			return 0
		}
	}

	count := 0

	for i in 0 ..< NODE_COUNT {
		if !bit_array.unsafe_get(marked, i) && bit_array.unsafe_get(&graph[vert], i) {
			count += dfs(graph, marked, n - 1, i, start)
		}

		bit_array.unsafe_unset(marked, vert)
	}

	return count
}

count_networks :: proc(graph: ^Graph, n: int) -> int {
	marked := bit_array.create(NODE_COUNT)
	defer bit_array.destroy(marked)

	count := 0

	for i in 0 ..< NODE_COUNT - (n - 1) {
		if i / 26 == 't' - 'a' {
			count += dfs(graph, marked, n - 1, i, i)
			bit_array.unsafe_set(marked, i)
		}

	}

	return count / 2
}

and_bitarray :: proc(a, b: ^bit_array.Bit_Array) -> (was_reduced: bool) {
	iter := bit_array.make_iterator(b)

	for i in bit_array.iterate_by_unset(&iter) {
		if bit_array.unsafe_get(a, i) do was_reduced = true
		bit_array.unsafe_unset(a, i)
	}

	return
}

and_neighbors :: proc(graph: ^Graph, clique: ^bit_array.Bit_Array)

// Full of memory leaks, fix this later
find_clique :: proc(graph: ^Graph) {

	biggest_clique: [dynamic]int

	for &neighbors, i in graph {
		clique := [dynamic]int{i}

		neighbor_iter := bit_array.make_iterator(&neighbors)
		for n in bit_array.iterate_by_set(&neighbor_iter) {
			neighbors_deep := graph[n]

			all := true
			for g in clique {
				if !bit_array.unsafe_get(&neighbors_deep, g) do all = false
			}

			if all do append(&clique, n)
		}

		if len(clique) > len(biggest_clique) {
			biggest_clique = clique
		}
	}

	slice.sort(biggest_clique[:])

	for i in biggest_clique[:] {
		fmt.print(rune(i / 26 + 'a'))
		fmt.print(rune(i % 26 + 'a'))
		fmt.print(",")
	}
}

part_1 :: proc(input: string) -> (result: int) {
	input := input

	graph: Graph
	for &node in graph {
		bit_array.init(&node, NODE_COUNT)
	}
	defer {
		for &node in graph do bit_array.destroy(&node)
	}

	for line in strings.split_lines_iterator(&input) {
		connection := parse_connection(transmute([]u8)line)

		bit_array.unsafe_set(&graph[connection[0]], connection[1])
		bit_array.unsafe_set(&graph[connection[1]], connection[0])
	}


	return count_networks(&graph, 3)
}

part_2 :: proc(input: string) -> (result: int) {
	input := input

	graph: Graph
	for &node in graph {
		bit_array.init(&node, NODE_COUNT)
	}
	defer {
		for &node in graph do bit_array.destroy(&node)
	}

	for line in strings.split_lines_iterator(&input) {
		connection := parse_connection(transmute([]u8)line)

		bit_array.unsafe_set(&graph[connection[0]], connection[1])
		bit_array.unsafe_set(&graph[connection[1]], connection[0])
	}

	find_clique(&graph)

	return
}

main :: proc() {
	utils.aoc_main(part_1, part_2)
}

EXAMPLE_1: string : ``


EXAMPLE_2: string : ``


@(test)
part1_test :: proc(t: ^testing.T) {
	//testing.expect_value(t, part_1(EXAMPLE_1), 0)
}

@(test)
part2_test :: proc(t: ^testing.T) {
	//testing.expect_value(t, part_2(EXAMPLE_2), 0)
}
