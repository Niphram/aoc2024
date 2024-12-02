package parse

RunePredicate :: proc(r: rune) -> bool

take_while :: proc {
	take_while_0,
	take_while_m,
	take_while_m_n,
}

take_while_0 :: proc(pred: RunePredicate) -> Parser(string, RunePredicate) {
	return {pred, proc(pred: RunePredicate, s: ^string) -> (result: string, ok := true) {
			count := len(s)

			for r, i in s^ {
				if !pred(r) {
					count = i
					break
				}
			}

			result = s[:count]
			s^ = s[count:]

			return
		}}}

take_while_m :: proc(min: int, pred: RunePredicate) -> Parser(string, struct {
			min:  int,
			pred: RunePredicate,
		}) {
	return {{min, pred}, proc(ctx: struct {
				min:  int,
				pred: RunePredicate,
			}, s: ^string) -> (result: string, ok: bool) {

			result = exec(take_while(ctx.pred), s) or_return
			ok = len(result) >= ctx.min
			return
		}}}

take_while_m_n :: proc(m, n: int, pred: RunePredicate) -> Parser(string, struct {
			m, n: int,
			pred: RunePredicate,
		}) {
	return {{m, n, pred}, proc(ctx: struct {
				m, n: int,
				pred: RunePredicate,
			}, s: ^string) -> (result: string, ok: bool) {

			result = exec(take_while(ctx.pred), s) or_return
			ok = len(result) >= ctx.m && len(result) <= ctx.n
			return
		}}}
