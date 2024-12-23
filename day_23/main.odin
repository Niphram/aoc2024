package day_23

import "core:strings"
import "core:testing"

import "../utils"
import "../utils/small_bitset"

// The upper bound of nodes (aa to zz)
NODE_COUNT :: 26 * 26

NodeBitset :: small_bitset.BitSet(NODE_COUNT)
Graph :: [NODE_COUNT]NodeBitset

// Packs the 2-letter identifier into an uint
// aa -> 0, ab -> 1, [...], zy -> 674, zz -> 675
pack_identifier :: proc(input: []u8) -> (packed: uint) {
	assert(len(input) == 2)
	assert(input[0] >= 'a')
	assert(input[0] <= 'z')
	assert(input[1] >= 'a')
	assert(input[1] <= 'z')

	return uint(input[0] - 'a') * 26 + uint(input[1] - 'a')
}

// Unpacks the identifier and returns the original two numbers
unpack_identifier :: proc(input: uint) -> [2]u8 {
	left := input / 26 + 'a'
	right := input % 26 + 'a'

	assert(left <= uint(max(u8)))
	assert(right <= uint(max(u8)))

	return [2]u8{u8(left), u8(right)}
}

parse_input_graph :: proc(input: string) -> (graph: Graph) {
	input := input

	for line in strings.split_lines_iterator(&input) {
		line := transmute([]u8)line

		assert(len(line) == 5)

		left := pack_identifier(line[:2])
		right := pack_identifier(line[3:])

		// Make the graph unidirectional by setting both directions
		small_bitset.set(&graph[left], right)
		small_bitset.set(&graph[right], left)
	}

	return graph

}

count_networks :: proc(graph: ^Graph, n: uint) -> int {
	// recursively traverses the graph
	dfs :: proc(
		graph: ^Graph,
		marked: ^small_bitset.BitSet(NODE_COUNT),
		depth, node, start: uint,
	) -> (
		count: int,
	) {
		small_bitset.set(marked, node)

		if depth == 0 {
			small_bitset.unset(marked, node)
			return 1 if small_bitset.get(graph[node], start) else 0
		}

		for i in 0 ..< uint(NODE_COUNT) {
			if !small_bitset.get(marked^, i) && small_bitset.get(graph[node], i) {
				count += dfs(graph, marked, depth - 1, i, start)
			}

			small_bitset.unset(marked, node)
		}

		return count
	}

	count := 0

	// Marked will be used to keep track of nodes that are already used
	marked: small_bitset.BitSet(NODE_COUNT)

	for &a_neighbors, identifier in graph {
		identifier := uint(identifier)

		// Skip this starting-node if it doesn't start with a 't'
		if unpack_identifier(identifier)[0] != 't' do continue

		count += dfs(graph, &marked, n - 1, identifier, identifier)
		small_bitset.set(&marked, identifier)
	}

	return count / 2
}

find_largest_clique :: proc(graph: ^Graph) -> small_bitset.BitSet(NODE_COUNT) {
	best_clique: small_bitset.BitSet(NODE_COUNT)

	for &connections, i in graph {
		// Bitset to keep track of the nodes in the clique
		clique: small_bitset.BitSet(NODE_COUNT)
		small_bitset.set(&clique, uint(i))

		neighbor_iter := small_bitset.make_iterator(&connections)
		for neighbor_id in small_bitset.iterate_by_set(&neighbor_iter) {
			neighbors := graph[neighbor_id]

			// Check if every node in "clique" is also in "neighbors"
			if clique.data == (clique.data & neighbors.data) {
				small_bitset.set(&clique, neighbor_id)
			}
		}

		// Check cardinality to determine if the found clique is larger
		if small_bitset.card(clique) > small_bitset.card(best_clique) {
			best_clique = clique
		}
	}

	return best_clique
}

part_1 :: proc(input: string) -> (result: int) {
	graph := parse_input_graph(input)

	return count_networks(&graph, 3)
}

part_2 :: proc(input: string) -> (result: string) {
	graph := parse_input_graph(input)

	largest_clique := find_largest_clique(&graph)

	// Build output string
	b := strings.builder_make()
	node_iter := small_bitset.make_iterator(&largest_clique)
	for identifier in small_bitset.iterate_by_set(&node_iter) {
		result := unpack_identifier(uint(identifier))

		strings.write_string(&b, transmute(string)result[:])
		strings.write_rune(&b, ',')
	}

	return string(b.buf[:len(b.buf) - 1])
}

main :: proc() {
	_, part2_result := utils.aoc_main(part_1, part_2)
	delete(part2_result)
}

EXAMPLE_INPUT: string : `kh-tc
qp-kh
de-cg
ka-co
yn-aq
qp-ub
cg-tb
vc-aq
tb-ka
wh-tc
yn-cg
kh-ub
ta-co
de-co
tc-td
tb-wq
wh-td
ta-ka
td-qp
aq-cg
wq-ub
ub-vc
de-ta
wq-aq
wq-vc
wh-yn
ka-de
kh-ta
co-tc
wh-qp
tb-vc
td-yn
`


@(test)
part1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(EXAMPLE_INPUT), 7)
}

@(test)
part2_test :: proc(t: ^testing.T) {
	result := part_2(EXAMPLE_INPUT)
	defer delete(result)
	testing.expect_value(t, result, "co,de,ka,ta")
}
