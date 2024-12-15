package day_15

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
	pos:  [2]int,
	size: [2]int,
	type: enum {
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

		if collides(o^, other) {
			push_recursive(&other, objects, dir, pushed_objects) or_return
		}
	}

	return
}

collides :: proc(a, b: Object) -> bool {
	return(
		a.pos.x < b.pos.x + b.size.x &&
		a.pos.x + a.size.x > b.pos.x &&
		a.pos.y < b.pos.y + b.size.y &&
		a.pos.y + a.size.y > b.pos.y \
	)
}
