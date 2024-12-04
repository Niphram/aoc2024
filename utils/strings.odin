package utils

count_with_stride :: proc(s, substr: string, stride := 1) -> (count: int) {
	s := transmute([]u8)s
	substr := transmute([]u8)substr

	end_offset := (len(substr) - 1) * stride

	outer: for i in 0 ..= (len(s) - end_offset) {
		for substring_byte, j in substr {
			cmp_idx := i + j * stride

			if s[cmp_idx] != substring_byte {
				continue outer
			}

		}

		count += 1
	}

	return
}
