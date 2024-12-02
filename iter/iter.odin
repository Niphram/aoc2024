package iter

Iterator :: struct($Item, $Context: typeid) {
	ctx:  Context,
	next: proc(ctx: ^Context) -> (item: Item, ok: bool),
}

next :: proc(iterator: ^Iterator($Item, $Context)) -> (item: Item, ok: bool) {
	return iterator.next(&iterator.ctx)
}

clone :: proc(iterator: $Iter/Iterator($Item, $Context)) -> Iter {
	return {iterator.ctx, iterator.next}
}
