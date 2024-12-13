package day_13

import "core:fmt"
import "core:os"
import "core:strings"
import "core:testing"

import "../parse"

Vec2i :: [2]int

parse_input :: proc(input: ^string) -> (a, b, prize: Vec2i, ok := true) {
	parse.take(input, "Button A: X+") or_return
	a.x = parse.read_number(input) or_return
	parse.take(input, ", Y+") or_return
	a.y = parse.read_number(input) or_return

	parse.take(input, "\nButton B: X+") or_return
	b.x = parse.read_number(input) or_return
	parse.take(input, ", Y+") or_return
	b.y = parse.read_number(input) or_return

	parse.take(input, "\nPrize: X=") or_return
	prize.x = parse.read_number(input) or_return
	parse.take(input, ", Y=") or_return
	prize.y = parse.read_number(input) or_return

	return
}

solve_button_presses :: proc(a_btn, b_btn, prize: Vec2i) -> (a_presses, b_presses: int, ok: bool) {
	// Equations
	// A*a + B*b = c
	// A*d + B*e = f

	// A = (f - B*e) / d
	// B = (c*d - a*f) / b*d - a*e 
	// Only when bd != ae and d != 0
	// A, B need to be integers

	// Shorter names
	a, b, c, d, e, f := a_btn.x, b_btn.x, prize.x, a_btn.y, b_btn.y, prize.y

	// Solve for B-presses
	{
		numerator := (c * d) - (a * f)
		denominator := (b * d) - (a * e)

		// Check if solution possible
		if denominator == 0 do return
		if d == 0 do return

		// Make sure B has an integer solution
		if numerator % denominator != 0 do return

		b_presses = numerator / denominator
	}

	// Solve for A-presses
	{
		numerator := f - e * b_presses

		// Make sure A has an integer solution
		if numerator % d != 0 do return

		a_presses = numerator / d
	}

	// This doesn't happen in my input, although I can't say for sure the input always adheres to this rule
	// The input also seems to guarantee, that the two linear equations only ever have zero or one solutions
	if a_presses < 0 || b_presses < 0 do return

	return a_presses, b_presses, true
}

part_1 :: proc(input: string) -> (tokens: int) {
	input := input

	for machine in strings.split_iterator(&input, "\n\n") {
		machine := machine

		a, b, prize := parse_input(&machine) or_continue

		test_a := prize / a
		test_b := prize / b

		a_presses, b_presses := solve_button_presses(a, b, prize) or_continue

		// This doesn't happen in my input, although I can't say for sure the input always adheres to this rule
		if a_presses > 100 || b_presses > 100 do continue

		tokens += b_presses + 3 * a_presses
	}

	return
}

part_2 :: proc(input: string) -> (tokens: int) {
	input := input

	for machine in strings.split_iterator(&input, "\n\n") {
		machine := machine

		a, b, prize := parse_input(&machine) or_continue
		prize += {10000000000000, 10000000000000}

		a_presses, b_presses := solve_button_presses(a, b, prize) or_continue
		tokens += b_presses + 3 * a_presses
	}

	return
}

main :: proc() {
	input :=
		os.read_entire_file(#directory + "/input.txt") or_else panic("Could not read input file")
	defer delete(input)

	fmt.printfln("Part 1: %i", part_1(string(input)))
	fmt.printfln("Part 2: %i", part_2(string(input)))
}

EXAMPLE_INPUT: string : `Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
`


@(test)
part1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(EXAMPLE_INPUT), 480)
}
