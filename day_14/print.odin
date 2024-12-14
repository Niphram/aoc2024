package day_14

import "core:fmt"

import "../utils/grid"

print_robots :: proc(robots: []Robot, room: Vec2i) {
	g := grid.Grid(bool) {
		width   = room.x,
		height  = room.y,
		padding = 0,
		bytes   = make([]bool, room.x * room.y),
	}
	defer delete(g.bytes)

	for r in robots {
		grid.set(g, r.pos, true)
	}

	for y in 0 ..< g.height {
		for x in 0 ..< g.width {
			if grid.get(g, {x, y}) do fmt.print("#", flush = false)
			else do fmt.print(".", flush = false)
		}
		fmt.println(flush = false)
	}

	// Flush the output
	fmt.print()
}
