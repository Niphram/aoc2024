package grid

import "core:slice"
import "core:strings"

Grid :: struct($T: typeid) {
	width, height: int,
	padding:       int,
	bytes:         []T,
}

get :: proc(grid: Grid($T), pos: [2]int) -> T {
	return grid.bytes[xy_to_index(grid, pos)]
}

set :: proc(grid: Grid($T), pos: [2]int, value: T) {
	grid.bytes[xy_to_index(grid, pos)] = value
}

xy_to_index :: proc(grid: Grid($T), pos: [2]int) -> (idx: int) {
	return pos.x + pos.y * (grid.width + grid.padding)
}

index_to_xy :: proc(grid: Grid($T), idx: int) -> [2]int {
	x := idx % (grid.width + grid.padding)
	y := idx / (grid.width + grid.padding)

	return {x, y}
}

in_bounds :: proc(grid: Grid($T), pos: [2]int) -> bool {
	return pos.x >= 0 && pos.x < grid.width && pos.y >= 0 && pos.y < grid.height
}

from :: proc {
	from_seperated,
	from_seperated_string,
}

from_seperated :: proc(input: []$T, seperator: T) -> Grid(T) {
	grid := Grid(T) {
		bytes   = input,
		padding = 1,
	}

	grid.width = slice.linear_search(input, seperator) or_else len(input)
	grid.height = (len(input) + 1) / (grid.width + grid.padding)

	return grid
}

from_seperated_string :: proc(s: string) -> Grid(u8) {
	return from_seperated(transmute([]u8)s, '\n')
}

clone_proc :: proc(g: Grid($I), mapper: proc(cell: I) -> $O) -> Grid(O) {
	cells := make([]O, g.width * g.height)

	idx: int
	for y in 0 ..< g.height {
		for x in 0 ..< g.width {
			cells[idx] = mapper(get(g, {x, y}))
			idx += 1
		}
	}

	return Grid(O){width = g.width, height = g.height, bytes = cells}
}
