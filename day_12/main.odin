package day_12

import "core:fmt"
import "core:os"

import "../utils/grid"

Vec2i :: [2]int
NEIGHBORS :: [4]Vec2i{{0, -1}, {+1, 0}, {0, +1}, {-1, 0}}

GardenPlots :: grid.Grid(u8)

Region :: struct {
	min, max: Vec2i,
	points:   map[Vec2i]struct {},
}

delete_regions :: proc(regions: [dynamic]Region) {
	for r in regions do delete(r.points)
	delete(regions)
}

flood_fill :: proc(g: GardenPlots, pos: Vec2i, region: ^Region) {
	region_marker := grid.get(g, pos)

	grid.set(g, pos, 0)
	region.points[pos] = {}

	region.min.x = min(region.min.x, pos.x)
	region.max.x = max(region.max.x, pos.x)
	region.min.y = min(region.min.y, pos.y)
	region.max.y = max(region.max.y, pos.y)

	for offset in NEIGHBORS {
		if (pos + offset) in region.points do continue

		if v, ok := grid.get_safe(g, pos + offset).(u8); ok && v == region_marker {
			flood_fill(g, pos + offset, region)
		}
	}
}

separate_regions :: proc(g: GardenPlots) -> [dynamic]Region {
	g := grid.clone(g)
	defer delete(g.bytes)

	regions := make([dynamic]Region)

	for y in 0 ..< g.height {
		for x in 0 ..< g.width {
			if grid.get(g, {x, y}) != 0 {
				region := Region{{x, y}, {x, y}, {{x, y} = {}}}
				flood_fill(g, {x, y}, &region)
				append(&regions, region)
			}
		}
	}

	return regions
}

part_1 :: proc(input: []u8) -> (cost: int) {
	regions := separate_regions(grid.from_seperated(input, '\n'))
	defer delete_regions(regions)

	for r in regions {
		fence_count := 0

		// Check neighbors of every position in the region 
		for n in NEIGHBORS {
			for p in r.points {
				if (p + n) not_in r.points do fence_count += 1
			}
		}

		cost += fence_count * len(r.points)
	}

	return
}

part_2 :: proc(input: []u8) -> (cost: int) {
	regions := separate_regions(grid.from_seperated(input, '\n'))
	defer delete_regions(regions)

	for r in regions {
		corners := 0

		for y in r.min.y - 1 ..= r.max.y {
			for x in r.min.x - 1 ..= r.max.x {
				// Test positions in a 2x2 area
				mat: bit_set[0 ..< 4]
				for o, i in ([?]Vec2i{{0, 0}, {1, 0}, {1, 1}, {0, 1}}) {
					if ({x, y} + o) in r.points do mat += {i}
				}

				switch mat {
				// Only one of the positions is inside the region -> external corner
				case {0}, {1}, {2}, {3}:
					corners += 1
				// Three of the positions are inside the region -> internal corners
				case {1, 2, 3}, {0, 2, 3}, {0, 1, 3}, {0, 1, 2}:
					corners += 1
				// Two opposing positions are inside the region -> 2 external corners
				case {0, 2}, {1, 3}:
					corners += 2
				}
			}
		}

		// The number of sides (straight fences) is equal to the number of corners of the shape
		cost += corners * len(r.points)
	}

	return
}

main :: proc() {
	input :=
		os.read_entire_file(#directory + "/input.txt") or_else panic("Could not read input file")
	defer delete(input)

	fmt.printfln("Part 1: %i", part_1(input))
	fmt.printfln("Part 2: %i", part_2(input))
}
