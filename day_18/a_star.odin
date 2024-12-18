package day_18

import "core:container/priority_queue"
import "core:container/small_array"

import "../utils/grid"

Maze :: grid.Grid(bool)

Neighbors :: [?]Vec2i{{+1, 0}, {0, -1}, {-1, 0}, {0, +1}}

ScoredNode :: struct {
	pos:  Vec2i,
	cost: int,
}

scored_node_less :: proc(a, b: ScoredNode) -> bool {
	return a.cost < b.cost
}

a_star :: proc(maze: Maze, start, end: Vec2i) -> (lowest_cost := max(int)) {
	costs := make(map[Vec2i]int)
	defer delete(costs)

	// Priority Queue to keep track of open paths
	pq: priority_queue.Priority_Queue(ScoredNode)
	priority_queue.init(&pq, scored_node_less, priority_queue.default_swap_proc(ScoredNode))
	defer priority_queue.destroy(&pq)

	// Starting position
	priority_queue.push(&pq, ScoredNode{pos = start})

	// Keep track of the ending nodes for backtracking
	end_nodes: [dynamic]Vec2i
	defer delete(end_nodes)

	for current_node in priority_queue.pop_safe(&pq) {
		current_cost := costs[current_node.pos]

		// We already have a lower cost for this node
		if current_node.cost > current_cost do continue

		// Path has found the end, update lowest cost
		if current_node.pos == end do return current_cost

		// Find neighbors
		neighbor_loop: for offset, dir in Neighbors {
			next_node := current_node.pos + offset

			// Wall, skip
			if grid.get_safe(maze, next_node) or_continue do continue

			new_cost := current_cost + 1
			old_cost := costs[next_node] or_else max(int)

			if new_cost < old_cost {
				// If we find a shorter way to reach this node, update our graph
				costs[next_node] = new_cost
				priority_queue.push(&pq, ScoredNode{pos = next_node, cost = new_cost})
			}
		}
	}

	return
}
