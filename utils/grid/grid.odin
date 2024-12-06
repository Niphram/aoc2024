package grid

import "core:slice"
import "core:strings"

Grid :: struct($T: typeid) {
	width, height: int,
	padding:       int,
	bytes:         []T,
}

get :: proc(grid: Grid($T), x, y: int) -> T {
	return grid.bytes[xy_to_index(grid, x, y)]
}

xy_to_index :: proc(grid: Grid($T), x, y: int) -> (idx: int) {
	return x + y * (grid.width + grid.padding)
}

index_to_xy :: proc(grid: Grid($T), idx: int) -> (x, y: int) {
	x = idx % (grid.width + grid.padding)
	y = idx / (grid.width + grid.padding)

	return
}

in_bounds :: proc(grid: Grid($T), x, y: int) -> bool {
	return x >= 0 && x < grid.width && y >= 0 && y < grid.height
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
