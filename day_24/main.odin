package day_24

import "core:container/topological_sort"
import "core:fmt"
import "core:math"
import "core:strings"
import "core:testing"

import "../parse"
import "../utils"

GateType :: enum {
	AND,
	OR,
	XOR,
}

Gate :: struct {
	a, b: string,
	type: GateType,
}

Wire :: struct {
	name:  string,
	value: union {
		bool,
		Gate,
	},
}

parse_wires :: proc(input: string) -> (wires: map[string]Wire, ok := true) {
	wires_input, gates_input := utils.split_once(input, "\n\n") or_return

	for wire_string in strings.split_lines_iterator(&wires_input) {
		wire_name := wire_string[:3]
		wire_value := wire_string[5] == '1'

		wires[wire_name] = Wire {
			name  = wire_name,
			value = wire_value,
		}
	}

	for gate_string in strings.split_lines_iterator(&gates_input) {
		gate_string := gate_string

		wire_a := parse.take_until(&gate_string, ' ') or_return
		gate_type_string := parse.take_until(&gate_string, ' ') or_return
		wire_b := parse.take_until(&gate_string, ' ') or_return

		// Arrow
		parse.take_until(&gate_string, ' ') or_return

		wire_name := parse.take_until(&gate_string, ' ') or_return

		gate_type: GateType = ---

		switch gate_type_string {
		case "AND":
			gate_type = .AND
		case "XOR":
			gate_type = .XOR
		case "OR":
			gate_type = .OR
		case:
			return
		}

		wires[wire_name] = Wire {
			name = wire_name,
			value = Gate{a = wire_a, b = wire_b, type = gate_type},
		}
	}

	return
}

make_net :: proc(wires: map[string]Wire) -> (sorter: topological_sort.Sorter(Wire)) {
	for _, wire in wires {
		switch value in wire.value {
		case bool:
			topological_sort.add_key(&sorter, wire)
		case Gate:
			topological_sort.add_dependency(&sorter, wires[value.a], wire)
			topological_sort.add_dependency(&sorter, wires[value.b], wire)
		}
	}

	return
}

evaluate_net :: proc(sorted_wires: []Wire) -> map[string]bool {
	wire_states: map[string]bool

	#reverse for wire in sorted_wires {
		switch value in wire.value {
		case bool:
			wire_states[wire.name] = value
		case Gate:
			a_value := wire_states[value.a] or_else panic("NOT SET?!")
			b_value := wire_states[value.b] or_else panic("NOT SET?!")

			switch value.type {
			case .AND:
				wire_states[wire.name] = a_value & b_value
			case .XOR:
				wire_states[wire.name] = a_value ~ b_value
			case .OR:
				wire_states[wire.name] = a_value | b_value
			}
		}
	}

	return wire_states
}

calculate_number :: proc(wire_states: map[string]bool, wire_prefix: rune) -> (result: int) {
	named_wires: map[int]bool
	defer delete(named_wires)

	for k, v in wire_states {
		if k[0] == u8(wire_prefix) {
			n := k[1:]

			wire_index := parse.read_number(&n) or_else panic("?!")
			named_wires[wire_index] = v
		}
	}

	for i := 99; i >= 0; i -= 1 {
		if value, ok := named_wires[i]; ok {

			result <<= 1
			result |= 1 if value else 0
		}
	}

	return
}

part_1 :: proc(input: string) -> (result: int) {
	wires := parse_wires(input) or_else panic("Could not parse input")
	defer delete(wires)

	sorter := make_net(wires)
	defer topological_sort.destroy(&sorter)

	sorted, cycled := topological_sort.sort(&sorter)
	delete(cycled)
	defer delete(sorted)
	assert(len(cycled) == 0)

	wire_states := evaluate_net(sorted[:])
	defer delete(wire_states)

	return calculate_number(wire_states, 'z')
}

