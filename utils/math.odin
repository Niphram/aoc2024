package utils

import "core:math"

/*
Splits a number into two parts (i.e. if you concatenate those parts, you get the original number)
The index is measured from the right / the least-significant digits

example: split_int(12345, 2) -> (123, 45)
*/
split_int :: proc(n, index: int) -> (left, right: int) {
	base := int(math.pow10(f64(index)))
	return (n / base), (n % base)
}
