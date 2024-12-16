package day_16

import "core:container/priority_queue"
import "core:container/small_array"
import "core:slice"
import "core:testing"

import "../utils"
import "../utils/grid"

Maze :: grid.Grid(u8)

Direction :: enum {
	East  = 0,
	North = 1,
	West  = 2,
	South = 3,
}

turns :: proc(a, b: Direction) -> int {
	return min(abs((int(a) - int(b) + 4) % 4), abs((int(b) - int(a) + 4) % 4))
}

Neighbors :: [Direction][2]int {
	.East  = {+1, 0},
	.North = {0, -1},
	.West  = {-1, 0},
	.South = {0, +1},
}

Node :: struct {
	pos: [2]int,
	dir: Direction,
}

ScoredNode :: struct {
	using node: Node,
	cost:       int,
}

scored_node_less :: proc(a, b: ScoredNode) -> bool {
	return a.cost < b.cost
}

// Every node can have at most 4 parents
Parents :: small_array.Small_Array(4, Node)

// Finds ALL shortest paths
a_star_exhaustive :: proc(
	maze: Maze,
	start, end: [2]int,
) -> (
	lowest_cost := max(int),
	visited_cells := 0,
) {
	costs := make(map[Node]int)
	defer delete(costs)

	// Track the parents of every node
	parents := make(map[Node]Parents)
	defer delete(parents)

	// Priority Queue to keep track of open paths
	pq: priority_queue.Priority_Queue(ScoredNode)
	priority_queue.init(&pq, scored_node_less, priority_queue.default_swap_proc(ScoredNode))
	defer priority_queue.destroy(&pq)

	// Starting position
	start_node := ScoredNode {
		pos = start,
		dir = .East,
	}
	priority_queue.push(&pq, start_node)

	// Keep track of the ending nodes for backtracking
	end_nodes: [dynamic]Node
	defer delete(end_nodes)

	for current_node in priority_queue.pop_safe(&pq) {
		current_cost := costs[current_node]

		// There are no more shortest paths
		if current_cost > lowest_cost do break

		// We already have a lower cost for this node
		if current_node.cost > current_cost do continue

		// Path has found the end, update lowest cost
		if current_node.pos == end {
			append(&end_nodes, current_node)
			lowest_cost = costs[current_node]
			continue
		}

		// Find neighbors
		neighbor_loop: for offset, dir in Neighbors {
			next_node := Node {
				pos = current_node.pos + offset,
				dir = dir,
			}

			// Wall, skip
			if grid.get(maze, next_node.pos) == '#' do continue

			new_cost := current_cost + 1 + (turns(dir, current_node.dir) * 1000)
			old_cost := costs[next_node] or_else max(int)

			if new_cost < old_cost {
				// If we find a shorter way to reach this node, update our graph
				costs[next_node] = new_cost
				priority_queue.push(&pq, ScoredNode{node = next_node, cost = new_cost})

				parents[next_node] = Parents {
					data = {0 = current_node},
					len = 1,
				}
			} else if new_cost == old_cost {
				// We found a path that reaches this node with the same cost, update parents
				small_array.append(&parents[next_node], current_node)
			}
		}
	}

	{
		// Count visited cells on all paths
		visited := make(map[[2]int]struct {})
		defer delete(visited)

		for e in pop_safe(&end_nodes) {
			visited[e.pos] = {}

			parents_array := parents[e]
			append(&end_nodes, ..small_array.slice(&parents_array))
		}

		visited_cells = len(visited)
	}

	return
}

part_1 :: proc(input: []u8) -> (result: int) {
	maze := grid.from_seperated(input, '\n')

	start_idx := slice.linear_search(maze.bytes, 'S') or_else panic("Could not find start")
	end_idx := slice.linear_search(maze.bytes, 'E') or_else panic("Could not find end")

	lowest_cost, _ := a_star_exhaustive(
		maze,
		grid.index_to_xy(maze, start_idx),
		grid.index_to_xy(maze, end_idx),
	)

	return lowest_cost
}

part_2 :: proc(input: []u8) -> (result: int) {
	maze := grid.from_seperated(input, '\n')

	start_idx := slice.linear_search(maze.bytes, 'S') or_else panic("Could not find start")
	end_idx := slice.linear_search(maze.bytes, 'E') or_else panic("Could not find end")

	_, visited := a_star_exhaustive(
		maze,
		grid.index_to_xy(maze, start_idx),
		grid.index_to_xy(maze, end_idx),
	)

	return visited
}

main :: proc() {
	utils.aoc_main(part_1, part_2)
}

EXAMPLE_1: string : `###############
#.......#....E#
#.#.###.#.###.#
#.....#.#...#.#
#.###.#####.#.#
#.#.#.......#.#
#.#.#####.###.#
#...........#.#
###.#.#####.#.#
#...#.....#.#.#
#.#.#.###.#.#.#
#.....#...#.#.#
#.###.#.#.#.#.#
#S..#.....#...#
###############
`


EXAMPLE_2: string : `#################
#...#...#...#..E#
#.#.#.#.#.#.#.#.#
#.#.#.#...#...#.#
#.#.#.#.###.#.#.#
#...#.#.#.....#.#
#.#.#.#.#.#####.#
#.#...#.#.#.....#
#.#.#####.#.###.#
#.#.#.......#...#
#.#.###.#####.###
#.#.#...#.....#.#
#.#.#.#####.###.#
#.#.#.........#.#
#.#.#.#########.#
#S#.............#
#################
`


@(test)
part1_example1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(transmute([]u8)EXAMPLE_1), 7036)
}

@(test)
part1_example2_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(transmute([]u8)EXAMPLE_2), 11048)
}

@(test)
part2__example1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(transmute([]u8)EXAMPLE_1), 45)
}

@(test)
part2_example2_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(transmute([]u8)EXAMPLE_2), 64)
}
