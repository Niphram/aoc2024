package day_24

import "core:container/small_array"
import "core:container/topological_sort"
import "core:fmt"
import "core:math"
import "core:slice"
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

calculate_number :: proc(wire_states: map[string]bool, wire_prefix: u8) -> (result: int) {
	for i in 0 ..< u8(100) {
		i := 99 - i
		wire_name := string([]u8{wire_prefix, i / 10 + '0', i % 10 + '0'})

		if value, ok := wire_states[wire_name]; ok {
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

	defer delete(sorted)
	defer delete(cycled)

	// there should be no cycles in the net 
	assert(len(cycled) == 0, "Cycles detected in input!")

	wire_states := evaluate_net(sorted[:])
	defer delete(wire_states)

	return calculate_number(wire_states, 'z')
}

part_2 :: proc(input: string) -> (result: string) {
	wires := parse_wires(input) or_else panic("Could not parse input")
	defer delete(wires)

	highest_z := "z45"

	wrong: [dynamic]string
	defer delete(wrong)

	// Find all the wrong gates
	// This seems to work in general, but I'll clean this entire solution up... tomorrow.
	for _, wire in wires {
		if gate, ok := wire.value.(Gate); ok {

			// Result is z-wire but the gate is not XOR (except last bit)
			if wire.name[0] == 'z' && gate.type != .XOR && wire.name != highest_z {
				append(&wrong, wire.name)
			}

			// Gate is XOR but none of the inputs or output are z-wires
			if gate.type == .XOR &&
			   strings.index_any(wire.name, "xyz") != 0 &&
			   strings.index_any(gate.a, "xyz") != 0 &&
			   strings.index_any(gate.b, "xyz") != 0 {
				append(&wrong, wire.name)
			}

			// AND gate (except the first x00&y00) and the result is used in an OR gate
			if gate.type == .AND && (gate.a != "x00" && gate.b != "x00") {
				for _, sub_wire in wires {
					if sub_gate, ok := sub_wire.value.(Gate); ok {
						if (wire.name == sub_gate.a || wire.name == sub_gate.b) &&
						   sub_gate.type != .OR {
							append(&wrong, wire.name)
						}
					}
				}
			}

			// XOR gate and the result is not used in an OR gate
			if gate.type == .XOR {
				for _, sub_wire in wires {
					if sub_gate, ok := sub_wire.value.(Gate); ok {
						if (wire.name == sub_gate.a || wire.name == sub_gate.b) &&
						   sub_gate.type == .OR {
							append(&wrong, wire.name)
						}
					}
				}
			}
		}
	}

	slice.sort(wrong[:])
	wrong_unique := slice.unique(wrong[:])

	return strings.join(wrong_unique, ",")
}

main :: proc() {
	_, part2_result := utils.aoc_main(part_1, part_2)
	delete(part2_result)
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
