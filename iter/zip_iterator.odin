package iter

Pair :: struct($Left, $Right: typeid) {
	x: Left,
	y: Right,
}

zip :: proc(
	left: ^$LeftIter/Iterator($LeftItem, $LeftContext),
	right: ^$RightIter/Iterator($RightItem, $RightContext),
) -> Iterator(Pair(LeftItem, RightItem), Pair(^LeftIter, ^RightIter)) {
	zip_next :: proc(
		ctx: ^Pair(^LeftIter, ^RightIter),
	) -> (
		item: Pair(LeftItem, RightItem),
		ok := true,
	) {
		item.x = next(ctx.x) or_return
		item.y = next(ctx.y) or_return
		return
	}

	return {{left, right}, zip_next}
}
