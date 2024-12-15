package day_15

import "../utils"

Direction :: enum u8 {
	Up    = '^',
	Right = '>',
	Down  = 'v',
	Left  = '<',
}

Direction_Vectors := #sparse[Direction][2]int {
	.Up    = {0, -1},
	.Right = {+1, 0},
	.Down  = {0, +1},
	.Left  = {-1, 0},
}

Object :: struct {
	using aabb: utils.AABB(int),
	type:       enum {
		Wall,
		Box,
		Robot,
	},
}

push_object :: proc(objects: []Object, obj: ^Object, dir: Direction) {
	pushed_objects := make([dynamic]^Object)
	defer delete(pushed_objects)

	if !push_recursive(obj, objects, dir, &pushed_objects) {
		// Unpush all objects
		for &pushed in pushed_objects {
			pushed.pos -= Direction_Vectors[dir]
		}
	}
}

push_recursive :: proc(
	o: ^Object,
	objects: []Object,
	dir: Direction,
	pushed_objects: ^[dynamic]^Object,
) -> (
	ok := true,
) {
	(o.type != .Wall) or_return

	append(pushed_objects, o)
	o.pos += Direction_Vectors[dir]

	for &other in objects {
		if o == &other do continue

		if utils.aabb_intersects(o.aabb, other.aabb) {
			push_recursive(&other, objects, dir, pushed_objects) or_return
		}
	}

	return
}
