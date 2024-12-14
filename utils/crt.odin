package utils

import "core:slice"

chinese_remainder_theorem :: proc(equations: [][2]int) -> int {
	N := slice.reduce(equations, 1, proc(acc: int, eq: [2]int) -> int {
		return acc * eq.y
	})

	X := 0
	for i in 0 ..< len(equations) {
		N_i := N / equations[i].y
		X += mod_mul_inv(N_i, equations[i].y) * N_i * equations[i].x
	}

	return X % N
}

// Modular multiplicative inverse
mod_mul_inv :: proc(a, m: int) -> int {
	if gcd(a, m) != 1 do return -1

	for x in 1 ..< m {
		if ((a % m) * (x % m)) % m == 1 {
			return x
		}
	}

	return 1
}

// Greatest Common Divisor 
gcd :: proc(a, b: int) -> int {
	a, b := a, b

	for b != 0 {
		a, b = b, a % b
	}

	return a
}
