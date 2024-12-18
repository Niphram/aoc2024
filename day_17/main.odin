package day_17

import "core:slice"
import "core:strconv"
import "core:strings"
import "core:testing"

import "../parse"
import "../utils"

VM :: struct {
	a, b, c: int,
	pc:      int,
	memory:  []int,
}

vm_run :: proc(vm: VM) -> (outputs: [dynamic]int) {
	vm := vm

	for ; vm.pc < len(vm.memory); vm.pc += 2 {
		instr := vm.memory[vm.pc]
		literal_operand := vm.memory[vm.pc + 1]
		combo_operand: int

		switch literal_operand {
		case 0, 1, 2, 3:
			combo_operand = literal_operand
		case 4:
			combo_operand = vm.a
		case 5:
			combo_operand = vm.b
		case 6:
			combo_operand = vm.c
		case 7:
			panic("Invalid operand!")
		}

		switch instr {
		case 0:
			// adv
			vm.a /= utils.pow(2, combo_operand)
		case 1:
			// bxl
			vm.b ~= literal_operand
		case 2:
			// bst
			vm.b = combo_operand % 8
		case 3:
			//jnz
			if vm.a != 0 {
				vm.pc = literal_operand - 2 // -2 so pc doesn't increase
			}
		case 4:
			// bxc
			vm.b ~= vm.c
		case 5:
			// out
			append(&outputs, combo_operand % 8)
		case 6:
			// bdv
			vm.b = vm.a / utils.pow(2, combo_operand)
		case 7:
			// cdv
			vm.c = vm.a / utils.pow(2, combo_operand)
		}
	}

	return
}

parse_input :: proc(s: string) -> (vm: VM, ok := true) {
	s := s

	parse.take(&s, "Register A: ") or_return
	vm.a = parse.read_number(&s) or_return
	parse.take(&s, "\nRegister B: ") or_return
	vm.b = parse.read_number(&s) or_return
	parse.take(&s, "\nRegister C: ") or_return
	vm.c = parse.read_number(&s) or_return

	parse.take(&s, "\n\nProgram: ") or_return

	pl := (len(s) + 1) / 2
	vm.memory = make([]int, pl)

	pc := 0
	for instr in strings.split_iterator(&s, ",") {
		vm.memory[pc] = strconv.parse_int(utils.trim_newline(instr), 10) or_return
		pc += 1
	}

	return
}

part_1 :: proc(input: string) -> (result: string) {
	vm := parse_input(input) or_else panic("Could not parse input!")
	defer delete(vm.memory)

	outputs := vm_run(vm)
	defer delete(outputs)

	b := strings.builder_init(&strings.Builder{})
	for o, i in outputs {
		if i != 0 do strings.write_rune(b, ',')
		strings.write_int(b, o)
	}

	return string(b.buf[:])
}

part_2 :: proc(input: string) -> (result: int) {
	vm := parse_input(input) or_else panic("Could not parse input!")
	defer delete(vm.memory)

	// Every output is dependent on 3 bits of the input, as well as the preceding bits
	// i.e.: The last number that is output, is only influences by the last 3 bits of the input
	// The second to last number is influenced by the last 6 bits of the input and so on

	// This means, we can start from the back and update 3 bits at a time until the output matches, then continue forwards
	// Keep track if these individual offsets
	offsets := make([]int, len(vm.memory))
	defer delete(offsets)

	// Set the last offset to 1, so we have enough outputs
	slice.last_ptr(offsets)^ = 1

	next: for {
		init_a := 0
		#reverse for offset in offsets {
			init_a = (init_a << 3) + offset
		}

		// Copy the VM and change the starting value
		vm := vm
		vm.a = init_a

		// Run to completion
		outputs := vm_run(vm)
		defer delete(outputs)

		// Update our offsets
		#reverse for &off, i in offsets {
			// Our outputs don't match, increase the offset at that position
			if outputs[i] != vm.memory[i] {
				off += 1
				continue next
			}
		}

		// If we reach this line, the output matches the program
		return init_a
	}
}

main :: proc() {
	part1_result, _ := utils.aoc_main(part_1, part_2)
	delete(part1_result)
}

EXAMPLE_1: string : `Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0
`


EXAMPLE_2: string : `Register A: 2024
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0
`


@(test)
part1_test :: proc(t: ^testing.T) {
	result := part_1(EXAMPLE_1)
	defer delete(result)
	testing.expect_value(t, result, "4,6,3,5,6,3,5,2,1,0")
}

@(test)
part2_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(EXAMPLE_2), 117440)
}
