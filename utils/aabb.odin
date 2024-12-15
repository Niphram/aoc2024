package utils

AABB :: struct($T: typeid) {
	pos, size: [2]T,
}

aabb_contains :: proc(a: AABB($T), pos: [2]T) -> bool {
	return(
		a.pos.x <= pos.x &&
		pos.x < a.pos.x + a.size.x &&
		a.pos.y <= pos.y &&
		pos.y < a.pos.y + a.size.y \
	)
}

aabb_intersects :: proc(a, b: AABB($T)) -> bool {
	return(
		a.pos.x < b.pos.x + b.size.x &&
		a.pos.x + a.size.x > b.pos.x &&
		a.pos.y < b.pos.y + b.size.y &&
		a.pos.y + a.size.y > b.pos.y \
	)
}
