package day_18

import "core:container/priority_queue"
import "core:container/small_array"

import "../utils/grid"

Maze :: grid.Grid(bool)

Neighbors :: [?]Vec2i{{+1, 0}, {0, -1}, {-1, 0}, {0, +1}}

Node :: struct {
	pos: Vec2i,
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
a_star_exhaustive :: proc(maze: Maze, start, end: Vec2i) -> (lowest_cost := max(int)) {
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
			return current_cost
		}

		// Find neighbors
		neighbor_loop: for offset, dir in Neighbors {
			next_node := Node {
				pos = current_node.pos + offset,
			}

			// Wall, skip
			if grid.get_safe(maze, next_node.pos) or_continue do continue

			new_cost := current_cost + 1
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

	return
}
