package utils

import "core:strings"

Grid :: struct {
	width, height: int,
	bytes:         []u8,
}

grid_from_string :: proc(s: string) -> Grid {

	line_len := strings.index_rune(s, '\n')
	if line_len < 0 {
		line_len = len(s)
	}

	bytes := transmute([]u8)s

	width := line_len
	height := (len(s) - 1) / width

	return {width, height, bytes}
}

index_grid :: proc(grid: Grid, x, y: int) -> u8 {
	idx := x + y * (grid.width + 1)

	return grid.bytes[idx]
}
