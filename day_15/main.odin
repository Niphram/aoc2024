package day_15

import "core:fmt"
import "core:slice"
import "core:strings"
import "core:testing"

import "../parse"
import "../utils"
import "../utils/grid"

parse_warehouse :: proc(map_string: string, x_scale := 1) -> (objects: []Object, robot: ^Object) {
	warehouse := grid.from_seperated(transmute([]u8)map_string, '\n')

	dyn_objects := make([dynamic]Object)
	robot_idx := 0

	for y in 0 ..< warehouse.height {
		for x in 0 ..< warehouse.width {
			switch grid.get(warehouse, {x, y}) {
			case '#':
				append(
					&dyn_objects,
					Object{pos = {x * x_scale, y}, size = {x_scale, 1}, type = .Wall},
				)
			case 'O':
				append(
					&dyn_objects,
					Object{pos = {x * x_scale, y}, size = {x_scale, 1}, type = .Box},
				)
			case '@':
				robot_idx = len(dyn_objects)
				append(&dyn_objects, Object{pos = {x * x_scale, y}, size = {1, 1}, type = .Robot})
			}
		}
	}

	return dyn_objects[:], &dyn_objects[robot_idx]
}

sum_box_gps_coords :: proc(objects: []Object) -> (gps_sum: int) {
	for o in objects {
		if o.type == .Box {
			gps_sum += o.pos.x + 100 * o.pos.y
		}
	}

	return
}

part_1 :: proc(input: string) -> int {
	map_string, moves := utils.split_once(input, "\n\n") or_else panic("Invalid input")

	objects, robot := parse_warehouse(map_string, 1)
	defer delete(objects)

	for m in moves {
		if m == '\n' do continue
		push_object(objects[:], robot, Direction(m))
	}

	return sum_box_gps_coords(objects[:])
}

part_2 :: proc(input: string) -> int {
	map_string, moves := utils.split_once(input, "\n\n") or_else panic("Invalid input")

	objects, robot := parse_warehouse(map_string, 2)
	defer delete(objects)

	for m in moves {
		if m == '\n' do continue
		push_object(objects[:], robot, Direction(m))
	}

	return sum_box_gps_coords(objects[:])
}

main :: proc() {
	utils.aoc_main(part_1, part_2)
}
