package day_24

import "core:reflect"
import "core:slice"
import "core:strconv"
import "core:strings"

import "../parse"
import "../utils"

Operation :: enum {
	AND,
	OR,
	XOR,
}

Gate :: struct {
	a, b:      string,
	operation: Operation,
}

parse_input :: proc(
	input: string,
) -> (
	wires: map[string]bool,
	gates: map[string]Gate,
	highest_z := "z00",
	ok := true,
) {
	wires_input, gates_input := utils.split_once(input, "\n\n") or_return

	for wire_string in strings.split_lines_iterator(&wires_input) {
		wires[wire_string[:3]] = wire_string[5] == '1'
	}

	for gate_string in strings.split_lines_iterator(&gates_input) {
		gate_string := gate_string

		wire_a := parse.take_until(&gate_string, ' ') or_return
		operation_string := parse.take_until(&gate_string, ' ') or_return
		wire_b := parse.take_until(&gate_string, ' ') or_return
		parse.take_until(&gate_string, ' ') or_return
		result_wire := parse.take_until(&gate_string, ' ') or_return

		operation := reflect.enum_from_name(Operation, operation_string) or_return

		gates[result_wire] = Gate {
			a         = wire_a,
			b         = wire_b,
			operation = operation,
		}

		// Update highest z
		if result_wire[0] == 'z' && result_wire > highest_z {
			highest_z = result_wire
		}
	}

	return
}

part_1 :: proc(input: string) -> (result: int) {
	wires, gates, highest_z := parse_input(input) or_else panic("Could not parse input")
	defer delete(wires)
	defer delete(gates)

	// Recursively solves the node, persists results in 'wires'
	solve_node :: proc(node: string, wires: ^map[string]bool, gates: map[string]Gate) -> bool {
		if node in wires do return wires[node]

		gate := gates[node] or_else panic("Could not find node")

		a := solve_node(gate.a, wires, gates)
		b := solve_node(gate.b, wires, gates)

		result: bool = ---

		switch gate.operation {
		case .AND:
			result = a & b
		case .OR:
			result = a | b
		case .XOR:
			result = a ~ b
		}

		wires[node] = result
		return result
	}

	z := strconv.parse_int(highest_z[1:], 10) or_else panic("Could not find highest z")
	for ; z >= 0; z -= 1 {
		wire_name := string([]u8{'z', u8(z / 10 + '0'), u8(z % 10 + '0')})

		value := solve_node(wire_name, &wires, gates)

		// Shift left and append digit
		result <<= 1
		result |= 1 if value else 0
	}

	return
}

part_2 :: proc(input: string) -> (result: string) {
	wires, gates, highest_z := parse_input(input) or_else panic("Help")
	defer delete(wires)
	defer delete(gates)

	incorrect_wire_names: [dynamic]string
	defer delete(incorrect_wire_names)

	is_xyz_node :: proc(node: string) -> bool {
		return node[0] == 'x' || node[0] == 'y' || node[0] == 'z'
	}

	any_of :: proc(input: string, tests: ..string) -> bool {
		return slice.any_of(tests, input)
	}

	// Find all the wrong gates
	// This does not detect topological errors (switching two wires in the same gate-group, i.e. z20 <-> z34)
	// My input doesn't include errors like that, by I don't know if this is the case in general
	for result_wire, gate in gates {
		// Result is z-wire but the gate is not XOR (except last bit)
		if result_wire[0] == 'z' && gate.operation != .XOR && result_wire != highest_z {
			append(&incorrect_wire_names, result_wire)
		}

		// Gate is XOR but none of the inputs or output are z-wires
		if gate.operation == .XOR &&
		   !is_xyz_node(result_wire) &&
		   !is_xyz_node(gate.a) &&
		   !is_xyz_node(gate.b) {
			append(&incorrect_wire_names, result_wire)
		}

		// AND gate (except the first x00 & y00) and the result is used in an OR gate
		if gate.operation == .AND && !any_of("x00", gate.a, gate.b) {
			for sub_wire, sub_gate in gates {
				wire_is_requirenment := any_of(result_wire, sub_gate.a, sub_gate.b)
				if wire_is_requirenment && sub_gate.operation != .OR {
					append(&incorrect_wire_names, result_wire)
				}
			}
		}

		// XOR gate and the result is not used in an OR gate
		if gate.operation == .XOR {
			for sub_wire, sub_gate in gates {
				wire_is_requirenment := any_of(result_wire, sub_gate.a, sub_gate.b)
				if wire_is_requirenment && sub_gate.operation == .OR {
					append(&incorrect_wire_names, result_wire)
				}
			}
		}
	}

	// Sort, unique and join
	slice.sort(incorrect_wire_names[:])
	return strings.join(slice.unique(incorrect_wire_names[:]), ",")
}

main :: proc() {
	_, part2_result := utils.aoc_main(part_1, part_2)
	delete(part2_result)
}
