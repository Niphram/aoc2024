package utils

import "base:intrinsics"

Pointcloud :: struct($T: typeid) where intrinsics.type_is_numeric(T) {
	min, max: [2]T,
	points:   map[[2]T]struct {},
}

delete_pointcloud :: proc(pc: Pointcloud($T)) {
	delete(pc.points)
}

pointcloud_add :: proc(pc: ^Pointcloud($T), pos: [2]T) {
	pc.min.x = min(pc.min.x, pos.x)
	pc.min.y = min(pc.min.y, pos.y)
	pc.max.x = max(pc.max.x, pos.x)
	pc.max.y = max(pc.max.y, pos.y)

	pc.points[pos] = {}
}