part_2 :: proc(input: string) -> (result: int) {
	wires := parse_wires(input) or_else panic("Could not parse input")
	defer delete(wires)

	swap_wires :: proc(wires: ^map[string]Wire, a, b: string) {
		wire_a := wires[a]
		wire_b := wires[b]

		wire_a.name = b
		wire_b.name = a

		wires[a] = wire_b
		wires[b] = wire_a
	}

	// swap_wires(&wires, "z22", "hwq")
	// swap_wires(&wires, "thm", "z08")

	// z08 can be swapped anywhere, no dependents
	//swap_wires(&wires, "z22", "hwq")
	// z08 can be swapped anywhere, no dependents
	//swap_wires(&wires, "z22", "hwq")
	// z29 can be swapped anywhere, no dependents
	//swap_wires(&wires, "z29", "hwq")

	// z29 needs to depend directly on dcf -> z29 ~ rpq?


	// BEST GUESSES
	swap_wires(&wires, "z08", "thm")
	swap_wires(&wires, "z22", "hwq")
	swap_wires(&wires, "z29", "gbs")
	swap_wires(&wires, "wss", "wrm")

	/*
	gbs,hwq,thm,wrm,wss,z08,z22,z29
	*/

	// z13 <- cqb pbd

	// OR -> Z-XOR && !Z-AND

	// vsn
	// rhk -> z01
	// rhk -> tpp -> mbr -> z02
	// rhk -> tpp -> mbr -> jdj -> rsm -> z03
	// rhk -> tpp -> mbr -> jdj -> rsm -> qwg -> ggh -> z04
	// rhk -> tpp -> mbr -> jdj -> rsm -> qwg -> ggh -> spd -> pvb


	// hwq -> fjs -> z23
	// hwq -> fjs -> fdc -> qbr -> z24
	// hwq -> fjs -> fdc -> qbr -> pqq -> dwm -> z25
	// hwq -> fjs -> fdc -> qbr -> pqq -> dwm -> rws -> fcn -> z26
	// hwq -> fjs -> fdc -> qbr -> pqq -> dwm -> rws -> fcn -> tgg -> frj -> z27
	// hwq -> fjs -> fdc -> qbr -> pqq -> dwm -> rws -> fcn -> tgg -> frj -> pgq -> bst -> z28
	// hwq -> fjs -> fdc -> qbr -> pqq -> dwm -> rws -> fcn -> tgg -> frj -> pgq -> bst -> pdq -> dcf -> rpq -> z29
	// hwq -> fjs -> fdc -> qbr -> pqq -> dwm -> rws -> fcn -> tgg -> frj -> pgq -> bst -> pdq -> dcf -> gbs -> z30
	// hwq -> fjs -> fdc -> qbr -> pqq -> dwm -> rws -> fcn -> tgg -> frj -> pgq -> bst -> pdq -> dcf -> gbs -> dqf -> hvf -> z31
	// hwq -> fjs -> fdc -> qbr -> pqq -> dwm -> rws -> fcn -> tgg -> frj -> pgq -> bst -> pdq -> dcf -> gbs -> dqf -> hvf -> wjp -> qvq -> z32
	// hwq -> fjs -> fdc -> qbr -> pqq -> dwm -> rws -> fcn -> tgg -> frj -> pgq -> bst -> pdq -> dcf -> gbs -> dqf -> hvf -> wjp -> qvq -> bgq -> vng -> z33
	// hwq -> fjs -> fdc -> qbr -> pqq -> dwm -> rws -> fcn -> tgg -> frj -> pgq -> bst -> pdq -> dcf -> gbs -> dqf -> hvf -> wjp -> qvq -> bgq -> vng -> vbf -> vkv -> z34
	// hwq -> fjs -> fdc -> qbr -> pqq -> dwm -> rws -> fcn -> tgg -> frj -> pgq -> bst -> pdq -> dcf -> gbs -> dqf -> hvf -> wjp -> qvq -> bgq -> vng -> vbf -> vkv -> vsr -> jrp -> z35
	// hwq -> fjs -> fdc -> qbr -> pqq -> dwm -> rws -> fcn -> tgg -> frj -> pgq -> bst -> pdq -> dcf -> gbs -> dqf -> hvf -> wjp -> qvq -> bgq -> vng -> vbf -> vkv -> vsr -> jrp -> psh -> fpc -> z36
	// hwq -> fjs -> fdc -> qbr -> pqq -> dwm -> rws -> fcn -> tgg -> frj -> pgq -> bst -> pdq -> dcf -> gbs -> dqf -> hvf -> wjp -> qvq -> bgq -> vng -> vbf -> vkv -> vsr -> jrp -> psh -> fpc -> hdw...

	// 14, 15, 16, 17
	// 29, 30, 31, 32, 33, 34, 35, 36

	// z12 = ((gst AND (y11 XOR x11)) OR (y11 AND x11)) XOR (y12 XOR x12)

	// c_0 = x_0 AND y_0
	// z_0 = x_0 XOR y_0

	// z_i = x_i-1 XOR y_i-1 XOR c_i-1
	// c_i = 

	// x13 xor y13 -> 

	// rmm -> z12
	// rmm -> sft -> cqb -> z13
	// rmm -> sft -> cqb -> vns -> hgw -> z14
	// rmm -> sft -> cqb -> vns -> hgw -> cgv -> mjj
	// pbd -> z13
	// pbd -> vns -> hgw -> z14
	// pbd -> vns -> hgw -> cgv -> mjj -> z15
	// pbd -> vns -> hgw -> cgv -> mjj -> ntv

	// Sanity checks for ripple carrier
	for _, wire in wires {

		#partial switch value in wire.value {
		case Gate:
			#partial switch value.type {

			case .XOR:
				// Check 1: No XOR gates with x and y inputs can result in a z output (except x00 and y00)
				if value.a[0] == 'x' ||
				   value.a[0] == 'y' && value.b[0] == 'x' ||
				   value.b[0] == 'y' {

					if wire.name[0] == 'z' && !(value.a[1:] == "00" && value.b[1:] == "00") {
						fmt.printfln("Invalid XOR: %s XOR %s => %s", value.a, value.b, wire.name)
					}

				} else {
					// Check 2: All other XOR gates have to output z
					if wire.name[0] != 'z' {
						fmt.printfln("Invalid XOR: %s XOR %s => %s", value.a, value.b, wire.name)
					}
				}
			}

			if wire.name[0] == 'z' {
				if value.type != .XOR && wire.name != "z45" {
					fmt.printfln(
						"Invalid Z-Output: %s %v %s => %s",
						value.a,
						value.type,
						value.b,
						wire.name,
					)
				}
			}
		}
	}


	sorter := make_net(wires)
	defer topological_sort.destroy(&sorter)

	sorted, cycled := topological_sort.sort(&sorter)
	assert(len(cycled) == 0)

	wire_states := evaluate_net(sorted[:])
	defer delete(wire_states)

	x_res := calculate_number(wire_states, 'x')
	y_res := calculate_number(wire_states, 'y')
	z_res := calculate_number(wire_states, 'z')

	xy_sum := x_res + y_res

	print_rec :: proc(node: string, wires: map[string]Wire) {
		wire := wires[node] or_else panic("Not found")

		switch value in wire.value {
		case bool:
		//fmt.println(wire.name)
		case Gate:
			fmt.println(wire.name, "depends on", value.a, value.type, value.b)
			print_rec(value.a, wires)
			print_rec(value.b, wires)
		}
	}

	for i in 0 ..< uint(math.count_digits_of_base(z_res, 2)) {

		mask := 1 << i

		if xy_sum & mask != z_res & mask {

			fmt.println("Invalid at", i)

			i := i + 3

			z_string := string([]u8{'z', u8(i / 10 + '0'), u8(i % 10 + '0')})

			print_rec(z_string, wires)

			break
		}

	}


	fmt.printfln("% 50b", calculate_number(wire_states, 'x'))
	fmt.printfln("+% 49b", calculate_number(wire_states, 'y'))
	fmt.println()
	fmt.printfln("=% 49b", calculate_number(wire_states, 'x') + calculate_number(wire_states, 'y'))
	fmt.printfln("% 50b", calculate_number(wire_states, 'z'))

	return calculate_number(wire_states, 'z')
}

main :: proc() {
	utils.aoc_main(part_1, part_2)
}

EXAMPLE_INPUT: string : `x00: 1
x01: 1
x02: 1
y00: 0
y01: 1
y02: 0

x00 AND y00 -> z00
x01 XOR y01 -> z01
x02 OR y02 -> z02
`


@(test)
part1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(EXAMPLE_INPUT), 4)
}

@(test)
part2_test :: proc(t: ^testing.T) {
	// testing.expect_value(t, part_2(EXAMPLE_INPUT), 0)
}
