package parse

Parser :: struct($T, $Context: typeid) {
	ctx:   Context,
	parse: proc(ctx: Context, input: ^string) -> (T, bool),
}

exec :: proc(p: Parser($T, $C), input: ^string) -> (res: T, ok: bool) {
	return p.parse(p.ctx, input)
}
